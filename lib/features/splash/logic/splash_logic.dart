import 'package:flutter/material.dart';

import '../../presentation/pages/customer_screen.dart';

class SplashLogic {
  void handleNavigation(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerScreen(),
        ),
      );
    });
  }
}
