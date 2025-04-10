import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FacilitySignup extends StatefulWidget {
  const FacilitySignup({super.key});

  @override
  _FacilitySignupState createState() => _FacilitySignupState();
}

class _FacilitySignupState extends State<FacilitySignup> {
  // المتحكمات للحقول
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // دالة تسجيل منشأة جديدة باستخدام Firebase
  Future<void> signUp() async {
    setState(() {
      isLoading = true;
    });

    try {
      // إنشاء حساب جديد باستخدام Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // حفظ بيانات المنشأة في Firestore
      await FirebaseFirestore.instance.collection("facilities").doc(userCredential.user!.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "created_at": Timestamp.now(),
      });

      // إذا نجح التسجيل، انتقل إلى FacilityHome
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          "/Facilityhome",
          arguments: {'facilityId': userCredential.user!.uid},
        );
      }
    } on FirebaseAuthException catch (e) {
      // التعامل مع الأخطاء
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2A3E5F)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Facility Sign Up",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3E5F),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Create a new facility account",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // حقل اسم المنشأة
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Facility Name",
                  prefixIcon: Icon(Icons.store, color: Color(0xFF2A3E5F)),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // حقل البريد الإلكتروني
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email, color: Color(0xFF2A3E5F)),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              // حقل كلمة المرور
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock, color: Color(0xFF2A3E5F)),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              // زر التسجيل
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          if (nameController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              passwordController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill in all fields"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          signUp();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7DAF),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              // رابط للذهاب إلى صفحة تسجيل الدخول
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, "/Facilitylogin");
                  },
                  child: const Text(
                    "Already have an account? Sign in",
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
    );
  }
}