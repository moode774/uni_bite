import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/cart_data.dart';
import 'shopping_cart_page.dart';
import 'package:uni_bite/localization/app_localizations.dart';

class ProductDetailPage extends StatefulWidget {
  final String productDocId;
  final String title;
  final String price;
  final String calories;
  final String imagePath;
  final String storeId;

  const ProductDetailPage({
    Key? key,
    required this.productDocId,
    required this.title,
    required this.price,
    required this.calories,
    required this.imagePath,
    required this.storeId,
  }) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  List<dynamic> dynamicAdditions = [];
  List<dynamic> selectedAdditions = [];

  Future<Map<String, dynamic>> _getProductData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Products')
        .doc(widget.productDocId)
        .get();
    return doc.exists ? (doc.data() as Map<String, dynamic>) : {};
  }

  Future<Map<String, dynamic>> _getStoreInfo() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Facility')
        .doc(widget.storeId)
        .get();
    return doc.exists ? (doc.data() as Map<String, dynamic>) : {};
  }

  Widget _buildAdditionsChips() {
    return Wrap(
      spacing: 8.0,
      children: dynamicAdditions.map((addition) {
        String addName = addition["name"] ?? "";
        // Convert addition price to int (even if stored as String)
        int addPrice = int.tryParse(addition["price"].toString()) ?? 0;
        bool isSelected = selectedAdditions.any((e) => e["name"] == addName);
        return FilterChip(
          label: Text("$addName (+$addPrice ${AppLocalizations.of(context).translate('sar')})"),
          selected: isSelected,
          onSelected: (bool selected) {
            setState(() {
              if (selected) {
                selectedAdditions.add(addition);
              } else {
                selectedAdditions.removeWhere((e) => e["name"] == addName);
              }
            });
          },
          selectedColor: Colors.green.shade200,
          checkmarkColor: Colors.white,
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    int basePrice = int.tryParse(widget.price) ?? 0;
    int additionalTotal = selectedAdditions.fold<int>(
      0,
      (prev, e) => prev + (int.tryParse(e["price"].toString()) ?? 0),
    );
    int totalPrice = basePrice + additionalTotal;

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([_getProductData(), _getStoreInfo()])
          .then((results) => {"product": results[0], "store": results[1]}),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9EAE6),
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9EAE6),
            body: Center(child: Text(AppLocalizations.of(context).translate("error_occurred"))),
          );
        }

        final data = snapshot.data!;
        final productData = data["product"] as Map<String, dynamic>;
        final storeData = data["store"] as Map<String, dynamic>;

        final String storeName = storeData["name"] ?? "Unknown Store";
        final String description = productData["description"] ?? "";
        final List<dynamic>? allergenImages = productData["allergenImages"];

        dynamicAdditions = productData["additions"] ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFFF9EAE6),
          body: SafeArea(
            child: Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 380,
                      child: Image.network(
                        widget.imagePath,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) => Image.asset(
                          'assets/placeholder.png',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 15,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFF9EAE6),
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A3E5F), size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      right: 15,
                      child: CircleAvatar(
                        backgroundColor: const Color(0xFFF9EAE6),
                        radius: 22,
                        child: IconButton(
                          icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2A3E5F), size: 24),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CartPage()),
                            );
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: Text(
                        storeName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A3E5F),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2A3E5F),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "${widget.calories} ${AppLocalizations.of(context).translate('cal')}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF2A3E5F),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
                                ),
                                child: Text(
                                  '$totalPrice ${AppLocalizations.of(context).translate('sar')}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2A3E5F),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (description.isNotEmpty) ...[
                            Text(
                              AppLocalizations.of(context).translate("description"),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2A3E5F),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              description,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2A3E5F),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          Text(
                            AppLocalizations.of(context).translate("allergens"),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3E5F),
                            ),
                          ),
                          const SizedBox(height: 10),
                          allergenImages != null && allergenImages.isNotEmpty
                              ? _buildAllergenImages(allergenImages)
                              : Text(
                                  AppLocalizations.of(context).translate("no_allergen_info"),
                                  style: const TextStyle(color: Color(0xFF2A3E5F)),
                                ),
                          const SizedBox(height: 20),
                          Text(
                            AppLocalizations.of(context).translate("additions"),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2A3E5F),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildAdditionsChips(),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF2A3E5F)),
                                ),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove, color: Color(0xFF2A3E5F)),
                                      onPressed: () {
                                        setState(() {
                                          if (quantity > 1) quantity--;
                                        });
                                      },
                                    ),
                                    Text(
                                      "$quantity",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Color(0xFF2A3E5F),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add, color: Color(0xFF2A3E5F)),
                                      onPressed: () {
                                        setState(() {
                                          quantity++;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    addToCart(
                                      CartItem(
                                        name: widget.title,
                                        imagePath: widget.imagePath,
                                        price: basePrice,
                                        quantity: quantity,
                                        storeId: widget.storeId,
                                        additionName: selectedAdditions.isNotEmpty
                                            ? selectedAdditions
                                                .map((e) => e["name"])
                                                .join(", ")
                                            : null,
                                        additionPrice: selectedAdditions.fold<int>(
                                            0,
                                            (prev, e) => prev +
                                                (int.tryParse(e["price"].toString()) ??
                                                    0)),
                                      ),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context).translate("product_added")),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF2A3E5F)),
                                  label: Text(
                                    AppLocalizations.of(context).translate("add_to_cart"),
                                    style: const TextStyle(fontSize: 16, color: Color(0xFF2A3E5F)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: const BorderSide(color: Color(0xFF2A3E5F)),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 15),
                                  ),
                                ),
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
        );
      },
    );
  }

  Widget _buildAllergenImages(List<dynamic> allergenImages) {
    return Wrap(
      spacing: 20,
      runSpacing: 10,
      children: allergenImages.map((allergen) {
        final String imageUrl = allergen["imageUrl"] ?? "";
        final String name = allergen["name"] ?? "";
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                  onError: (_, __) =>
                      Image.asset('assets/placeholder.png', fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(color: Color(0xFF2A3E5F)),
            ),
          ],
        );
      }).toList(),
    );
  }
}