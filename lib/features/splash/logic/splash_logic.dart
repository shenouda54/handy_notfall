import 'package:flutter/material.dart';
import '../../presentation/pages/customer_screen.dart';

class SplashLogic {
  void handleNavigation(State state) {
    Future.delayed(const Duration(seconds: 3), () {
      if (!state.mounted) return;
      Navigator.pushReplacement(
        state.context,
        MaterialPageRoute(
          builder: (_) => const CustomerScreen(),
        ),
      );
    });
  }
}
