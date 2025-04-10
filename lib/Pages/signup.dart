import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // تخصيص الرسالة عند حدوث الخطأ
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // تخصيص الرسالة عند نجاح التسجيل
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print("User registered with UID: ${userCredential.user!.uid}");

        // بيانات المستخدم
        Map<String, String> userData = {
          "first_name": _firstNameController.text.trim(),
          "last_name": _lastNameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _phoneController.text.trim(),
          "role": "Client",
        };

        print("Data to be added: $userData");

        // إضافة البيانات إلى Firestore
        await _firestore
            .collection("users")
            .doc(userCredential.user!.uid)
            .set(userData)
            .then((_) {
          print("User data added to Firestore");
          _showSuccess("Registration successful! Please log in.");

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }).catchError((error) {
          print("Failed to add user data to Firestore: $error");
          _showError("Failed to add user data. Please try again.");
        });
      } catch (e) {
        String errorMessage;

        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = "This email is already in use.";
              break;
            case 'weak-password':
              errorMessage = "The password is too weak.";
              break;
            case 'invalid-email':
              errorMessage = "The email is invalid.";
              break;
            default:
              errorMessage = "An error occurred. Please try again.";
          }
        } else {
          errorMessage = "An unexpected error occurred. Please try again.";
        }

        _showError(errorMessage);
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
            decoration: const BoxDecoration(
              color: Color(0xFFF9EAE6),
            ),
            child: Stack(
              children: [
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
                      'assets/MM.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 350,
                    ),
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
                              color: Colors.grey.withOpacity(0.2),
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
                                      color: const Color.fromARGB(
                                          255, 196, 193, 193),
                                      width: 1),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                padding: const EdgeInsets.all(1),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, "/login");
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: const Text(
                                            "Sign In",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, "/signup");
                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF6B7DAF),
                                            borderRadius:
                                                BorderRadius.circular(40),
                                          ),
                                          child: const Text(
                                            "Sign Up",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                    labelText: "First Name"),
                                validator: (value) => value!.isEmpty
                                    ? "Enter your first name"
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                    labelText: "Last Name"),
                                validator: (value) => value!.isEmpty
                                    ? "Enter your last name"
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                    labelText: "Enter email"),
                                validator: (value) =>
                                    value!.isEmpty || !value.contains("@")
                                        ? "Enter a valid email"
                                        : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: "Enter phone number",
                                  hintText: "5XXXXXXXX",
                                  prefixText: "+966 ",
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your phone number";
                                  } else if (!value.startsWith("5")) {
                                    return "Phone number must start with 5";
                                  } else if (value.length != 9) {
                                    return "Phone number must be exactly 9 digits after country code";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: "Password"),
                                validator: (value) => value!.length < 6
                                    ? "Password must be at least 6 characters"
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                    labelText: "Confirm Password"),
                                validator: (value) =>
                                    value != _passwordController.text
                                        ? "Passwords do not match"
                                        : null,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _signUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6B7DAF),
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                                child: const Text("Sign Up",
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
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

// import 'package:flutter/material.dart';

// class Signup extends StatelessWidget {
//   const Signup({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: false, // تثبيت العناصر عند ظهور لوحة المفاتيح
//       body: SafeArea(
//         child: Container(
//           width: double.infinity,
//           decoration: const BoxDecoration(
//             color: Color(0xFFF9EAE6), // لون الخلفية البيج
//           ),
//           child: Stack(
//             children: [
//               // الصورة في الخلفية
//               Container(
//                 width: double.infinity,
//                 decoration: const BoxDecoration(
//                   color: Color(0xFFF9EAE6),
//                   borderRadius: BorderRadius.only(
//                     bottomRight: Radius.elliptical(100, 80),
//                   ),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 0),
//                   child: Image.asset(
//                     'assets/MM.png', // ضع مسار الصورة هنا
//                     fit: BoxFit.cover,
//                     width: double.infinity,
//                     height: 350, // ارتفاع الصورة
//                   ),
//                 ),
//               ),
//               // منطقة تسجيل الدخول
//               Align(
//                 alignment: Alignment.bottomCenter,
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                       top: 263), // ضبط المحاذاة فوق الصورة
//                   child: Center(
//                     child: Container(
//                       width: 300,
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.withOpacity(0.2),
//                             blurRadius: 10,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         mainAxisSize:
//                             MainAxisSize.min, // يمنع تمدد العمود أكثر من اللازم
//                         children: [
//                           // التبديل بين "Sign In" و "Sign Up"
//                           Container(
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                   color:
//                                       const Color.fromARGB(255, 196, 193, 193),
//                                   width: 1),
//                               borderRadius: BorderRadius.circular(40),
//                             ),
//                             padding: const EdgeInsets.all(1),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.pushNamed(context, "/login");
//                                     },
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 10),
//                                       child: const Text(
//                                         "Sign In",
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: GestureDetector(
//                                     onTap: () {
//                                       Navigator.pushNamed(context, "/signup");
//                                     },
//                                     child: Container(
//                                       alignment: Alignment.center,
//                                       padding: const EdgeInsets.symmetric(
//                                           vertical: 10),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFF6B7DAF),
//                                         borderRadius: BorderRadius.circular(40),
//                                       ),
//                                       child: const Text(
//                                         "Sign Up",
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           // حقل الاسم الأول
//                           const TextField(
//                             decoration: InputDecoration(
//                               labelText: "First Name",
//                               border: UnderlineInputBorder(),
//                               labelStyle: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           // حقل الاسم الأخير
//                           const TextField(
//                             decoration: InputDecoration(
//                               labelText: "Last Name",
//                               border: UnderlineInputBorder(),
//                               labelStyle: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           // حقل البريد الإلكتروني
//                           const TextField(
//                             decoration: InputDecoration(
//                               labelText: "Enter email",
//                               border: UnderlineInputBorder(),
//                               labelStyle: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           // حقل كلمة المرور
//                           const TextField(
//                             obscureText: true,
//                             decoration: InputDecoration(
//                               labelText: "Password",
//                               border: UnderlineInputBorder(),
//                               labelStyle: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           const SizedBox(height: 15),
//                           // حقل تأكيد كلمة المرور
//                           const TextField(
//                             obscureText: true,
//                             decoration: InputDecoration(
//                               labelText: "Confirm Password",
//                               border: UnderlineInputBorder(),
//                               labelStyle: TextStyle(color: Colors.grey),
//                             ),
//                           ),
//                           const SizedBox(height: 20),
//                           // زر تسجيل
//                           ElevatedButton(
//                             onPressed: () {
//                               Navigator.popAndPushNamed(context, '/Welcome');
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF6B7DAF),
//                               minimumSize: const Size(double.infinity, 50),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(40),
//                               ),
//                             ),
//                             child: const Text(
//                               "Sign Up",
//                               style:
//                                   TextStyle(fontSize: 18, color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Signup extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView(
//         padding: EdgeInsets.all(16.0),
//         children: <Widget>[
//           SizedBox(height: 80),
//           // logo
//           Column(
//             children: [
//               FlutterLogo(
//                 size: 55,
//               ),
//             ],
//           ),
//           SizedBox(height: 50),
//           Text(
//             'Welcome!',
//             style: TextStyle(fontSize: 24),
//           ),

