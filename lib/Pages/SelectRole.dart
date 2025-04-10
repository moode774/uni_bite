import 'package:flutter/material.dart';

class SelectRolePage extends StatelessWidget {
  const SelectRolePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // color: Color.fromARGB(255, 248, 240, 237),
          color: Color(0xFFFFF5F0),
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/MM.png',
            ),
            const SizedBox(height: 40),
            const Text(
              "Welcome to UniBite!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
// color: Color(0xFF35567C)
                color: Color(0xFF778CAB),
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Choose an option to access tailored features",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w500,
// color: Color(0xFF35567C)
                color: Color(0xFF778CAB),
              ),
            ),
            const SizedBox(height: 60),
            //3 card 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRoleButton(context, 'Client', 'assets/vcc3.png',
                    '/login'), // التوجيه إلى صفحة الدخول مع الصورة
                const SizedBox(width: 20),
                _buildRoleButton(context, 'Facility', 'assets/viewf2.png',
                    '/FacilitySignup'), // التوجيه إلى صفحة
                const SizedBox(width: 20),
                _buildRoleButton(context, 'Admin', 'assets/Admin.png',
                    '/AdminLogin'), // التوجيه إلى صفحة الدخول
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context, String title, String imagePath, String route) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushNamed(context, route); //   التنقل إلى الصفحة المحددة بناء ع الروت الي حددته فوق
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFEFD8D0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 22),
        elevation: 3,
      ),
      child: Column(
        children: [
          Image.asset(
            imagePath,
            width: 60, // تحديد العرض لصورة
            height: 60, // تحديد الارتفاع لصور 
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w400,
              color: Color(0xFF2A3E5F),
            ),
          ),
        ],
      ),
    );
  }
}
