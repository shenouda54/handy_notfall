import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'features/auth/presentation/login/login.dart';
import 'features/presentation/pages/customer_screen.dart';
import 'features/splash/presentation/splash_screen.dart';
import 'data/error_widget.dart';

import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Forward Flutter framework errors to this zone
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (details.stack != null) {
        Zone.current.handleUncaughtError(details.exception, details.stack!);
      }
    };

    // Friendly error UI for uncaught build errors
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return CustomErrorWidget(
        errorMessage: details.exceptionAsString(),
        onRetry: () {
          runApp(const MyApp());
        },
      );
    };

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Enable offline persistence for Firestore to reduce startup failures
      FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
      // ignore: avoid_print
      print("✅ Firebase initialized successfully");
    } catch (e) {
      // ignore: avoid_print
      print("❌ Firebase initialization failed: $e");
    }

    runApp(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    // ignore: avoid_print
    print('❌ Uncaught error: $error');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Handy Notfall',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthGate(),
        );
      },
    );
  }
}

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
          return const SplashScreen();
        }
        if (snapshot.hasData) {
          return const CustomerScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
