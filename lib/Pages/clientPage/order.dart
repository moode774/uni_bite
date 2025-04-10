import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_tracking_page.dart';
import 'package:uni_bite/localization/app_localizations.dart';
//import 'package:uni_bite/Pages/clientPage/order_edit_timer_page.dart'; 

class Order extends StatefulWidget {
  final int initialTabIndex;
  const Order({super.key, this.initialTabIndex = 0});

  @override
  _OrderState createState() => _OrderState();
}

class _OrderState extends State<Order> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Stream<List<DocumentSnapshot>> _getOrders(String status) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('Orders')
        .where('user_id', isEqualTo: user.uid)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
  }

  Widget _buildOrdersList(String status) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _getOrders(status),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('${AppLocalizations.of(context).translate("error")}: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final orders = snapshot.data ?? [];
        if (orders.isEmpty) {
          return Center(child: Text(AppLocalizations.of(context).translate("no_orders")));
        }
        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final doc = orders[index];
            final orderData = doc.data() as Map<String, dynamic>;
            final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
            final total = orderData['total'] ?? 0;
            final timestamp = orderData['timestamp'] as Timestamp?;
            final orderDate = timestamp?.toDate() ?? DateTime.now();

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderStatusPage(
                      orderId: doc.id,
                      isCancelled: (orderData['status'] == 'cancelled'),
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${AppLocalizations.of(context).translate("order_date")}: ${orderDate.day}/${orderDate.month}/${orderDate.year}",
                      style: const TextStyle(
                        color: Color(0xFF2A3E5F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    if (items.isNotEmpty)
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: items.length,
                          itemBuilder: (context, idx) {
                            final item = items[idx];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      item['imagePath'] ?? '',
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, error, stack) => Container(
                                        width: 50,
                                        height: 50,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.coffee, color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      item['name'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context).translate("total"),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A3E5F),
                          ),
                        ),
                        Text(
                          '$total ${AppLocalizations.of(context).translate("sar")}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2A3E5F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9EAE6),
      appBar: AppBar(
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate("orders"),
            style: const TextStyle(
              color: Color(0xFF2A3E5F),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF9EAE6),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2A3E5F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2A3E5F),
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          tabs: [
            Tab(text: AppLocalizations.of(context).translate("current")),
            Tab(text: AppLocalizations.of(context).translate("previous")),
            Tab(text: AppLocalizations.of(context).translate("cancelled")),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList("current"),
          _buildOrdersList("previous"),
          _buildOrdersList("cancelled"),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}