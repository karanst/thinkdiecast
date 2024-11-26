import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:thinkdiecast/models/attendance_check_model.dart';
import 'package:thinkdiecast/models/employee_punch_model.dart';
import 'package:thinkdiecast/models/login_model.dart';
import 'package:flutter/foundation.dart';

import '../network_constants.dart';
import 'api_client.dart';
import 'api_methods.dart';

class Api {
  final ApiMethods _apiMethods = ApiMethods();
  final ApiClient _apiClient = ApiClient();

  static final Api _api = Api._internal();

  final Connectivity connectivity = Connectivity();

  //final Connectivity? connectivity;

  factory Api() {
    return _api;
  }

  Api._internal();

  Map<String, String> getHeader() {
    return {'Cookie': 'ci_session=c35fa031f74710f20bf26fea3b4ccd7bfe18332a'};
    // return {'Content-Type': 'application/json'};
  }

  Future<LoginModel> loginUserApi(Map<String, String> body) async {
    if (await connectivity.checkConnectivity() == ConnectivityResult.wifi ||
        await connectivity.checkConnectivity() == ConnectivityResult.mobile) {
      String res = await _apiClient.postMethod(
          method: NetworkConstantsUtil.loginUrl, body: body);
      if (res.isNotEmpty) {
        try {
          return loginModelFromJson(res);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          return LoginModel(
              // status: true,
              // message: e.toString(),
              );
        }
      } else {
        return LoginModel(
            // status: false,
            // message: 'Something went wrong',
            );
      }
    } else {
      return LoginModel(
          // status: false,
          // message: 'No Internet',
          );
    }
  }

  Future<AttendanceCheckModel> checkAttendanceApi(
      double lat, long, String token) async {
    if (await connectivity.checkConnectivity() == ConnectivityResult.wifi ||
        await connectivity.checkConnectivity() == ConnectivityResult.mobile) {
      var headers = {'token': '$token'};
      String res = await _apiClient.getMethod(
          method:
              '${NetworkConstantsUtil.attendanceCheckUrl}?latitude=$lat&longitude=$long',
          header: headers);
      if (res.isNotEmpty) {
        try {
          return attendanceCheckModelFromJson(res);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          return AttendanceCheckModel(
            status: true,
            message: e.toString(),
          );
        }
      } else {
        return AttendanceCheckModel(
          status: false,
          message: 'Something went wrong',
        );
      }
    } else {
      return AttendanceCheckModel(
        status: false,
        message: 'No Internet',
      );
    }
  }

  Future<EmployeePunchModel> punchInOutApi(String action, token) async {
    if (await connectivity.checkConnectivity() == ConnectivityResult.wifi ||
        await connectivity.checkConnectivity() == ConnectivityResult.mobile) {
      var headers = {'token': '$token'};
      String res = await _apiClient.getMethod(
          method: '${NetworkConstantsUtil.employeePunchUrl}?action=$action',
          header: headers);
      if (res.isNotEmpty) {
        try {
          return employeePunchModelFromJson(res);
        } catch (e) {
          if (kDebugMode) {
            print(e);
          }
          return EmployeePunchModel(
            status: true,
            message: e.toString(),
          );
        }
      } else {
        return EmployeePunchModel(
          status: false,
          message: 'Something went wrong',
        );
      }
    } else {
      return EmployeePunchModel(
        status: false,
        message: 'No Internet',
      );
    }
  }
}
