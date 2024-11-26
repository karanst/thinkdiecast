import 'dart:convert';

/// status : true
/// subCode : 200
/// message : "Attendance Checked"
/// error : ""
/// items : {"allowed":true}
AttendanceCheckModel attendanceCheckModelFromJson(String str) =>
    AttendanceCheckModel.fromJson(json.decode(str));

String attendanceCheckModelToJson(AttendanceCheckModel data) =>
    json.encode(data.toJson());

class AttendanceCheckModel {
  AttendanceCheckModel({
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

  AttendanceCheckModel.fromJson(dynamic json) {
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
  AttendanceCheckModel copyWith({
    bool? status,
    num? subCode,
    String? message,
    String? error,
    Items? items,
  }) =>
      AttendanceCheckModel(
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

/// allowed : true

class Items {
  Items({
    bool? allowed,
  }) {
    _allowed = allowed;
  }

  Items.fromJson(dynamic json) {
    _allowed = json['allowed'];
  }
  bool? _allowed;
  Items copyWith({
    bool? allowed,
  }) =>
      Items(
        allowed: allowed ?? _allowed,
      );
  bool? get allowed => _allowed;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['allowed'] = _allowed;
    return map;
  }
}
