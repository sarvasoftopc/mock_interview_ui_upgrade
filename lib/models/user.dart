import 'dart:convert';

class User {
  final String id;
  final String name;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'] as String, name: json['name'] as String, token: json['token'] as String);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'token': token};

  @override
  String toString() => jsonEncode(toJson());
}
