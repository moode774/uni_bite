import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_payment_card_page.dart';
import 'package:uni_bite/localization/app_localizations.dart';

class PaymentMethodPage extends StatefulWidget {
  final String? selectedCardId; // معرف البطاقة المحددة حالياً (إذا وجد)
  
  const PaymentMethodPage({Key? key, this.selectedCardId}) : super(key: key);

  @override
  _PaymentMethodPageState createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedCardId; // معرف البطاقة المحددة في هذه الصفحة

  @override
  void initState() {
    super.initState();
    // تعيين البطاقة المحددة من القيمة المستلمة (إن وجدت)
    _selectedCardId = widget.selectedCardId;
    // قراءة البطاقة الافتراضية إذا لم يتم تمرير أي بطاقة
    if (_selectedCardId == null) {
      _loadDefaultCard();
    }
  }

  // قراءة البطاقة الافتراضية من Firestore
  Future<void> _loadDefaultCard() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()!.containsKey('defaultCardId')) {
          setState(() {
            _selectedCardId = userDoc.data()!['defaultCardId'];
          });
        }
      }
    } catch (e) {
      print('Error loading default card: $e');
    }
  }

  Future<void> _deleteCard(String cardId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('payment_cards')
            .doc(cardId)
            .delete();
        
        // إذا كانت البطاقة المحذوفة هي المحددة، قم بإلغاء التحديد
        if (_selectedCardId == cardId) {
          setState(() {
            _selectedCardId = null;
          });
          
          // حذف البطاقة الافتراضية من إعدادات المستخدم
          await _firestore.collection('users').doc(user.uid).update({
            'defaultCardId': FieldValue.delete()
          });
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('card_deleted'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).translate('error_deleting_card')}: $e')),
      );
    }
  }

  // تحديد البطاقة وحفظها كبطاقة افتراضية
  Future<void> _selectCard(String cardId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // حفظ البطاقة المحددة في Firestore كإعداد للمستخدم
        await _firestore.collection('users').doc(user.uid).set({
          'defaultCardId': cardId
        }, SetOptions(merge: true));
        
        setState(() {
          _selectedCardId = cardId;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).translate('default_payment_set'))),
        );
        
        // إرجاع معرف البطاقة المحددة إلى الشاشة السابقة
        Navigator.pop(context, cardId);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).translate('error')}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context, _selectedCardId),
        ),
        title: Text(
          AppLocalizations.of(context).translate('payment_method'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: user == null
          ? Center(child: Text(AppLocalizations.of(context).translate('please_login')))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context).translate('saved_cards'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          AppLocalizations.of(context).translate('edit'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('users')
                        .doc(user.uid)
                        .collection('payment_cards')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text('${AppLocalizations.of(context).translate('error')}: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final cards = snapshot.data?.docs ?? [];
                      
                      if (cards.isEmpty) {
                        return Center(
                          child: Text(
                            AppLocalizations.of(context).translate('no_saved_cards'),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey
                            )
                          ),
                        );
                      }

                      return Column(
                        children: cards.map((card) {
                          final cardData = card.data() as Map<String, dynamic>;
                          final cardId = card.id;
                          final isSelected = cardId == _selectedCardId;
                          
                          return _buildSavedCard(
                            cardNumber: cardData['cardNumber'] ?? '',
                            cardId: cardId,
                            isSelected: isSelected,
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  _buildAddNewCardButton(context),
                ],
              ),
            ),
    );
  }

  Widget _buildSavedCard({
    required String cardNumber,
    required String cardId,
    required bool isSelected,
  }) {
    String maskedNumber = cardNumber.length >= 4 
      ? "•••• ${cardNumber.substring(cardNumber.length - 4)}"
      : "•••• **";
    
    return GestureDetector(
      onTap: () => _selectCard(cardId),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEAF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.blueGrey,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // شعار VISA بدلا من أيقونة البطاقة العادية
                Image.asset(
                  'assets/visa_logo.png',
                  width: 40,
                  height: 24,
                ),
                const SizedBox(width: 10),
                // خط فاصل عمودي
                Container(
                  height: 20,
                  width: 1,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context).translate('card'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  maskedNumber,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 24,
                  ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.black54),
                  onPressed: () => _deleteCard(cardId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCardButton(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPayment()),
          );
          setState(() {});
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.blueGrey),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text(
          AppLocalizations.of(context).translate('add_new_card'),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}