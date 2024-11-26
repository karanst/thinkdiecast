import 'dart:convert';

/// status : true
/// subCode : 200
/// message : "User Logged in successfully"
/// error : ""
/// items : {"employeId":"66850f7d374425e937114180","userName":"nikit.admin","roleName":"admin","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6IjY2ODUwZjdkMzc0NDI1ZTkzNzExNDE4MCIsInJvbGVOYW1lIjoiYWRtaW4iLCJpYXQiOjE3MjE3MzQ2NTl9.J-6VrkG3LZVLhBx6ozFlBWX9FfkgqfafOLS-ijTcs3w"}

LoginModel loginModelFromJson(String str) =>
    LoginModel.fromJson(json.decode(str));
String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  LoginModel({
    bool? status,
    num? subCode,
    String? message,
    String? error,
    Items? items,
  }) {
    _status = status;
    _subCode = subCode;
    _message = message;
    _error = error;
    _items = items;
  }

  LoginModel.fromJson(dynamic json) {
    _status = json['status'];
    _subCode = json['subCode'];
    _message = json['message'];
    _error = json['error'];
    _items = json['items'] != null ? Items.fromJson(json['items']) : null;
  }
  bool? _status;
  num? _subCode;
  String? _message;
  String? _error;
  Items? _items;
  LoginModel copyWith({
    bool? status,
    num? subCode,
    String? message,
    String? error,
    Items? items,
  }) =>
      LoginModel(
        status: status ?? _status,
        subCode: subCode ?? _subCode,
        message: message ?? _message,
        error: error ?? _error,
        items: items ?? _items,
      );
  bool? get status => _status;
  num? get subCode => _subCode;
  String? get message => _message;
  String? get error => _error;
  Items? get items => _items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['status'] = _status;
    map['subCode'] = _subCode;
    map['message'] = _message;
    map['error'] = _error;
    if (_items != null) {
      map['items'] = _items?.toJson();
    }
    return map;
  }
}

/// employeId : "66850f7d374425e937114180"
/// userName : "nikit.admin"
/// roleName : "admin"
/// token : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJJZCI6IjY2ODUwZjdkMzc0NDI1ZTkzNzExNDE4MCIsInJvbGVOYW1lIjoiYWRtaW4iLCJpYXQiOjE3MjE3MzQ2NTl9.J-6VrkG3LZVLhBx6ozFlBWX9FfkgqfafOLS-ijTcs3w"

class Items {
  Items({
    String? employeId,
    String? userName,
    String? roleName,
    String? token,
  }) {
    _employeId = employeId;
    _userName = userName;
    _roleName = roleName;
    _token = token;
  }

  Items.fromJson(dynamic json) {
    _employeId = json['employeId'];
    _userName = json['userName'];
    _roleName = json['roleName'];
    _token = json['token'];
  }
  String? _employeId;
  String? _userName;
  String? _roleName;
  String? _token;
  Items copyWith({
    String? employeId,
    String? userName,
    String? roleName,
    String? token,
  }) =>
      Items(
        employeId: employeId ?? _employeId,
        userName: userName ?? _userName,
        roleName: roleName ?? _roleName,
        token: token ?? _token,
      );
  String? get employeId => _employeId;
  String? get userName => _userName;
  String? get roleName => _roleName;
  String? get token => _token;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['employeId'] = _employeId;
    map['userName'] = _userName;
    map['roleName'] = _roleName;
    map['token'] = _token;
    return map;
  }
}