//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SignupForm(),
//           ),

//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: <Widget>[
//                 Row(
//                   children: <Widget>[
//                     Text('Already here  ?',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 20)),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(' Get Logged in Now!',
//                           style: TextStyle(fontSize: 20, color: Colors.blue)),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Container buildLogo() {
//     return Container(
//       height: 80,
//       width: 80,
//       decoration: BoxDecoration(
//           borderRadius: BorderRadius.all(Radius.circular(10)),
//           color: Colors.blue),
//       child: Center(
//         child: Text(
//           "T",
//           style: TextStyle(color: Colors.white, fontSize: 60.0),
//         ),
//       ),
//     );
//   }
// }

// class SignupForm extends StatefulWidget {
//   SignupForm({Key? key}) : super(key: key);

//   @override
//   _SignupFormState createState() => _SignupFormState();
// }

// class _SignupFormState extends State<SignupForm> {
//   final _formKey = GlobalKey<FormState>();

//   String? email;
//   String? password;
//   String? name;
//   bool _obscureText = false;

//   bool agree = false;

//   final pass = new TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     var border = OutlineInputBorder(
//       borderRadius: BorderRadius.all(
//         const Radius.circular(100.0),
//       ),
//     );

//     var space = SizedBox(height: 10);
//     return Form(
//       key: _formKey,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           // email
//           TextFormField(
//             decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.email_outlined),
//                 labelText: 'Email',
//                 border: border),
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter some text';
//               }
//               return null;
//             },
//             onSaved: (val) {
//               email = val;
//             },
//             keyboardType: TextInputType.emailAddress,
//           ),

//           space,

//           // password
//           TextFormField(
//             controller: pass,
//             decoration: InputDecoration(
//               labelText: 'Password',
//               prefixIcon: Icon(Icons.lock_outline),
//               border: border,
//               suffixIcon: GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     _obscureText = !_obscureText;
//                   });
//                 },
//                 child: Icon(
//                   _obscureText ? Icons.visibility_off : Icons.visibility,
//                 ),
//               ),
//             ),
//             onSaved: (val) {
//               password = val;
//             },
//             obscureText: !_obscureText,
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter some text';
//               }
//               return null;
//             },
//           ),
//           space,
//           // confirm passwords
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: 'Confirm Password',
//               prefixIcon: Icon(Icons.lock_outline),
//               border: border,
//             ),
//             obscureText: true,
//             validator: (value) {
//               if (value != pass.text) {
//                 return 'password not match';
//               }
//               return null;
//             },
//           ),
//           space,
//           // name
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: 'Full name',
//               prefixIcon: Icon(Icons.account_circle),
//               border: border,
//             ),
//             onSaved: (val) {
//               name = val;
//             },
//             validator: (value) {
//               if (value!.isEmpty) {
//                 return 'Please enter some name';
//               }
//               return null;
//             },
//           ),

//           Row(
//             children: <Widget>[
//               Checkbox(
//                 onChanged: (_) {
//                   setState(() {
//                     agree = !agree;
//                   });
//                 },
//                 value: agree,
//               ),
//               Flexible(
//                 child: Text(
//                     'By creating account, I agree to Terms & Conditions and Privacy Policy.'),
//               ),
//             ],
//           ),
//           SizedBox(
//             height: 10,
//           ),

//           // signUP button
//           SizedBox(
//             height: 50,
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   _formKey.currentState!.save();

//                   AuthenticationHelper()
//                       .signUp(email: email!, password: password!)
//                       .then((result) {
//                     if (result == null) {
//                       Navigator.pushReplacement(context,
//                           MaterialPageRoute(builder: (context) => Home()));
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                         content: Text(
//                           result,
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ));
//                     }
//                   });
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(24.0)))),
//               child: Text('Sign Up'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
