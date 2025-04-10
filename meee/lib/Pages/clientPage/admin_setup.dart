import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupPage extends StatelessWidget {
  const AdminSetupPage({super.key});

  Future<void> setupFakeData(BuildContext context) async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    try {
      // إنشاء مستخدم
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: 'mnzar7161@gmail.com',
        password: 'moode774',
      );
      final userId = userCredential.user!.uid;

      await firestore.collection('users').doc(userId).set({
        "first_name": "منذر",
        "last_name": "تجريبي",
        "email": 'mnzar7162@gmail.com',
        "phone": '512345678',
        "role": "Client",
      });

      // بطاقة دفع
      await firestore.collection('users').doc(userId).collection('payment_cards').add({
        "cardName": "Test Visa",
        "cardNumber": "1234567890123456",
        "expiry": "12/26",
        "timestamp": FieldValue.serverTimestamp(),
      });

      // متاجر
      final store1 = await firestore.collection('facility').add({
        "name": "قهوة بنوة",
        "image": "https://picsum.photos/200?random=1",
        "rating": "4.8",
        "ratingsCount": 23,
      });

      final store2 = await firestore.collection('facility').add({
        "name": "قهوة المزاج",
        "image": "https://picsum.photos/200?random=2",
        "rating": "4.5",
        "ratingsCount": 12,
      });

      // منتجات
      await firestore.collection('Products').add({
        "productName": "اسبريسو",
        "price": 12,
        "calories": "50",
        "category": "Hot Drinks",
        "imageUrl": "https://picsum.photos/seed/coffee1/200/300",
        "storeId": store1.id,
      });

      await firestore.collection('Products').add({
        "productName": "كابتشينو",
        "price": 15,
        "calories": "80",
        "category": "Hot Drinks",
        "imageUrl": "https://picsum.photos/seed/coffee2/200/300",
        "storeId": store2.id,
      });

      // باقات وهمية
      for (int i = 1; i <= 4; i++) {
        await firestore.collection('packages').add({
          "name": "باقة رقم $i",
          "price": 10 * i,
          "details": "تفاصيل باقة $i",
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ تم إنشاء البيانات الوهمية بنجاح")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ خطأ: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Setup")),
      body: Center(
        child: ElevatedButton(
          child: const Text("إنشاء بيانات وهمية"),
          onPressed: () => setupFakeData(context),
        ),
      ),
    );
  }
}
