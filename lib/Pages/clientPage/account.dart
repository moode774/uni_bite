import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uni_bite/Pages/clientPage/profile.dart';
import 'package:uni_bite/Pages/login.dart';
import 'package:uni_bite/Pages/clientPage/ChangePasswordPage.dart';  // إضافة صفحة تغيير كلمة المرور
import 'package:uni_bite/localization/app_localizations.dart'; 

// صفحة إعدادات الحساب
class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F0),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2A3E5F)),
          onPressed: () {
            Navigator.pop(context); // العودة إلى الصفحة السابقة
          },
        ),
        title: Text(
          AppLocalizations.of(context).translate("account_settings"), // عنوان الصفحة
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3E5F),
          ),
        ),
      ),
      body: const AccountSettingsScreen(), // عرض محتوى إعدادات الحساب
    );
  }
}

// صفحة إعدادات الحساب (الشاشة)
class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  // تعريف المتحكمات لتخزين البيانات المدخلة
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController(); // حقل الهاتف
  bool isLoading = true; // متغير للتحكم في حالة التحميل
// دالة التحقق من صحة رقم الهاتف
bool _validatePhoneNumber(String phone) {
  final RegExp regex = RegExp(r'^5\d{8}$'); // الرقم يبدأ بـ 5 ويكون 9 أرقام
  return regex.hasMatch(phone);
}
  // المتغيرات الأخرى
  File? _selectedImage;

  // دالة اختيار الصورة
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // دالة لإظهار خيارات اختيار الصورة
  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context).translate("take_photo")),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context).translate("choose_from_gallery")),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchClientData(); // جلب بيانات العميل عند تحميل الصفحة
  }

  User? user = FirebaseAuth.instance.currentUser;

  // دالة لجلب بيانات العميل من Firebase
  void fetchClientData() async {
    final doc = await FirebaseFirestore.instance
        .collection("users") // تغيير الكوليكشن إلى "Clients"
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        // تعبئة الحقول بالبيانات المسحوبة من Firebase
        firstNameController.text = doc["first_name"];
        lastNameController.text = doc["last_name"];
        emailController.text = doc["email"];
        phoneController.text = doc["phone"] ?? ''; // جلب الهاتف
        isLoading = false; // إنهاء التحميل
      });
    } else {
      setState(() {
        isLoading = false; // إنهاء التحميل حتى لو لم توجد بيانات
      });
    }
  }

  // دالة لتحديث بيانات العميل في Firebase
  void updateClientData() async {
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).update({
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "email": emailController.text,
      "phone": phoneController.text, // حفظ رقم الهاتف
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context).translate("changes_saved")),
            backgroundColor: Colors.green),
      );
    }
  }

  // دالة لحذف البيانات من جميع الكوليكشن المرتبطة بالـ UID
void deleteClient() async {
  final confirmation = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context).translate("confirm_deletion")),
        content: Text(AppLocalizations.of(context).translate("delete_account_confirmation")),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false); // إلغاء الحذف
            },
            child: Text(AppLocalizations.of(context).translate("cancel")),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true); // تأكيد الحذف
            },
            child: Text(AppLocalizations.of(context).translate("delete")),
          ),
        ],
      );
    },
  );

  if (confirmation == true) {
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).delete();

    await FirebaseFirestore.instance.collection("orders").where("user_id", isEqualTo: user!.uid).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await FirebaseFirestore.instance.collection("favorites").where("user_id", isEqualTo: user!.uid).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    await FirebaseAuth.instance.currentUser!.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate("account_deleted")),
        backgroundColor: Colors.red,
      ),
    );

    // العودة إلى صفحة تسجيل الدخول بعد الحذف
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginForm()),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (isLoading)
          Center(child: CircularProgressIndicator())
        else
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : AssetImage('assets/vcc.png') as ImageProvider,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _showImageSourceActionSheet(context),
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFF2A3E5F),
                              child: Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate("first_name"),
                      suffixIcon: const Icon(Icons.edit, color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate("last_name"),
                      suffixIcon: const Icon(Icons.edit, color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // حقل البريد الإلكتروني
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context).translate("email"),
                      suffixIcon: const Icon(Icons.edit, color: Colors.grey),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                TextFormField(
  controller: phoneController,
  decoration: InputDecoration(
    labelText: AppLocalizations.of(context).translate("phone_number"),
    prefixText: '+966 ',
    hintText: '5****',
    suffixIcon: const Icon(Icons.edit, color: Colors.grey),
    border: OutlineInputBorder(),
    errorText: _validatePhoneNumber(phoneController.text) ? null : AppLocalizations.of(context).translate("phone_validation_error"), // التحقق من الرقم
  ),
  keyboardType: TextInputType.phone,
  onChanged: (value) {
    setState(() {});
  },
),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChangePasswordPage()), 
                      );
                    },
                    child: Text(
                      AppLocalizations.of(context).translate("change_password"),
                      style: const TextStyle(
                        color: Color(0xFF6B7DAF),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Column(
                    children: [
                      ElevatedButton(
                    onPressed: () {
  if (firstNameController.text.isEmpty ||
      lastNameController.text.isEmpty ||
      emailController.text.isEmpty ||
      phoneController.text.isEmpty ||
      !_validatePhoneNumber(phoneController.text)) {  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).translate("enter_fields_correctly")),  
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    updateClientData();
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(AppLocalizations.of(context).translate("changes_saved")),
      backgroundColor: Colors.green,
    ),
  );

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => ProfilePage()),
  );
                    },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B7DAF),
                          padding: const EdgeInsets.symmetric(horizontal: 123, vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate("save_account"),
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10), // مسافة موحدة بين الزرين
                      ElevatedButton(
                        onPressed: deleteClient, // زر حذف الحساب
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(horizontal: 120, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context).translate("delete_account"),
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}