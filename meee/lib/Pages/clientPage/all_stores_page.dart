// cli/all_stores_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_shop_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllStoresPage extends StatelessWidget {
  const AllStoresPage({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _getStores() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('facility').get();
    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/login'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Stores"),
        backgroundColor: const Color(0xFF2A3E5F),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF2A3E5F),
              ),
              child: Center(
                child: Text(
                  "Main Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text("All Stores"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/stores');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Signup"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/signup');
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Shopping Cart"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/shoppingCart');
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("Add Payment Card"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/addPayment');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text("Payment Methods"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/paymentMethod');
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text("Order Edit Timer"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/orderEditTimer');
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text("Order Confirmation"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/orderConfirmation');
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Order History"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/orderHistory');
              },
            ),
            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text("Rating & Feedback"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/ratingFeedback');
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant),
              title: const Text("Menu Shop"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/menuShop');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text("Order Tracking"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/orderTracking');
              },
            ),
            ListTile(
              leading: const Icon(Icons.production_quantity_limits),
              title: const Text("Product Detail"),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/productDetail');
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getStores(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final stores = snapshot.data ?? [];
          if (stores.isEmpty) {
            return const Center(child: Text("No stores available"));
          }
          return ListView.builder(
            itemCount: stores.length,
            itemBuilder: (context, index) {
              final store = stores[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    store["image"] ?? "",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey,
                      child: const Icon(Icons.store, color: Colors.white),
                    ),
                  ),
                ),
                title: Text(store["name"] ?? "Store Name"),
                subtitle: Text("Rating: ${store["rating"] ?? "0.0"}"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MenuShopPage(storeDocId: store["id"]),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
