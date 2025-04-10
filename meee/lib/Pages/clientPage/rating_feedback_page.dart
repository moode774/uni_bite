// rating_feedback_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/model/rating_manager.dart';

class RatingFeedbackPage extends StatefulWidget {
  final String? orderId;
  final String? storeId;

  const RatingFeedbackPage({
    Key? key,
    this.orderId,
    this.storeId,
  }) : super(key: key);

  @override
  _RatingFeedbackPageState createState() => _RatingFeedbackPageState();
}

class _RatingFeedbackPageState extends State<RatingFeedbackPage> {
  int _selectedStars = 3;
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  Future<Map<String, dynamic>> _getStoreInfo() async {
    if (widget.storeId == null || widget.storeId!.isEmpty) {
      // If the store ID is not available, return empty data
      return {};
    }
    
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('facility')
        .doc(widget.storeId)
        .get();
    return doc.exists ? doc.data() as Map<String, dynamic> : {};
  }

  Future<void> _submitRating() async {
    if (_isSending) return;
    
    if (widget.orderId == null ||
        widget.orderId!.isEmpty ||
        widget.storeId == null ||
        widget.storeId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Store or order information not available'))
      );
      return;
    }
    
    setState(() {
      _isSending = true;
    });
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to submit a rating'))
        );
        return;
      }
      
      await FirebaseFirestore.instance.collection('ratings').add({
        'userId': user.uid,
        'storeId': widget.storeId,
        'orderId': widget.orderId,
        'rating': _selectedStars,
        'comment': _commentController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await _updateStoreRating();
      
      // Mark this order as rated
      if (widget.orderId != null && widget.orderId!.isNotEmpty) {
        await RatingManager.markOrderAsRated(widget.orderId!);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rating submitted successfully'))
      );
      
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e'))
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<void> _updateStoreRating() async {
    try {
      if (widget.storeId == null || widget.storeId!.isEmpty) return;
      
      QuerySnapshot ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('storeId', isEqualTo: widget.storeId)
          .get();
      
      if (ratingsSnapshot.docs.isEmpty) return;
      
      // Calculate the average rating
      double totalRating = 0;
      for (var doc in ratingsSnapshot.docs) {
        totalRating += (doc.data() as Map<String, dynamic>)['rating'] as int;
      }
      
      double averageRating = totalRating / ratingsSnapshot.docs.length;
      
      // Update the store document with the new average rating and count
      await FirebaseFirestore.instance
          .collection('facility')
          .doc(widget.storeId)
          .update({
        'rating': averageRating.toStringAsFixed(1),
        'ratingsCount': ratingsSnapshot.docs.length,
      });
    } catch (e) {
      print('Error updating store rating: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getStoreInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF9EAE6),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        final storeData = snapshot.data!;
        return Scaffold(
          backgroundColor: const Color(0xFFF9EAE6),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 40.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF9EAE6),
                      border: Border.all(
                        color: const Color(0xFF2A3E5F),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.close,
                        color: Color(0xFF2A3E5F),
                        size: 18,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Rating & Feedback",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3E5F),
                  ),
                ),
                const SizedBox(height: 15),
                storeData['image'] != null
                    ? Image.network(storeData['image'], height: 80)
                    : Container(height: 80),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: index < _selectedStars
                            ? const Color(0xFF2A3E5F)
                            : Colors.grey,
                        size: 50,
                      ),
                      onPressed: () {
                        setState(() {
                          _selectedStars = index + 1;
                        });
                      },
                    );
                  }),
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Please write your comments here",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 150,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: "Write here",
                      border: InputBorder.none,
                    ),
                    maxLines: 5,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isSending ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3E5F),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 150,
                      vertical: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: _isSending 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Send",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
