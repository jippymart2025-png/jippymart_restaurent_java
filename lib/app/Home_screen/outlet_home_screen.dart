import 'package:flutter/material.dart';

class OutletHomeScreen extends StatelessWidget {
  const OutletHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Outlet Dashboard"),
      ),
      body: const Center(
        child: Text(
          "Waiting For Orders",
        ),
      ),
    );
  }
}