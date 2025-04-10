import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uni_bite/Pages/clientPage/favorites.dart';
import 'package:uni_bite/Pages/clientPage/order.dart' as order_page;  // هنا أضفنا alias
import 'package:uni_bite/Pages/clientPage/profile.dart';
import 'package:uni_bite/Pages/clientPage/menu_shop_page.dart';

class Facility {
  final String id;
  final String name;
  final String type;
  final double rating;
  final String image;

  Facility({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.image,
  });

  factory Facility.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Facility(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['Type'] ?? '',
      rating: data['rating'] != null
          ? double.tryParse(data['rating'].toString()) ?? 0.0
          : 0.0,
      image: data['image'] ?? '',
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedCategoryIndex = 0;
  int _selectedNavIndex = 0;
  String searchQuery = '';
  final List<String> orders = [];
  List<String> favorites = []; // قائمة المفضلات

  final List<String> categories = const [
    'All',
    'Restaurants',
    'Cafes',
    'Top Rated'
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data.containsKey('favorites')) {
          setState(() {
            favorites = List<String>.from(data['favorites']);
          });
        }
      }
    }
  }

  Future<void> _toggleFavorite(String facilityName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef =
          FirebaseFirestore.instance.collection('favorites').doc(user.uid);

      if (favorites.contains(facilityName)) {
        setState(() {
          favorites.remove(facilityName);
        });
      } else {
        setState(() {
          favorites.add(facilityName);
        });
      }

      await docRef.set({'favorites': favorites});
    }
  }

  List<Facility> getFilteredFacilities(List<Facility> facilities) {
    List<Facility> filteredList;
    switch (_selectedCategoryIndex) {
      case 1:
        filteredList = facilities
            .where((facility) =>
                facility.type == 'restaurant' || facility.type == 'Restaurant')
            .toList();
        break;
      case 2:
        filteredList = facilities
            .where((facility) => facility.type.toLowerCase() == 'cafe')
            .toList();
        break;
      case 3:
        filteredList =
            facilities.where((facility) => facility.rating >= 4.8).toList();
        filteredList.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        filteredList = facilities;
    }

    if (searchQuery.isNotEmpty) {
      filteredList = filteredList
          .where((facility) =>
              facility.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }
    return filteredList;
  }

  Widget buildFacilityGrid(List<Facility> facilities) {
    final filteredFacilities = getFilteredFacilities(facilities);
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredFacilities.length,
      itemBuilder: (context, index) {
        final facility = filteredFacilities[index];
        final isFavorite = favorites.contains(facility.name);
        return FacilityCard(
          facility: facility,
          isFavorite: isFavorite,
          onFavoriteToggle: () => _toggleFavorite(facility.name),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MenuShopPage(storeDocId: facility.id),
              ),
            );
          },
        );
      },
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFF5F2),
      body: IndexedStack(
        index: _selectedNavIndex,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(45),
                margin: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF2D1C8), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 0),
                    const Text(
                      'Your meal is ready! Order now and save time.',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (query) {
                        setState(() {
                          searchQuery = query;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(1),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          categories.length,
                          (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryIndex = index;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: _selectedCategoryIndex == index
                                    ? Colors.blueGrey
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: Text(
                                categories[index],
                                style: TextStyle(
                                  color: _selectedCategoryIndex == index
                                      ? Colors.white
                                      : Colors.blueGrey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Facility')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final facilitiesList = snapshot.data!.docs
                        .map((doc) => Facility.fromDocument(doc))
                        .toList();
                    return buildFacilityGrid(facilitiesList);
                  },
                ),
              ),
            ],
          ),
          FavoritesScreen(
            favorites: favorites,
            toggleFavorite: _toggleFavorite,
          ),
          order_page.Order(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          setState(() {
            _selectedNavIndex = index;
          });
        },
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class FacilityCard extends StatelessWidget {
  final Facility facility;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const FacilityCard({
    super.key,
    required this.facility,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  Widget _buildFacilityImage() {
    if (facility.image.isEmpty) {
      return const Icon(Icons.image, size: 100, color: Colors.grey);
    } else if (facility.image.startsWith('assets/')) {
      return Image.asset(
        facility.image,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      );
    } else {
      return Image.network(
        facility.image,
        height: 100,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 100, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(15)),
              child: _buildFacilityImage(),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    facility.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${facility.rating} ⭐',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.blueGrey : Colors.grey,
                        ),
                        onPressed: onFavoriteToggle,
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
  }
}