import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter/material.dart';
import 'shopping_cart_page.dart';
import 'order_tracking_page.dart';
import '/model/cart_data.dart';
import 'order.dart';
import 'package:uni_bite/localization/app_localizations.dart'; // إضافة مكتبة التعريب

class EditCancelOrderPage extends StatefulWidget {
  const EditCancelOrderPage({super.key});

  @override
  _EditCancelOrderPageState createState() => _EditCancelOrderPageState();
}

class _EditCancelOrderPageState extends State<EditCancelOrderPage> {
  int _secondsRemaining = 30;
  late Timer _timer;
  bool _showOrderReceived = false;

  String? userFirstName;
  String? userLastName;
  String? userEmail;
  String? userPhone;

  List<CartItem> originalCartItems = [];

  @override
  void initState() {
    super.initState();
    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderId =
          ModalRoute.of(context)?.settings.arguments as String? ?? "";
      if (orderId.isNotEmpty) {
        _fetchOrderAndUserData(orderId);
      }
    });
  }

  Future<void> _fetchOrderAndUserData(String orderId) async {
    try {
      final orderDoc =
          await FirebaseFirestore.instance
              .collection('Orders')
              .doc(orderId)
              .get();

      if (!orderDoc.exists) return;

      final orderData = orderDoc.data()!;
      final userId = orderData['user_id'];

      List<dynamic> items = orderData['items'] ?? [];
      String storeId = orderData['storeId'] ?? '';

      originalCartItems.clear();

      for (var item in items) {
        CartItem cartItem = CartItem(
          storeId: storeId,
          name: item['name'] ?? '',
          price: item['price'] ?? 0,
          quantity: item['quantity'] ?? 1,
          imagePath: item['imagePath'] ?? '',
          additionName: item['additionName'],
          additionPrice: item['additionPrice'] ?? 0,
        );
        originalCartItems.add(cartItem);
      }

      print('Retrieved ${originalCartItems.length} items for order: $orderId');

      final userDoc =
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(userId)
              .get();

      if (!userDoc.exists) return;

      final userData = userDoc.data()!;
      setState(() {
        userFirstName = userData['first_name'];
        userLastName = userData['last_name'];
        userEmail = userData['email'];
        userPhone = userData['phone'];
      });
    } catch (e) {
      debugPrint('Error fetching order/user data: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer.cancel();
        _showOrderReceivedScreen();
      }
    });
  }

  void _showOrderReceivedScreen() {
    setState(() {
      _showOrderReceived = true;
    });

    Timer(const Duration(seconds: 3), () {
      if (mounted && _showOrderReceived) {
        _navigateToOrderStatus();
      }
    });
  }

  void _navigateToOrderStatus() {
    final orderId = ModalRoute.of(context)?.settings.arguments as String? ?? "";
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderStatusPage(orderId: orderId),
      ),
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    // عرض Dialog مع خيارات أسباب الإلغاء
    final String? selectedReason = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate("reason_for_cancellation")),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).translate("changed_my_mind")),
                  onTap: () => Navigator.pop(context, AppLocalizations.of(context).translate("changed_my_mind")),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).translate("found_better_option")),
                  onTap: () => Navigator.pop(context, AppLocalizations.of(context).translate("found_better_option")),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).translate("order_mistake")),
                  onTap: () => Navigator.pop(context, AppLocalizations.of(context).translate("order_mistake")),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).translate("delivery_delay")),
                  onTap: () => Navigator.pop(context, AppLocalizations.of(context).translate("delivery_delay")),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).translate("prefer_not_to_say")),
                  onTap: () => Navigator.pop(context, AppLocalizations.of(context).translate("prefer_not_to_say")),
                ),
              ],
            ),
          ),
        );
      },
    );

    // إذا اختار المستخدم سبب أو أغلق الـ Dialog
    if (selectedReason != null) {
      try {
        // تحديث حالة الطلب في Firestore مع إضافة سبب الإلغاء
        await FirebaseFirestore.instance
            .collection('Orders')
            .doc(orderId)
            .update({
              'status': 'cancelled',
              'cancelReason': selectedReason, // إضافة سبب الإلغاء للبيانات
            });

        // الانتقال إلى OrdersScreen مع فتح تبويب "Cancelled"
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const Order(initialTabIndex: 2),
          ),
        );
      } catch (e) {
        debugPrint('Error cancelling order: $e');
      }
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderId = ModalRoute.of(context)?.settings.arguments as String? ?? "";

    if (!_showOrderReceived) {
      return _buildMainTimerUI(orderId);
    } else {
      return _buildOrderReceivedUI(orderId);
    }
  }

  Widget _buildMainTimerUI(String orderId) {
    double percent = _secondsRemaining / 30;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF6F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A3E5F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          " ",
          style: TextStyle(
            color: Color(0xFF2A3E5F),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (userFirstName != null && userLastName != null)
              Text("${AppLocalizations.of(context).translate("customer")}: $userFirstName $userLastName"),
            if (userEmail != null) Text("${AppLocalizations.of(context).translate("email")}: $userEmail"),
            if (userPhone != null) Text("${AppLocalizations.of(context).translate("phone")}: $userPhone"),
            const SizedBox(height: 20),
            _buildTimerWidget(percent),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context).translate("edit_cancel_time_message"),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF65768B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _timer.cancel();

                    cartItems.clear();
                    cartItems.addAll(originalCartItems);

                    print(
                      'Added ${cartItems.length} items back to cart for editing',
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3E5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).translate("edit")),
                ),
                ElevatedButton(
                  onPressed: () {
                    _timer.cancel();
                    _cancelOrder(orderId); // الانتقال بعد اختيار السبب
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3E5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).translate("cancel")),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_timer.isActive) {
                      _timer.cancel();
                    }
                    _showOrderReceivedScreen();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3E5F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(AppLocalizations.of(context).translate("skip_time")),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerWidget(double percent) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: CircularProgressIndicator(
            value: percent,
            strokeWidth: 8,
            color: const Color(0xFF2A3E5F),
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        Text(
          '$_secondsRemaining',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildOrderReceivedUI(String orderId) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EAE6),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context).translate("thank_you"),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3E5F),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                AppLocalizations.of(context).translate("order_received"),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A3E5F),
                ),
              ),
              const SizedBox(height: 15),
              Image.asset(
                "assets/cart.png",
                width: 220,
                color: const Color(0xFF2A3E5F),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  _showOrderReceived = false;
                  _navigateToOrderStatus();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A3E5F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(AppLocalizations.of(context).translate("skip")),
              ),
            ],
          ),
        ),
      ),
    );
  }
}