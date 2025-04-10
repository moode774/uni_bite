import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:uni_bite/Pages/clientPage/account.dart';
import 'package:uni_bite/Pages/login.dart';
import 'package:uni_bite/Pages/Languge.dart';
import 'payment_methods_page.dart';
import 'package:uni_bite/localization/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedLanguage = "العربية";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5F0),
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("profile"),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A3E5F)),
        ),
      ),
      body: buildProfileView(),
    );
  }

  Widget buildProfileView() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const CircleAvatar(
          radius: 50,
          backgroundColor: Color(0xFF4B606B),
          child: Icon(Icons.person, size: 50, color: Colors.white),
        ),
        const SizedBox(height: 20),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return Text(AppLocalizations.of(context).translate("error_loading_user"));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text(AppLocalizations.of(context).translate("user_not_found"));
            }

            var userData = snapshot.data!;
            String firstName = userData['first_name'] ?? AppLocalizations.of(context).translate("not_specified");

            return Text(
              firstName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A3E5F)),
            );
          },
        ),
        const SizedBox(height: 30),
        Expanded(
          child: ListView(
            children: [
              _buildRoundedContainer(
                child: buildProfileOption(Icons.account_circle, AppLocalizations.of(context).translate("account_settings"), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AccountSettingsPage()),
                  );
                }),
              ),
              _buildRoundedContainer(
                child: buildProfileOption(Icons.language, AppLocalizations.of(context).translate("language"), () {
                  Navigator.push(
                    context,
  MaterialPageRoute(builder: (context) => const LanguagePage(),
  ),                  );
                }),
              ),
              _buildRoundedContainer(
                child: buildProfileOption(Icons.help, AppLocalizations.of(context).translate("help_center"), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HelpCenterPage()),
                  );
                }),
              ),
              _buildRoundedContainer(
                child: buildProfileOption(Icons.help, AppLocalizations.of(context).translate("payment_methods"), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PaymentMethodPage()),
                  );
                }),
              ),
              _buildRoundedContainer(
                child: buildProfileOption(Icons.exit_to_app, AppLocalizations.of(context).translate("sign_out"), _showSignOutBottomSheet),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSignOutBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).translate("sign_out_confirmation")),
            ElevatedButton(onPressed: _signOut, child: Text(AppLocalizations.of(context).translate("sign_out"))),
            TextButton(onPressed: () => Navigator.pop(context), child: Text(AppLocalizations.of(context).translate("cancel"))),
          ],
        ),
      ),
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  LoginForm()),
    );
  }

  Widget _buildRoundedContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 5,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6B7DAF)),
      title: Text(title, style: const TextStyle(fontSize: 18, color: Color(0xFF2A3E5F))),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Color(0xFF6B7DAF)),
    );
  }
}

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 255, 241, 241),
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context).translate("help_center"),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2A3E5F)),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 241, 241),
      body: Center(
        child: Column(
          children: [
            Image.asset(
              'assets/Admin.png',
              width: 250,
              height: 300,
            ),
            const SizedBox(height: 40),
            Text(
              AppLocalizations.of(context).translate("contact_us_message"),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Color(0xFF2A3E5F)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openOutlook,
              child: Text(AppLocalizations.of(context).translate("contact_via_outlook")),
            ),
          ],
        ),
      ),
    );
  }

  void _openOutlook() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'mwwm99@outlook.sa',
      queryParameters: {'subject': 'Customer Inquiry'},
    );
    // Logic to open email
  }
}