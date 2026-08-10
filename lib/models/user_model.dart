class User {
  final String? id;
  late final String name;
  late final String email1;
  late final String city;
  late final String phone;
  final String? uid;
   String? plan;
  final String? limit;
  final String? entries;

  User({
    this.id,
    required this.name,
    required this.email1,
    required this.city,
    required this.phone,
    this.uid,
    this.plan,
    this.limit,
    this.entries,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      email1: json['email1'] as String? ?? json['email'] as String? ?? '',
      city: json['City'] as String? ?? json['city'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      uid: json['uid'] as String?,
      plan: json['plan'] as String?,
      limit: json['limit'] as String?,
      entries: json['entries'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email1': email1,
      'City': city,
      'phone': phone,
      'uid': uid,
      'plan': plan,
      'limit': limit,
      'entries': entries,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email1,
    String? city,
    String? phone,
    String? uid,
    String? plan,
    String? limit,
    String? entries,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email1: email1 ?? this.email1,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      uid: uid ?? this.uid,
      plan: plan ?? this.plan,
      limit: limit ?? this.limit,
      entries: entries ?? this.entries,
    );
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String? ?? '',
      user: User.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
    );
  }
}
