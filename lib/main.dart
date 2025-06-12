import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import 'features/auth/presentation/login/login.dart';
import 'features/presentation/pages/customer_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _showSplash) {
          return const SplashScreen(); // ✅ عرض Splash مؤقتًا
        }
        if (snapshot.hasData) {
          return const CustomerScreen(); // ✅ بعد السبلاتش يروح هنا
        }
        return const LoginScreen(); // ❌ مش مسجل دخول
      },
    );
  }
}
