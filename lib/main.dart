
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import 'Screens/login_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Firebase
  await Firebase.initializeApp();

  // Init Stripe
  Stripe.publishableKey = 'pk_test_51NBDk2IAWGSq2YIwvrcq6RO4r9JfJX7RQABdteHusr2RrYFuLtqJS2R7jhL26rtDMjuk5HE18FXULKnXktRoXbXt00qXzdpI5o';
  await Stripe.instance.applySettings();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return const MaterialApp(
      // theme: ThemeData(primarySwatch: Colors.purple),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool authenticated = false;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: LoginPage(),
    );
  }
}