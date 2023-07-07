import 'dart:async';

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

Text homeScreenText(String text) {
  return Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
  );
}

class MenuButton extends StatelessWidget {
  final Icon icon;
  final String text;
  final dynamic route;
  const MenuButton({super.key, required this.icon, required this.text, required this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        width: MediaQuery.of(context).size.height * 0.175,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade500),
            color: Colors.white38
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: route));
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 20,
                  child: icon,
                ),
                Positioned(
                  bottom: 10,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}