import 'package:flutter/material.dart';

class CameraDroneScreen extends StatelessWidget {
  const CameraDroneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text(
            'Camera & Drone Management',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('Monitor farm cameras and control drones.'),
        ],
      ),
    );
  }
}
