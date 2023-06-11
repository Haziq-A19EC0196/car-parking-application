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
        height: 75,
        width: MediaQuery.of(context).size.height * 0.175,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.lightBlueAccent.shade100,
        ),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: route));
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                top: 25,
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
    );
  }
}

class ParkTimer extends StatefulWidget {
  // DateTime dateTime;
  const ParkTimer({Key? key}) : super(key: key);

  @override
  State<ParkTimer> createState() => _ParkTimerState();
}

class _ParkTimerState extends State<ParkTimer> {
  int time = 1;

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        time++;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          time.toString()
        ),
        RawMaterialButton(
          onPressed: startTimer,
        ),
      ],
    );
  }
}
