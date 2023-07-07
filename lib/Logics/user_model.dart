import 'dart:core';

class UserModel {
  String userId;
  final String name;
  final String email;
  final String phone;
  List parkingRef;
  bool inside;
  double balance;
  bool isAdmin;

  UserModel({
    this.userId = '',
    required this.name,
    required this.email,
    required this.phone,
    required this.parkingRef,
    required this.inside,
    required this.balance,
    required this.isAdmin,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'parkingEntryRef': parkingRef,
    'inside': inside,
    'balance': balance,
    'isAdmin': isAdmin,
  };

  static UserModel fromJson(Map<String, dynamic> data) => UserModel(
    name: data['name'],
    email: data['email'],
    phone: data['phone'],
    parkingRef: data['parkingEntryRef'],
    inside: data['inside'],
    balance: data['balance'].toDouble(),
    isAdmin: data['isAdmin'],
  );
}