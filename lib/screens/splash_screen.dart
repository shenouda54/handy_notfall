
import 'package:flutter/material.dart';

import 'data_of_custmer_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // تأخير لمدة 4 ثوانٍ قبل الانتقال إلى CustomerScreen
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CustomerScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // خلفية سوداء
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo_handynotfall-white.webp', // شعار التطبيق
              width: MediaQuery.of(context).size.width * 0.6, // عرض الصورة
            ),
            const SizedBox(height: 20.0),
            Text(
              'HandyNotfall',
              style: TextStyle(
                color: Color(0xFFE53935), // الأحمر للعناوين الكبيرة
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ), // النص بالأحمر الكبير
            ),
          ],
        ),
      ),
    );
  }
}