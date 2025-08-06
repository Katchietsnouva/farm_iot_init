import 'package:flutter/material.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onTap,
      backgroundColor:
          Colors.blueGrey, // Change the background color to something darker
      selectedItemColor: Colors.black, // Color for the selected icon
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.agriculture),
          label: 'Farm',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.devices),
          label: 'Devices',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          label: 'AI Chat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Camera/Drone',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sync_disabled_outlined),
          label: 'IoT',
        ),
      ],
    );
  }
}
