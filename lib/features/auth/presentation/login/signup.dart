import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../presentation/pages/customer_screen.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  void _register() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      // 🔍 تحقق مما إذا كان الإيميل مسجلًا بالفعل
      List<String> signInMethods = await FirebaseAuth.instance
          .fetchSignInMethodsForEmail(emailController.text.trim());

      if (signInMethods.isNotEmpty) {
        // ✖ الإيميل مسجل بالفعل
        setState(() {
          isLoading = false;
          errorMessage =
              'Diese E-Mail-Adresse ist bereits registriert. '; //هذا البريد الإلكتروني مسجل مسبقًا.
        });
        return;
      }

      // ✅ إنشاء الحساب إذا لم يكن الإيميل مسجلًا
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 🎉 تم التسجيل بنجاح → الانتقال إلى `CustomerScreen`
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CustomerScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = '❌Fehler: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Erstelle ein neues Konto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Passwort '),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Erstelle ein neues Konto'),
                  ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                  'Hast du bereits ein Konto? Anmelden'), //لديك حساب بالفعل؟ تسجيل الدخول
            ),
          ],
        ),
      ),
    );
  }
}
