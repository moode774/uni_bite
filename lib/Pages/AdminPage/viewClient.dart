import 'package:flutter/material.dart';

class ViewClientsPage extends StatelessWidget {
  const ViewClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Clients")),
      body: const Center(
        child: Text("View Clients Page"),
      ),
    );
  }
}