import 'package:flutter/material.dart';
import 'package:uni_bite/localization/app_localizations.dart';

class FavoritesScreen extends StatelessWidget {
  final List<String> favorites;
  final Function(String) toggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.toggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 241, 241),
      body: Column(
        children: [
          // التدرج العلوي مع زر الرجوع
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFF2D1C8), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8), // مسافة بين الزر والعنوان
                // عنوان المفضلة في المنتصف
                Center(
                  child: Text(
                    AppLocalizations.of(context).translate("favorites"),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // خلفية وردية فاتحة لقائمة العناصر
          Expanded(
            child: Container(
              color: const Color(0xFFFFF5F2), // لون وردي فاتح للخلفية
              child: favorites.isEmpty
                  ? Center(
                      child: Text(
                        AppLocalizations.of(context).translate("no_favorites"),
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: favorites.length,
                      itemBuilder: (context, index) {
                        final favorite = favorites[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: IconButton(
                              icon: const Icon(
                                Icons.favorite,
                                color: Colors.blueGrey,
                              ),
                              onPressed: () {
                                // عندما يتم الضغط على الأيقونة، يتم التبديل بين إضافة وحذف المفضلة
                                toggleFavorite(favorite);
                              },
                            ),
                            title: Text(
                              favorite,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}