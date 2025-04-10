// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'pages/clientPage/all_stores_page.dart';
import 'pages/clientPage/admin_setup.dart';
import 'pages/clientPage/signup.dart';
import 'pages/clientPage/shopping_cart_page.dart';
import 'pages/clientPage/add_payment_card_page.dart';
import 'pages/clientPage/payment_methods_page.dart';
import 'pages/clientPage/order_edit_timer_page.dart';
import 'pages/clientPage/order.dart';
import 'pages/clientPage/rating_feedback_page.dart';
import 'pages/clientPage/menu_shop_page.dart';
import 'pages/clientPage/product_detail_page.dart';
import 'pages/clientPage/order_tracking_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Ordering App',
      debugShowCheckedModeBanner: false,

      // لتشغيل الإعداد أول مرة فقط، غير الصفحة الرئيسية مؤقتاً:
      // home: const AdminSetupPage(),
      home: const Signup(),

      routes: {
        '/admin': (context) => const AdminSetupPage(),

        '/signup': (context) => const Signup(),
        '/stores': (context) => const AllStoresPage(),
        '/shoppingCart': (context) => const CartPage(),
        '/addPayment': (context) => const AddPayment(),
        '/paymentMethod': (context) => PaymentMethodPage(),
        '/orderEditTimer': (context) => EditCancelOrderPage(),
        '/orderHistory': (context) => Order(),
        '/ratingFeedback': (context) => RatingFeedbackPage(),
        '/menuShop': (context) => MenuShopPage(storeDocId: 'demo'),
        '/productDetail': (context) => ProductDetailPage(
          productDocId: '',
          title: '',
          price: '',
          calories: '',
          imagePath: '',
          storeId: '',
        ),
        '/orderTracking': (context) => OrderStatusPage(),
      },
    );
  }
}
