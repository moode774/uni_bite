import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/cart_data.dart';
import 'package:uni_bite/Pages/clientPage/payment_methods_page.dart';
import 'package:uni_bite/localization/app_localizations.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final TextEditingController _notesController = TextEditingController();
  String? selectedCardId;
  String? currentStoreId; 
  Map<String, dynamic>? paymentCardData; 

  @override
  void initState() {
    super.initState();
    if (cartItems.isNotEmpty && cartItems.first.storeId != null) {
      currentStoreId = cartItems.first.storeId;
    }
    _loadDefaultCard();
  }

  Future<void> _loadDefaultCard() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists && userDoc.data()!.containsKey('defaultCardId')) {
          setState(() {
            selectedCardId = userDoc.data()!['defaultCardId'];
          });
          await _loadCardData(selectedCardId!);
        }
      }
    } catch (e) {
      print('Error loading default card: $e');
    }
  }

  Future<void> _loadCardData(String cardId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final cardDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('payment_cards')
            .doc(cardId)
            .get();
            
        if (cardDoc.exists) {
          final cardData = cardDoc.data()!;
          paymentCardData = {
            'cardName': cardData['cardName'] ?? '',
            'cardNumber': cardData['cardNumber'] ?? '',
            'expiry': cardData['expiry'] ?? '',
          };
        }
      }
    } catch (e) {
      print('Error loading card data: $e');
    }
  }

  Future<void> _placeOrder() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushNamed(context, '/signup');
      return;
    }

    if (currentStoreId == null || currentStoreId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('store_not_found')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).translate('user_not_found')),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userData = userDoc.data()!;
      final firstName = userData['first_name'] ?? '';
      final lastName = userData['last_name'] ?? '';
      final email = userData['email'] ?? '';
      final phone = userData['phone'] ?? '';

      int total = cartItems.fold(0, (sum, item) => sum + ((item.price + item.additionPrice) * item.quantity));

      final orderData = {
        "user_id": user.uid,
        "storeId": currentStoreId,
        "first_name": firstName,
        "last_name": lastName,
        "email": email,
        "phone": phone,
        "items": cartItems.map((item) {
          final Map<String, dynamic> itemMap = {
            "name": item.name,
            "price": item.price,
            "quantity": item.quantity,
            "imagePath": item.imagePath,
          };
          if (item.additionName != null && item.additionName!.isNotEmpty) {
            itemMap["additionName"] = item.additionName!;
            itemMap["additionPrice"] = item.additionPrice;
          }
          return itemMap;
        }).toList(),
        "notes": _notesController.text.trim(),
        "total": total,
        "status": "current",
        "timestamp": FieldValue.serverTimestamp(),
        if (paymentCardData != null) "payment_info": paymentCardData,
      };

      DocumentReference orderRef =
          await FirebaseFirestore.instance.collection('Orders').add(orderData);
      String orderId = orderRef.id;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).translate('order_placed_successfully')),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        cartItems.clear();
      });

      Navigator.pushNamed(context, '/orderEditTimer', arguments: orderId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context).translate('error_occurred')}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _editProduct(CartItem item) {
    int newQuantity = item.quantity;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('${AppLocalizations.of(context).translate('edit_quantity')}: ${item.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(AppLocalizations.of(context).translate('quantity')),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Color(0xFF2A3E5F)),
                        onPressed: () {
                          if (newQuantity > 1) {
                            setDialogState(() {
                              newQuantity--;
                            });
                          }
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2A3E5F))
                        ),
                        child: Text(
                          '$newQuantity',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: Color(0xFF2A3E5F)),
                        onPressed: () {
                          setDialogState(() {
                            newQuantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${AppLocalizations.of(context).translate('price')}: ${(item.price + item.additionPrice) * newQuantity} SAR',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2A3E5F),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context).translate('cancel'), 
                    style: const TextStyle(color: Colors.red)
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      item.quantity = newQuantity;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A3E5F),
                  ),
                  child: Text(
                    AppLocalizations.of(context).translate('save'), 
                    style: const TextStyle(color: Colors.white)
                  ),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int total = cartItems.fold(0, (sum, item) => sum + ((item.price + item.additionPrice) * item.quantity));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF9F3ED),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2A3E5F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context).translate('cart'),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3E5F),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF9F3ED),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: cartItems.isEmpty
                    ? SizedBox(
                        height: 300,
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context).translate('no_items_in_cart')
                          )
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) =>
                            _buildCartItem(cartItems[index]),
                      ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: const Color(0xFFF9F3ED),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _addMoreItemsButton(),
                    const SizedBox(height: 15),
                    Text(
                      AppLocalizations.of(context).translate('add_notes'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A3E5F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildNotesField(),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context).translate('payment_method'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A3E5F),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentMethod(context),
                    const SizedBox(height: 20),
                    _buildTotalSection(total),
                    const SizedBox(height: 15),
                    _placeOrderButton(),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (user != null) ...[
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .collection('payment_cards').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print('Error loading cards: ${snapshot.error}');
                return Text(
                  AppLocalizations.of(context).translate('error_loading_cards')
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 40,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              
              final cards = snapshot.data?.docs ?? [];
              if (cards.isEmpty) {
                return _buildPaymentButtons();
              }
              
              QueryDocumentSnapshot? selectedCardDoc;
              
              if (selectedCardId != null) {
                for (var card in cards) {
                  if (card.id == selectedCardId) {
                    selectedCardDoc = card;
                    break;
                  }
                }
              }
              
              
              if (selectedCardDoc != null) {
                final cardData = selectedCardDoc.data() as Map<String, dynamic>;
                final cardNumber = cardData['cardNumber'] as String? ?? '';
                final lastFourDigits = cardNumber.length >= 4 
                    ? cardNumber.substring(cardNumber.length - 4) 
                    : '**';
                
                // حفظ بيانات الدفع
                paymentCardData = {
                  'cardName': cardData['cardName'] ?? '',
                  'cardNumber': cardNumber,
                  'expiry': cardData['expiry'] ?? '',
                };

                return _buildPaymentButtons(lastFourDigits);
              }
              
              return _buildPaymentButtons();
            },
          ),
        ],
        if (user == null) _buildPaymentButtons(),
      ],
    );
  }

  Widget _buildPaymentButtons([String? lastFourDigits]) {
    return Column(
      children: [
        // زر VISA مع شعار وكلمة CARD
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          child: ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentMethodPage(selectedCardId: selectedCardId),
                ),
              );
              
              if (result != null && result is String) {
                setState(() {
                  selectedCardId = result;
                });
                await _loadCardData(result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              elevation: 1,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              child: Row(
                children: [
                  Image.asset(
                    'assets/visa_logo.png',
                    height: 24,
                    width: 40,
                  ),
                  Container(
                    height: 20,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.grey.shade300,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('card_button'),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    lastFourDigits != null ? '•••• $lastFourDigits' : '•••• **',
                    style: const TextStyle(
                      color: Color(0xFF2A3E5F),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // زر Apple Pay
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
            },
            icon: const Icon(Icons.apple, color: Colors.black),
            label: Text(
              AppLocalizations.of(context).translate('apple_pay'),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              side: const BorderSide(color: Colors.black),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF2A3E5F),
            radius: 12,
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildImage(item.imagePath),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2A3E5F),
                  ),
                ),
                if (item.additionName != null && item.additionName!.isNotEmpty)
                  Text(
                    '${AppLocalizations.of(context).translate('addition')}: ${item.additionName} (+${item.additionPrice} SAR)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF2A3E5F),
                    ),
                  ),
                Text(
                  '${(item.price + item.additionPrice) * item.quantity} SAR',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2A3E5F),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2A3E5F)),
            onPressed: () => _editProduct(item),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => setState(() => cartItems.remove(item)),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String path) {
    return Image.network(
      path,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset('assets/placeholder.png', width: 50, height: 50),
    );
  }

  Widget _addMoreItemsButton() {
    return ElevatedButton.icon(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.add, color: Color(0xFF2A3E5F)),
      label: Text(
        AppLocalizations.of(context).translate('add_more_items'),
        style: const TextStyle(color: Color(0xFF2A3E5F)),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).translate('notes_hint'),
        hintStyle: const TextStyle(color: Color(0xFF2A3E5F)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A3E5F)),
        ),
      ),
    );
  }

  Widget _buildTotalSection(int total) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context).translate('total'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3E5F),
          ),
        ),
        Text(
          '$total SAR',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2A3E5F),
          ),
        ),
      ],
    );
  }

  Widget _placeOrderButton() {
    return ElevatedButton(
      onPressed: _placeOrder,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF728A9A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: const Size(double.infinity, 50),
      ),
      child: Text(
        AppLocalizations.of(context).translate('place_order'),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}