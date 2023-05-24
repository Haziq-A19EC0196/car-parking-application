import 'dart:core';

class UserModel {
  String userId;
  final String name;
  final String email;
  final String phone;
  bool inside;

  UserModel({
    this.userId = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.inside,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'phone': phone,
    'email': email,
    'inside': inside,
  };

  static UserModel fromJson(Map<String, dynamic> data) => UserModel(
    name: data['name'],
    phone: data['phone'],
    email: data['email'],
    inside: data['inside'],
  );
}