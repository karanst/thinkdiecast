import 'dart:convert';

/// status : true
/// subCode : 200
/// message : "Employee Punch in successfully "
/// error : ""
/// items : {"employeeId":"6696603cc300c77cacf9b22d","date":"2024-07-25T23:59:59.999Z","punchInTime":"2024-07-25T23:59:59.999Z","_id":"66a1f3669d9c3881dbe8f6d9","createdAt":"2024-07-25T06:40:38.082Z","updatedAt":"2024-07-25T06:40:38.082Z","__v":0}

EmployeePunchModel employeePunchModelFromJson(String str) =>
    EmployeePunchModel.fromJson(json.decode(str));

String employeePunchModelToJson(EmployeePunchModel data) =>
    json.encode(data.toJson());

class EmployeePunchModel {
  EmployeePunchModel({
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

  EmployeePunchModel.fromJson(dynamic json) {
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
  EmployeePunchModel copyWith({
    bool? status,
    num? subCode,
    String? message,
    String? error,
    Items? items,
  }) =>
      EmployeePunchModel(
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

/// employeeId : "6696603cc300c77cacf9b22d"
/// date : "2024-07-25T23:59:59.999Z"
/// punchInTime : "2024-07-25T23:59:59.999Z"
/// _id : "66a1f3669d9c3881dbe8f6d9"
/// createdAt : "2024-07-25T06:40:38.082Z"
/// updatedAt : "2024-07-25T06:40:38.082Z"
/// __v : 0

class Items {
  Items({
    String? employeeId,
    String? date,
    String? punchInTime,
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) {
    _employeeId = employeeId;
    _date = date;
    _punchInTime = punchInTime;
    _id = id;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _v = v;
  }

  Items.fromJson(dynamic json) {
    _employeeId = json['employeeId'];
    _date = json['date'];
    _punchInTime = json['punchInTime'];
    _id = json['_id'];
    _createdAt = json['createdAt'];
    _updatedAt = json['updatedAt'];
    _v = json['__v'];
  }
  String? _employeeId;
  String? _date;
  String? _punchInTime;
  String? _id;
  String? _createdAt;
  String? _updatedAt;
  num? _v;
  Items copyWith({
    String? employeeId,
    String? date,
    String? punchInTime,
    String? id,
    String? createdAt,
    String? updatedAt,
    num? v,
  }) =>
      Items(
        employeeId: employeeId ?? _employeeId,
        date: date ?? _date,
        punchInTime: punchInTime ?? _punchInTime,
        id: id ?? _id,
        createdAt: createdAt ?? _createdAt,
        updatedAt: updatedAt ?? _updatedAt,
        v: v ?? _v,
      );
  String? get employeeId => _employeeId;
  String? get date => _date;
  String? get punchInTime => _punchInTime;
  String? get id => _id;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  num? get v => _v;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['employeeId'] = _employeeId;
    map['date'] = _date;
    map['punchInTime'] = _punchInTime;
    map['_id'] = _id;
    map['createdAt'] = _createdAt;
    map['updatedAt'] = _updatedAt;
    map['__v'] = _v;
    return map;
  }
}
