import 'package:flutter/material.dart';
import '../logic/splash_logic.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashLogic _logic = SplashLogic();

  @override
  void initState() {
    super.initState();
    _logic.handleNavigation(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_handynotfall-white.webp',
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            const SizedBox(height: 20.0),
            const Text(
              'HandyNotfall',
              style: TextStyle(
                color: Color(0xFFE53935),
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
