import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



import 'package:http_parser/http_parser.dart';

class ApiService {
  static const String baseUrl = 'https://thinkdiecast-api.onrender.com';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _userIdKey = 'user_id';

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }


  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await _guardedRequest(
          () => http.get(Uri.parse('$baseUrl$endpoint'), headers: headers),
    );
    // Outside the network try/catch: _handleResponse's exceptions
    // (401 / 400 / 500 with the server's real message) propagate as-is.
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint,
      {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final response = await _guardedRequest(
          () => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>?> uploadImage(String endpoint, XFile file) async {
    final uri = Uri.parse('$baseUrl$endpoint'); // use your existing base URL field
    final request = http.MultipartRequest('POST', uri);

    final token = await getToken();
    print('uploadImage: retrieved token: $token');
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    print('uploadImage: request headers: ${request.headers}');

    final extension = file.path.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }

    final mimeTypeParts = mimeType.split('/');
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      file.path,
      contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _formatUrlsInJson(jsonDecode(response.body)) as Map<String, dynamic>;
    }
    throw Exception('Image upload failed: ${response.statusCode} ${response.body}');
  }

  Future<dynamic> put(String endpoint,
      {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final response = await _guardedRequest(
          () => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: jsonEncode(body),
      ),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await _guardedRequest(
          () => http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers),
    );
    return _handleResponse(response);
  }

  /// Wraps ONLY the actual network call (DNS/socket/timeout failures).
  /// This is the key fix: previously `_handleResponse` was called inside
  /// the same try/catch as the http call, so a real server-side error
  /// (e.g. a 400 with "name, email, pass... are required") got caught
  /// and re-thrown as a generic "Network error: ..." string, hiding the
  /// actual message. Now only genuine network failures get that label.
  Future<http.Response> _guardedRequest(
      Future<http.Response> Function() request) async {
    try {
      return await request().timeout(const Duration(seconds: 20));
    } on SocketException {
      throw Exception(
          'No internet connection. Please check your network and try again.');
    }
    // on TimeoutException {
    //   throw Exception('Request timed out. Please try again.');
    // } on http.ClientException catch (e) {
    //   throw Exception('Network error: ${e.message}');
    // } catch (e) {
    //   throw Exception('Network error: $e');
    // }
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      final decoded = jsonDecode(response.body);
      return _formatUrlsInJson(decoded);
    } else if (response.statusCode == 401) {
      // Token expired or invalid
      removeToken();
      throw Exception('Unauthorized: Please login again');
    } else if (response.statusCode == 400) {
      try {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? error['message'] ?? 'Bad request');
      } on FormatException {
        throw Exception('Bad request');
      }
    } else if (response.statusCode == 500) {
      String? errorMessage;
      try {
        final error = jsonDecode(response.body);
        errorMessage = error['error'] ?? error['message'] ?? response.body;
      } catch (_) {
        // Fallback to null if not JSON
      }

      if (errorMessage != null) {
        throw Exception('Server error (500): $errorMessage');
      } else {
        throw Exception('Server error: Please try again later');
      }
    } else {
      throw Exception('Error: ${response.statusCode} - ${response.body}');
    }
  }

  dynamic _formatUrlsInJson(dynamic data) {
    if (data is Map) {
      final mapped = data.map((key, value) {
        final stringKey = key.toString();
        if (value is String) {
          String newValue = value;
          if (newValue.contains('http://localhost:3000')) {
            newValue = newValue.replaceAll('http://localhost:3000', baseUrl);
          }
          if (newValue.contains('http://127.0.0.1:3000')) {
            newValue = newValue.replaceAll('http://127.0.0.1:3000', baseUrl);
          }
          final cleanHost = baseUrl.replaceFirst('http://', '').replaceFirst('https://', '');
          if (newValue.contains('localhost:3000')) {
            newValue = newValue.replaceAll('localhost:3000', cleanHost);
          }
          if (newValue.contains('127.0.0.1:3000')) {
            newValue = newValue.replaceAll('127.0.0.1:3000', cleanHost);
          }
          return MapEntry(stringKey, newValue);
        } else if (value is Map || value is List) {
          return MapEntry(stringKey, _formatUrlsInJson(value));
        }
        return MapEntry(stringKey, value);
      });
      return Map<String, dynamic>.from(mapped);
    } else if (data is List) {
      return data.map((item) => _formatUrlsInJson(item)).toList();
    }
    return data;
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<void> clearAllData() async {
    await removeToken();
    await clearUserData();
  }
}




// class ApiService {
//   static const String baseUrl = 'http://localhost:3000'; // Change to your production URL
//   static const String _tokenKey = 'auth_token';
//   static const String _userKey = 'user_data';
//
//   static final ApiService _instance = ApiService._internal();
//
//   factory ApiService() {
//     return _instance;
//   }
//
//   ApiService._internal();
//
//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }
//
//   Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }
//
//   Future<void> removeToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
//
//   Future<Map<String, String>> _getHeaders() async {
//     final token = await getToken();
//     final headers = {
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
//
//     return headers;
//   }
//
//   Future<dynamic> get(String endpoint) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.get(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: headers,
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }
//
//   Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.post(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: headers,
//         body: jsonEncode(body),
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }
//
//   Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.put(
//         Uri.parse('$baseUrl$endpoint'),
//         headers: headers,
//         body: jsonEncode(body),
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }
//
//   Future<dynamic> delete(String endpoint, {required Map<String, String> body}) async {
//     try {
//       final headers = await _getHeaders();
//       final response = await http.delete(
//         Uri.parse('$baseUrl$endpoint'),
//         body: body,
//         headers: headers,
//       );
//
//       return _handleResponse(response);
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }
//
//   dynamic _handleResponse(http.Response response) {
//     if (response.statusCode >= 200 && response.statusCode < 300) {
//       if (response.body.isEmpty) {
//         return {'success': true};
//       }
//       return jsonDecode(response.body);
//     } else if (response.statusCode == 401) {
//       // Token expired or invalid
//       removeToken();
//       throw Exception('Unauthorized: Please login again');
//     } else if (response.statusCode == 400) {
//       final error = jsonDecode(response.body);
//       throw Exception(error['error'] ?? 'Bad request');
//     } else if (response.statusCode == 500) {
//       throw Exception('Server error: Please try again later');
//     } else {
//       throw Exception('Error: ${response.statusCode} - ${response.body}');
//     }
//   }
//
//   Future<void> saveUserData(Map<String, dynamic> userData) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_userKey, jsonEncode(userData));
//   }
//
//   Future<Map<String, dynamic>?> getUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final data = prefs.getString(_userKey);
//     if (data != null) {
//       return jsonDecode(data);
//     }
//     return null;
//   }
//
//   Future<void> clearUserData() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_userKey);
//   }
//
//   Future<void> clearAllData() async {
//     await removeToken();
//     await clearUserData();
//   }
// }
