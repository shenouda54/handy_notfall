import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:handy_notfall/firebase_options.dart';
import 'package:handy_notfall/login/login.dart';
import 'package:handy_notfall/screens/data_of_custmer_screen.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // لو مش موجود السطر دا هيجري علي run app علطول
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ); // شاشة تحميل أثناء التحقق من حالة المستخدم
          }
          if (snapshot.hasData) {
            return const CustomerScreen(); // المستخدم مسجل دخول
          }
          return const LoginScreen(); // المستخدم غير مسجل دخول
        },
      ),
    );
  }
}


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: FirebaseAuth.instance.currentUser == null
//           ? const LoginScreen()
//           : const CustomerScreen(),
//     );
//   }
// }
