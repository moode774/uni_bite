import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/cart_data.dart'; 
import 'shopping_cart_page.dart';
import 'product_detail_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuShopPage extends StatefulWidget {
  final String storeDocId;
  const MenuShopPage({Key? key, required this.storeDocId}) : super(key: key);

  @override
  _MenuShopPageState createState() => _MenuShopPageState();
}

class _MenuShopPageState extends State<MenuShopPage> {
  String selectedCategory = "All";
  String searchQuery = "";
  List<String> categories = ["All"]; 

  final Color backgroundColor = const Color(0xFFFAF0F0);
  final Color selectedCategoryColor = const Color.fromARGB(255, 140, 165, 186);

  late Future<Map<String, dynamic>> _storeFuture;
  late Future<List<Map<String, dynamic>>> _productsFuture;
  late Future<List<String>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _checkUser();
    _storeFuture = _getStoreInfo();
    _productsFuture = _getProducts();
    _categoriesFuture = _getCategories();
  }

  void _checkUser() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      Future.microtask(() {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    }
  }

  Future<Map<String, dynamic>> _getStoreInfo() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('facility')
        .doc(widget.storeDocId)
        .get();
    return doc.exists ? (doc.data() as Map<String, dynamic>) : {};
  }

  Future<List<String>> _getCategories() async {
    try {
      DocumentSnapshot storeDoc = await FirebaseFirestore.instance
          .collection('facility')
          .doc(widget.storeDocId)
          .get();
      
      if (!storeDoc.exists) {
        return ["All"];
      }

      final storeData = storeDoc.data() as Map<String, dynamic>;
      
      if (storeData.containsKey('categories') && storeData['categories'] is List) {
        List<String> storeCategories = List<String>.from(storeData['categories']);
        
        if (!storeCategories.contains("All")) {
          return ["All", ...storeCategories];
        }
        return storeCategories;
      }
      
      return ["All"];
    } catch (error) {
      print("Error fetching categories: $error");
      return ["All"]; 
    }
  }

  Future<List<Map<String, dynamic>>> _getProducts() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Products')
        .where('storeId', isEqualTo: widget.storeDocId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        "productDocId": doc.id,
        "title": data["productName"] ?? "",
        "price": data["price"] is num ? data["price"] : 0,
        "calories": data["calories"] is String ? data["calories"] : "",
        "category": data["category"] ?? "Unknown",
        "imageUrl": data["imageUrl"] ?? "",
      };
    }).toList();
  }

  Future<void> _refreshData() async {
    try {
      final storeData = await _getStoreInfo();
      final products = await _getProducts();
      final categoriesList = await _getCategories();
      setState(() {
        _storeFuture = Future.value(storeData);
        _productsFuture = Future.value(products);
        _categoriesFuture = Future.value(categoriesList);
      });
    } catch (error) {
      print("Error refreshing data: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _storeFuture,
          builder: (context, storeSnapshot) {
            if (storeSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (storeSnapshot.hasError) {
              return Center(child: Text("Error: ${storeSnapshot.error}"));
            }
            if (storeSnapshot.data == null || storeSnapshot.data!.isEmpty) {
              return const Center(child: Text("Store not found"));
            }

            final storeData = storeSnapshot.data!;

            return FutureBuilder<List<String>>(
              future: _categoriesFuture,
              builder: (context, categoriesSnapshot) {
                if (categoriesSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (categoriesSnapshot.hasError) {
                  return Center(child: Text("Error loading categories: ${categoriesSnapshot.error}"));
                }
                
                List<String> dynamicCategories = categoriesSnapshot.data ?? ["All"];
                
                if (!dynamicCategories.contains(selectedCategory)) {
                  selectedCategory = "All";
                }

                return RefreshIndicator(
                  onRefresh: _refreshData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      storeData["name"] ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      storeData["type"] ?? "Store",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  storeData["image"] ?? "",
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Image.asset(
                                    'assets/HM.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                                      hintText: "Search",
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (value) =>
                                        setState(() => searchQuery = value),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart,
                                  color: Color.fromARGB(255, 140, 165, 186),
                                  size: 28,
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CartPage(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 35,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: dynamicCategories.length,
                              itemBuilder: (context, index) {
                                bool isSelected = selectedCategory == dynamicCategories[index];
                                return GestureDetector(
                                  onTap: () => setState(() =>
                                      selectedCategory = dynamicCategories[index]),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    margin: const EdgeInsets.only(right: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? selectedCategoryColor
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        dynamicCategories[index],
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: FutureBuilder<List<Map<String, dynamic>>>(
                              future: _productsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Center(child: Text("Error: ${snapshot.error}"));
                                }
                                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                  return const Center(child: Text("No products available"));
                                }

                                final products = snapshot.data!;
                                final filteredProducts = products.where((product) {
                                  final title = (product["title"] ?? "").toLowerCase();
                                  final query = searchQuery.toLowerCase();
                                  final matchesSearch = query.isEmpty || title.contains(query);
                                  final matchesCategory = selectedCategory == "All" ||
                                      product["category"] == selectedCategory;
                                  return matchesSearch && matchesCategory;
                                }).toList();

                                return GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 15,
                                    mainAxisSpacing: 15,
                                  ),
                                  itemCount: filteredProducts.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredProducts[index];
                                    return GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ProductDetailPage(
                                            productDocId: product["productDocId"],
                                            title: product["title"] ?? "",
                                            price: product["price"].toString(),
                                            calories: product["calories"].toString(),
                                            imagePath: product["imageUrl"] ?? "",
                                            storeId: widget.storeDocId,
                                          ),
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: const BorderRadius.vertical(
                                                      top: Radius.circular(15),
                                                    ),
                                                    child: Image.network(
                                                      product["imageUrl"] ?? "",
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      errorBuilder: (context, error, stackTrace) =>
                                                          Image.asset(
                                                        'assets/placeholder.png',
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                      ),
                                                    ),
                                                  ),
                                              
                                                  
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product["title"] ?? "",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "${product["calories"]} Cal",
                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        "${product["price"]} SAR",
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          addToCart(
                                                            CartItem(
                                                              name: product["title"] ?? "",
                                                              imagePath: product["imageUrl"] ?? "",
                                                              price: product["price"] ?? 0,
                                                              quantity: 1,
                                                              storeId: widget.storeDocId,
                                                            ),
                                                          );
                                                          showDialog(
                                                            context: context,
                                                            builder: (ctx) => AlertDialog(
                                                              title: const Text("Added"),
                                                              content: Text(
                                                                  "Successfully added ${product["title"]} to cart."),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed: () => Navigator.pop(ctx),
                                                                  child: const Text("OK"),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                        child: Container(
                                                          padding: const EdgeInsets.all(8),
                                                          decoration: BoxDecoration(
                                                            color: selectedCategoryColor,
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: const Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
