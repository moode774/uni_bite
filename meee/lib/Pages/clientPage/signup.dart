import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  SignupState createState() => SignupState();
}

class SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLogin = true;

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        _showSuccess("Signed in successfully!");
        Navigator.pushReplacementNamed(context, '/stores');
      } on FirebaseAuthException catch (e, st) {
        debugPrint("SignIn FirebaseAuthException");
        debugPrint("code: ${e.code}");
        debugPrint("message: ${e.message}");
        debugPrint("exception: $e");
        debugPrint("stackTrace: $st");
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = "No account found with this email.";
            break;
          case 'wrong-password':
            errorMessage = "Incorrect password.";
            break;
          default:
            errorMessage = "Error: ${e.code}. Please try again.";
        }
        _showError(errorMessage);
      } catch (e, st) {
        debugPrint("SignIn Error: $e");
        debugPrint("stackTrace: $st");
        _showError("Unexpected error: $e");
      }
    }
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        final userData = {
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "role": "Client",
        };
        await _firestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(userData)
            .then((_) {
          _showSuccess("Account created successfully!");
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/stores');
          });
        }).catchError((error, st) {
          debugPrint("Firestore Error: $error");
          debugPrint("stackTrace: $st");
          _showError("Failed to save user data.");
        });
      } on FirebaseAuthException catch (e, st) {
        debugPrint("SignUp FirebaseAuthException");
        debugPrint("code: ${e.code}");
        debugPrint("message: ${e.message}");
        debugPrint("exception: $e");
        debugPrint("stackTrace: $st");
        String errorMessage;
        switch (e.code) {
          case 'email-already-in-use':
            errorMessage = "This email is already in use.";
            break;
          case 'weak-password':
            errorMessage = "Password is too weak.";
            break;
          case 'invalid-email':
            errorMessage = "Invalid email address.";
            break;
          default:
            errorMessage = "Error: ${e.code}. Please try again.";
        }
        _showError(errorMessage);
      } catch (e, st) {
        debugPrint("SignUp Error: $e");
        debugPrint("stackTrace: $st");
        _showError("Unexpected error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF9EAE6),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 350,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9EAE6),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.elliptical(100, 80),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(Icons.person, size: 80),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 263),
                    child: Center(
                      child: Container(
                        width: 300,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 10,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 196, 193, 193),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                padding: const EdgeInsets.all(1),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isLogin = true),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _isLogin
                                                ? const Color(0xFF6B7DAF)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(40),
                                          ),
                                          child: Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: _isLogin ? Colors.white : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => setState(() => _isLogin = false),
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: !_isLogin
                                                ? const Color(0xFF6B7DAF)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(40),
                                          ),
                                          child: Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: !_isLogin ? Colors.white : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (!_isLogin) ...[
                                TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(labelText: "First Name"),
                                  validator: (value) =>
                                      value!.isEmpty ? "Enter your first name" : null,
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(labelText: "Last Name"),
                                  validator: (value) =>
                                      value!.isEmpty ? "Enter your last name" : null,
                                ),
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                    labelText: "Phone Number",
                                    hintText: "5XXXXXXXX",
                                    prefixText: "+966 ",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter your phone number";
                                    } else if (!value.startsWith("5")) {
                                      return "Phone number must start with 5";
                                    } else if (value.length != 9) {
                                      return "Must be 9 digits after country code";
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                              ],
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: "Email"),
                                validator: (value) => value!.isEmpty || !value.contains("@")
                                    ? "Enter a valid email"
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: "Password"),
                                validator: (value) => value!.length < 6
                                    ? "Password must be at least 6 characters"
                                    : null,
                              ),
                              if (!_isLogin) ...[
                                const SizedBox(height: 15),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(labelText: "Confirm Password"),
                                  validator: (value) => value != _passwordController.text
                                      ? "Passwords do not match"
                                      : null,
                                ),
                              ],
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _isLogin ? _signIn : _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF6B7DAF),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: Text(
                                  _isLogin ? "Sign In" : "Sign Up",
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

