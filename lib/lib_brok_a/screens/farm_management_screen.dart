import 'package:flutter/material.dart';

class FarmManagementScreen extends StatelessWidget {
  const FarmManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Farm Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Monitor and manage your farm devices here.'),
        ],
      ),
    );
  }
}
