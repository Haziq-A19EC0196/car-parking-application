import 'package:flutter/material.dart';

TextField customTextField(String text, IconData icon, bool isPassword, TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      hintText: text,
      prefixIcon: Icon(icon)
    ),
  );
}