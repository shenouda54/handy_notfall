import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/firebase_options.dart';
import 'package:handy_notfall/screens/splash_screen.dart';

void main()async{
WidgetsFlutterBinding.ensureInitialized(); // لو مش موجود السطر دا هيجري علي run app علطول
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}