import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/model/cart_data.dart';

class AddPayment extends StatefulWidget {
  const AddPayment({super.key});

  @override
  _AddPaymentState createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  bool saveCard = false;
  bool isLoading = false; // For loading indicator
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  @override
  void dispose() {
    _cardNameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    final cardNumber = _cardNumberController.text.replaceAll(' ', '');
    final expiry = _expiryController.text;
    final cvv = _cvvController.text;

    if (_cardNameController.text.trim().isEmpty ||
        cardNumber.isEmpty ||
        expiry.isEmpty ||
        cvv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return false;
    }

    if (cardNumber.length != 16 || !RegExp(r'^[0-9]+$').hasMatch(cardNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid card number')),
      );
      return false;
    }

    if (!RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(expiry)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid expiry date (MM/YY)')),
      );
      return false;
    }

    if (cvv.length != 3 || !RegExp(r'^[0-9]+$').hasMatch(cvv)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid CVV')),
      );
      return false;
    }

    return true;
  }

  Future<void> _saveCardToFirestore() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to save card')),
      );
      return;
    }

    if (!_validateInputs()) return;

    setState(() => isLoading = true);

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('payment_cards')
          .add({
        'cardName': _cardNameController.text.trim(),
        'cardNumber': _cardNumberController.text.trim(),
        'expiry': _expiryController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      paymentCardData = {
        "cardName": _cardNameController.text.trim(),
        "cardNumber": _cardNumberController.text.trim(),
        "expiry": _expiryController.text.trim(),
        "save": saveCard,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving card: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F5EF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Payment Card",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Add your card details",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Name on card", "John Doe", _cardNameController),
                  const SizedBox(height: 15),
                  _buildTextField(
                    "Card Number",
                    "1234 5678 9012 3456",
                    _cardNumberController,
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    onChanged: (value) {
                      if (value.length % 5 == 4 &&
                          value.length < 19 &&
                          !value.endsWith(' ')) {
                        _cardNumberController.text = value + ' ';
                        _cardNumberController.selection = TextSelection.fromPosition(
                          TextPosition(offset: _cardNumberController.text.length),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Expiry date",
                          "MM/YY",
                          _expiryController,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          onChanged: (value) {
                            if (value.length == 2 && !value.contains('/')) {
                              _expiryController.text = value + '/';
                              _expiryController.selection = TextSelection.fromPosition(
                                TextPosition(offset: _expiryController.text.length),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          "CVV",
                          "123",
                          _cvvController,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Checkbox(
                        value: saveCard,
                        activeColor: Colors.blueGrey,
                        onChanged: (value) {
                          setState(() => saveCard = value!);
                        },
                      ),
                      const Text(
                        "Save Card",
                        style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildButton("Cancel", Colors.white, Colors.black, () {
                        Navigator.pop(context);
                      }),
                      _buildButton("Add", Colors.blueGrey, Colors.white, _saveCardToFirestore),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hintText,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int? maxLength,
    bool obscureText = false,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontSize: 16, color: Colors.black54),
            filled: true,
            fillColor: Colors.white,
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blueGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blueGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blueGrey, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(String text, Color background, Color textColor, Function() onPressed) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed, 
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: background == Colors.white ? Colors.blueGrey : background),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}