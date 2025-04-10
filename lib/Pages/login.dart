import 'package:flutter/material.dart';
import 'package:uni_bite/Pages/auth_service.dart';
import 'package:uni_bite/Pages/home.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EAE6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // الصورة العلوية
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF9EAE6),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.elliptical(100, 80),
                  ),
                ),
                child: Image.asset(
                  'assets/MM.png',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 350,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Container(
                    width: 314,
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
                      children: [
                        // شريط التنقل بين تسجيل الدخول والتسجيل
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey, width: 1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          padding: const EdgeInsets.all(1),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, "/login");
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF6B7DAF),
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: const Text(
                                      "Sign In",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, "/signup");
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: const Text(
                                      "Sign Up",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),

                        // حقل البريد الإلكتروني
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Enter email",
                            border: UnderlineInputBorder(),
                            labelStyle: TextStyle(color: Colors.grey),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            email = val;
                          },
                        ),
                        const SizedBox(height: 10),

                        // حقل كلمة المرور
                        TextFormField(
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: "Password",
                            border: const UnderlineInputBorder(),
                            labelStyle: const TextStyle(color: Colors.grey),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              child: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          onSaved: (val) {
                            password = val;
                          },
                        ),
                        const SizedBox(height: 10),

                        // زر "نسيت كلمة المرور؟"
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                  context, "/ForgotPasswordPage");
                            },
                            child: const Text(
                              "Forgot Password?",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // زر تسجيل الدخول
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();
                              AuthenticationHelper()
                                  .signIn(email: email!, password: password!)
                                  .then((result) {
                                if (result == null) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(result,
                                          style: const TextStyle(fontSize: 16)),
                                    ),
                                  );
                                }
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6B7DAF),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // أو تسجيل الدخول عبر جوجل أو أبل
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () async {
                                // استدعاء الدالة الخاصة بتسجيل الدخول عبر Google
                                final result = await AuthenticationHelper()
                                    .signInWithGoogle();
                                if (result == null) {
                                  // إذا كانت النتيجة فارغة، سيتم نقل المستخدم إلى الصفحة الرئيسية
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Home()),
                                  );
                                } else {
                                  // إذا كانت هناك مشكلة، عرض رسالة خطأ
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(result,
                                            style: TextStyle(fontSize: 16))),
                                  );
                                }
                              },
                              icon: Image.asset('assets/google.png',
                                  width: 30, height: 30),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              onPressed: () {
                                // هنا يمكنك إضافة الدالة الخاصة بتسجيل الدخول عبر Apple إذا كنت تريد
                              },
                              icon: Image.asset('assets/apple.png',
                                  width: 30, height: 30),
                            ),
                          ],
                        ),
                      ],
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
