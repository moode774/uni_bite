import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // إضافة استيراد Firebase Auth

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    // تأخير لعرض شاشة البداية ثم التحقق من تسجيل الدخول
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        checkUserLoggedIn();
      }
    });
  }

  void checkUserLoggedIn() {
    // التحقق مما إذا كان المستخدم مسجل دخوله
    User? user = FirebaseAuth.instance.currentUser;
    
    if (user != null) {
      // إذا كان المستخدم مسجل دخوله، انتقل إلى الشاشة الرئيسية
      Navigator.pushReplacementNamed(context, "/home");
    } else {
      // إذا لم يكن المستخدم مسجل دخوله، انتقل إلى شاشة الترحيب
      Navigator.pushReplacementNamed(context, "/Welcome");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // يمكنك إضافة شعار التطبيق هنا
            Image.asset(
              'assets/misschef_logo.png', // استبدل هذا بمسار الشعار الخاص بك
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              "Uni Bite",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A3E5F),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6B7DAF)),
            ),
          ],
        ),
      ),
    );
  }
}