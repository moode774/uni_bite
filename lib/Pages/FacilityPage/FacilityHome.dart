import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Facilityhome extends StatefulWidget {
  final String facilityId;

  const Facilityhome({super.key, required this.facilityId});

  @override
  _FacilityhomeState createState() => _FacilityhomeState();
}

class _FacilityhomeState extends State<Facilityhome> {
  String facilityName = "Loading...";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFacilityData();
  }

  // دالة لجلب بيانات المنشأة من Firestore
  Future<void> fetchFacilityData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("facilities") // افترضت أن بيانات المنشآت مخزنة في كوليكشن "facilities"
          .doc(widget.facilityId)
          .get();

      if (doc.exists) {
        setState(() {
          facilityName = doc["name"] ?? "Unknown Facility";
          isLoading = false;
        });
      } else {
        setState(() {
          facilityName = "Facility Not Found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        facilityName = "Error Loading Facility";
        isLoading = false;
      });
    }
  }

  // دالة تسجيل الخروج
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F0),
        elevation: 0,
        title: Text(
          "Welcome, $facilityName",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3E5F),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF2A3E5F)),
            onPressed: signOut,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Facility Dashboard",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3E5F),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // بطاقة لعرض الطلبات
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.list_alt, color: Color(0xFF6B7DAF)),
                      title: const Text(
                        "View Orders",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        // يمكنك إضافة الانتقال إلى صفحة الطلبات هنا
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("View Orders clicked")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // بطاقة لإدارة القائمة
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.menu_book, color: Color(0xFF6B7DAF)),
                      title: const Text(
                        "Manage Menu",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        // يمكنك إضافة الانتقال إلى صفحة إدارة القائمة هنا
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Manage Menu clicked")),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  // بطاقة لعرض الملف الشخصي
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person, color: Color(0xFF6B7DAF)),
                      title: const Text(
                        "Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      onTap: () {
                        // يمكنك إضافة الانتقال إلى صفحة الملف الشخصي هنا
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Profile clicked")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}