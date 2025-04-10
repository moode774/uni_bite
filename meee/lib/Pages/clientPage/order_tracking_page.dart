// order_tracking_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'rating_feedback_page.dart';
import '/model/rating_manager.dart';

class OrderStatusPage extends StatefulWidget {
  final bool isCancelled;
  final String? orderId;

  const OrderStatusPage({
    super.key,
    this.isCancelled = false,
    this.orderId,
  });

  @override
  _OrderStatusPageState createState() => _OrderStatusPageState();
}

class _OrderStatusPageState extends State<OrderStatusPage> {
  String? _previousStatus;

  @override
  Widget build(BuildContext context) {
    if (widget.isCancelled) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9EAE6),
        appBar: AppBar(
          title: const Text('Order Status', style: TextStyle(color: Color(0xFF2A3E5F))),
          centerTitle: true,
          backgroundColor: const Color(0xFFF9EAE6),
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: const Center(
          child: Text("Order Cancelled", style: TextStyle(fontSize: 24, color: Colors.red)),
        ),
      );
    }

    if (widget.orderId == null) {
      return const Scaffold(
        body: Center(child: Text("No order found")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9EAE6),
      appBar: AppBar(
        title: const Text('Order Status', style: TextStyle(color: Color(0xFF2A3E5F))),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9EAE6),
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found'));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final String status = orderData['status']?.toString() ?? 'unknown';
          final String storeId = orderData['storeId']?.toString() ?? '';

          if (_previousStatus == 'current' && status == 'previous') {
            _checkAndShowRatingScreen(storeId);
          }

          _previousStatus = status;

          final items = List<Map<String, dynamic>>.from(orderData['items'] ?? []);
          final total = orderData['total'] ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Order Status",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2A3E5F)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Status: $status",
                    style: const TextStyle(fontSize: 18, color: Color(0xFF2A3E5F)),
                  ),
                  const SizedBox(height: 20),
                  _buildOrderStatus(status),
                  const SizedBox(height: 30),
                  const Divider(color: Color(0xFF2A3E5F)),
                  const SizedBox(height: 10),
                  const Text(
                    'Order summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3E5F),
                    ),
                  ),
                  const SizedBox(height: 15),
                  ...items.map((item) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.network(
                                item['imagePath'] ?? '',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    style: const TextStyle(fontSize: 16, color: Color(0xFF2A3E5F)),
                                  ),
                                  Text(
                                    'Qty: ${item['quantity']}',
                                    style: const TextStyle(color: Color(0xFF2A3E5F)),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      )),
                  const SizedBox(height: 20),
                  Text(
                    'Total: $total SAR',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF2A3E5F),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _checkAndShowRatingScreen(String storeId) async {
    if (widget.orderId == null) return;

    bool isRated = await RatingManager.isOrderRated(widget.orderId!);

    if (!isRated && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RatingFeedbackPage(
              orderId: widget.orderId,
              storeId: storeId,
            ),
          ),
        );
      });
    }
  }

  Widget _buildOrderStatus(String status) {
    bool isAccepted = false;
    bool isPreparing = false;
    bool isReady = false;

    if (status == 'current') {
      isAccepted = true;
      isPreparing = true;
      isReady = false;
    } else if (status == 'previous') {
      isAccepted = true;
      isPreparing = true;
      isReady = true;
    }

    return Column(
      children: [
        _statusTile("Your order is accepted", isAccepted),
        _statusTile("Preparing your order", isPreparing),
        _statusTile("Your order is ready", isReady),
      ],
    );
  }

  Widget _statusTile(String text, bool isActive) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? const Color(0xFF2A3E5F) : Colors.white,
                border: Border.all(color: const Color(0xFF2A3E5F), width: 2),
              ),
            ),
            Container(
              height: 40,
              width: 2,
              color: const Color(0xFF2A3E5F),
            ),
          ],
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: const Color(0xFF2A3E5F),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
