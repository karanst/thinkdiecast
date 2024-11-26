import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../network_constants.dart';

class ApiClient extends GetConnect {
  static final ApiClient _apiClient = ApiClient._internal();

  factory ApiClient() {
    return _apiClient;
  }

  ApiClient._internal();

  @override
  void onInit() {
    //baseUrl = baseAppUrl;

    ///Authenticator will be called 3 times if HttpStatus is
    ///HttpStatus.unauthorized
    //httpClient.maxAuthRetries = 3;
  }

  Future<String> getMethod({
    required String method,
    Map<String, String>? header,
  }) async {
    try {
      log('${NetworkConstantsUtil.baseUrl}$method');
      if (header != null) {
        log(header.toString());
      }
      final response = await http.get(
        Uri.parse('${NetworkConstantsUtil.baseUrl}$method'),
        headers: header,
      );
      log(response.body);
      final json = jsonDecode(response.body);
      return response.body;
    } catch (e) {
      log('______ getMethode error ${e.toString()}');
      return '';
    }
  }

  Future<String> postMethod({
    required method,
    required var body,
    Map<String, String>? header,
  }) async {
    try {
      log('${NetworkConstantsUtil.baseUrl}$method');
      if (header != null) {
        log(header.toString());
      }
      log(body.toString());
      final response = await http.post(
        Uri.parse('${NetworkConstantsUtil.baseUrl}$method'),
        body: body,
        headers: header,
      );
      final json = jsonDecode(response.body);
      log(response.body);
      // return json;
      return response.body;
    } catch (e) {
      log('______ post Method error ${e.toString()}');
      return '';
    }
  }

  Future<String> postMethodMultipart(http.MultipartRequest request) async {
    log(request.fields.toString());
    if (request.files.isNotEmpty) {
      for (var element in request.files) {
        log('___ file ${element.field.toString()} length = ${element.length}');
      }
    } else {
      log('___ file empty');
    }
    http.Response response =
        await http.Response.fromStream(await request.send());
    log(response.body.toString());
    final data = jsonDecode(response.body);
    if (data['code'].toString() == '401') {
      //token expired
      /*Get.offAndToNamed(
        'AppRoutes.login',
        arguments: 'Session expired!!!\nPlease login again.',
      );*/
      return '';
    } else {
      return response.body;
    }
  }
}
