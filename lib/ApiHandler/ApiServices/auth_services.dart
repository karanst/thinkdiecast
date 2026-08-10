import 'package:flutter/foundation.dart';
import 'package:thinkdiecast/ApiHandler/ApiServices/api_services.dart';
import 'package:thinkdiecast/models/user_model.dart';

import 'app_exceptions.dart';
// import your ApiService / User / AuthResponse models as before, e.g.:
// import 'api_service.dart';
// import 'user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Register a new user.
  ///
  /// NOTE: this does NOT log the user in — it just creates the account.
  /// Auto-login-after-signup is handled in LoginController.register(),
  /// which calls login() right after this succeeds.
  Future<User> register({
    required String name,
    required String email1,
    required String password, // This is actually the password field
    required String city,
    required String phone,
    String? uid,
    String plan = 'free',
    int limit = 5,
    int entries = 0,
  }) async {
    try {
      final response = await _apiService.post(
        '/Users/register',
        body: {
          'name': name,
          'email': email1,
          'pass': password,
          'city': city,
          'phone': phone,
          'uid': (uid == null || uid.isEmpty)
              ? DateTime.now().microsecondsSinceEpoch.toString()
              : uid,
          'plan': plan,
          'limit': limit,
          'entries': entries,
        },
      );

      if (response is Map<String, dynamic>) {
        final user = User.fromJson(response['user'] ?? response);
        await _apiService.saveUserData(user.toJson());
        return user;
      } else {
        throw ServerException('Invalid response from server.');
      }
    } catch (e) {
      // Route through the classifier instead of re-wrapping blindly, so
      // the UI gets a clean, specific message (network / validation /
      // server) instead of a nested "Exception: Registration failed:
      // Exception: ..." string.
      throw classifyError(e);
    }
  }

  /// Login user with email and password.
  Future<AuthResponse> login({
    required String email1,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/Users/login',
        body: {
          'email': email1,
          'password': password,
        },
      );

      if (response is Map<String, dynamic>) {
        final token = response['token'] as String?;
        final userId = response['user']['id'] as String?;
        if (token == null) {
          // Server responded 200 but with no token -> treat as bad
          // credentials, not a generic/server error.
          throw UnauthorizedException();
        }
        print('this is my api response $response');
        print('this is my token ${response['token']}');
        await _apiService.saveToken(token);
        await _apiService.saveUserId(userId ?? '');


        final userData =
            response['user'] as Map<String, dynamic>? ?? response;
        final user = User.fromJson(userData);




        await _apiService.saveUserData(user.toJson());

        return AuthResponse(token: token, user: user);
      } else {
        throw ServerException('Invalid response from server.');
      }
    } catch (e) {
      throw classifyError(e);
    }
  }

  /// Logout user - clear all stored data
  Future<void> logout() async {
    try {
      await _apiService.clearAllData();
    } catch (e) {
      throw classifyError(e);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current authentication token
  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  /// Get stored user data
  Future<User?> getCurrentUser() async {
    final userData = await _apiService.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }
}


/*class AuthService {
  final ApiService _apiService = ApiService();

  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Register a new user.
  ///
  /// NOTE: this does NOT log the user in — it just creates the account.
  /// Auto-login-after-signup is handled in LoginController.register(),
  /// which calls login() right after this succeeds.
  Future<User> register({
    required String name,
    required String email1,
    required String emailS, // This is actually the password field
    required String city,
    required String phone,
    String? uid,
    String plan = 'free',
    int limit = 5,
    int entries = 0,
  }) async {
    print('working here $email1');
    try {
      final response = await _apiService.post(
        '/Users/register',
        body: {
          'name': name,
          'email1': email1,
          'emailS': emailS,
          'City': city,
          'phone': phone,
          'uid': uid ?? '',
          'plan': plan,
          'limit': limit,
          'entries': entries,
        },
      );

      if (response is Map<String, dynamic>) {
        final user = User.fromJson(response['user'] ?? response);
        await _apiService.saveUserData(user.toJson());
        return user;
      } else {
        throw ServerException('Invalid response from server.');
      }
    } catch (e) {
      // Route through the classifier instead of re-wrapping blindly, so
      // the UI gets a clean, specific message (network / validation /
      // server) instead of a nested "Exception: Registration failed:
      // Exception: ..." string.
      throw classifyError(e);
    }
  }

  /// Login user with email and password.
  Future<AuthResponse> login({
    required String email1,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        '/Users/login',
        body: {
          'email': email1,
          'password': password,
        },
      );

      if (response is Map<String, dynamic>) {
        final token = response['token'] as String?;
        if (token == null) {
          // Server responded 200 but with no token -> treat as bad
          // credentials, not a generic/server error.
          throw UnauthorizedException();
        }

        final userData =
            response['user'] as Map<String, dynamic>? ?? response;
        final user = User.fromJson(userData);

        await _apiService.saveToken(token);
        await _apiService.saveUserData(user.toJson());

        return AuthResponse(token: token, user: user);
      } else {
        throw ServerException('Invalid response from server.');
      }
    } catch (e) {
      throw classifyError(e);
    }
  }

  /// Logout user - clear all stored data
  Future<void> logout() async {
    try {
      await _apiService.clearAllData();
    } catch (e) {
      throw classifyError(e);
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Get current authentication token
  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  /// Get stored user data
  Future<User?> getCurrentUser() async {
    final userData = await _apiService.getUserData();
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }
}*/


// class AuthService {
//   final ApiService _apiService = ApiService();
//
//   static final AuthService _instance = AuthService._internal();
//
//   factory AuthService() {
//     return _instance;
//   }
//
//   AuthService._internal();
//
//   /// Register a new user
//   ///
//   /// Parameters:
//   /// - name: User's full name
//   /// - email1: User's email address
//   /// - emailS: User's password (note: API field is 'emailS')
//   /// - city: User's city
//   /// - phone: User's phone number
//   /// - uid: Optional unique identifier
//   /// - plan: Subscription plan (default: 'free')
//   /// - limit: Usage limit (default: 5)
//   /// - entries: Initial entries count (default: 0)
//   Future<User> register({
//     required String name,
//     required String email1,
//     required String emailS, // This is actually the password field
//     required String city,
//     required String phone,
//     String? uid,
//     String plan = 'free',
//     int limit = 5,
//     int entries = 0,
//   }) async {
//     try {
//       final response = await _apiService.post(
//         '/Users/register',
//         body: {
//           'name': name,
//           'email1': email1,
//           'emailS': emailS,
//           'City': city,
//           'phone': phone,
//           'uid': uid ?? '',
//           'plan': plan,
//           'limit': limit,
//           'entries': entries,
//         },
//       );
//
//       if (response is Map<String, dynamic>) {
//         final user = User.fromJson(response['user'] ?? response);
//         await _apiService.saveUserData(user.toJson());
//         return user;
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } catch (e) {
//       throw Exception('Registration failed: $e');
//     }
//   }
//
//   /// Login user with email and password
//   ///
//   /// Parameters:
//   /// - email1: User's email address
//   /// - password: User's password
//   ///
//   /// Returns: AuthResponse containing token and user data
//   Future<AuthResponse> login({
//     required String email1,
//     required String password,
//   }) async {
//     try {
//       print('working calling api');
//       final response = await _apiService.post(
//         '/Users/login',
//         body: {
//           'email': email1,
//           'password': password,
//         },
//       );
//
//       print('calling api response');
//       if (response is Map<String, dynamic>) {
//         // Handle different response formats
//         final token = response['token'] as String?;
//         if (token == null) {
//           throw Exception('No token received from server');
//         }
//
//         // Extract user data from response
//         final userData = response['user'] as Map<String, dynamic>? ?? response;
//         final user = User.fromJson(userData);
//
//         // Save token and user data
//         await _apiService.saveToken(token);
//         await _apiService.saveUserData(user.toJson());
//
//         return AuthResponse(token: token, user: user);
//       } else {
//         throw Exception('Invalid response format');
//       }
//     } catch (e) {
//       throw Exception('Login failed: $e');
//     }
//   }
//
//   /// Logout user - clear all stored data
//   Future<void> logout() async {
//     try {
//       await _apiService.clearAllData();
//     } catch (e) {
//       throw Exception('Logout failed: $e');
//     }
//   }
//
//   /// Check if user is authenticated
//   Future<bool> isAuthenticated() async {
//     final token = await _apiService.getToken();
//     return token != null && token.isNotEmpty;
//   }
//
//   /// Get current authentication token
//   Future<String?> getToken() async {
//     return await _apiService.getToken();
//   }
//
//   /// Get stored user data
//   Future<User?> getCurrentUser() async {
//     final userData = await _apiService.getUserData();
//     if (userData != null) {
//       return User.fromJson(userData);
//     }
//     return null;
//   }
// }
