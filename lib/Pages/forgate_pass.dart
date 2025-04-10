import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> resetPassword() async {
    // إزالة المسافات الزائدة من نص الإيميل
    final String email = emailController.text.trim();

    // التحقق من كون الحقل فارغًا
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter your email address."),
          backgroundColor: Colors.red,
        ),
      );
      return; // الخروج من الدالة في حال كان الحقل فارغًا
    }

    // التحقق من صحة الإيميل باستخدام تعبير منتظم
    if (!RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid email address."),
          backgroundColor: Colors.red,
        ),
      );
      return; // الخروج من الدالة في حال عدم تطابق صيغة الإيميل
    }

    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // في حال نجاح العملية، يتم عرض AlertDialog للنجاح
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Success"),
          content: const Text("A reset link has been sent to your email."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(context); // الرجوع إلى صفحة تسجيل الدخول
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (e) {
      // التحقق من حالة عدم وجود المستخدم
      String errorMessage;
      if (e.code == "user-not-found") {
        errorMessage = "No account found with this email.";
      } else {
        errorMessage = "Error: ${e.message}";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      // التقاط أية أخطاء عامة أخرى
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("An error occurred. Please try again later."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // محتوى الصفحة
          SafeArea(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF9EAE6), // لون الخلفية البيج
              ),
              child: Stack(
                children: [
                  // الصورة في الخلفية
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9EAE6),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.elliptical(100, 80),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      child: Image.asset(
                        'assets/MM.png', // ضع مسار الصورة هنا
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 350, // ارتفاع الصورة
                      ),
                    ),
                  ),
                  // منطقة نسيت كلمة المرور
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 140), // ضبط المحاذاة فوق الصورة
                      child: Center(
                        child: Container(
                          width: 314,
                          height: 300,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Forgot Password",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6B7DAF),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // حقل البريد الإلكتروني
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: "Enter your email",
                                  border: UnderlineInputBorder(),
                                  labelStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // زر الإرسال
                              ElevatedButton(
                                onPressed: isLoading ? null : resetPassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B7DAF),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: const Text(
                                  "Send Reset Link",
                                  style: TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // زر العودة لتسجيل الدخول
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // الرجوع إلى صفحة تسجيل الدخول
                                  },
                                  child: const Text(
                                    "Back to Sign In",
                                    style: TextStyle(
                                      color: Color(0xFF6B7DAF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // مؤشر التحميل الشفاف
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
