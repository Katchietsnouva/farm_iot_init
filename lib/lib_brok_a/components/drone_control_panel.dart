import 'package:flutter/material.dart';

class DroneControlPanel extends StatelessWidget {
  const DroneControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              print('Drone Takeoff');
            },
            child: const Text('Takeoff'),
          ),
          ElevatedButton(
            onPressed: () {
              print('Drone Land');
            },
            child: const Text('Land'),
          ),
          ElevatedButton(
            onPressed: () {
              print('Set Path');
            },
            child: const Text('Set Path'),
          ),
        ],
      ),
    );
  }
}
