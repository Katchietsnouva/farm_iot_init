import 'package:flutter/material.dart';
import 'package:food/lib_brok_a/screens/chat_screen_caller.dart';
import 'package:food/lib_brok_a/utils/screen_type.dart' show ScreenTypeDetector;
import 'farm_management_screen.dart';
import 'farm_monitoring_screen.dart';
import '../components/navigation_bar.dart';
// import 'ai_chat_screen.dart';
import 'devices_screen.dart';
import 'camera_drone_screen.dart';
import 'dash_board_screen_2.dart';
// import 'real_time_charts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    FarmMonitoringApp(),
    DashboardScreen_2_screen(),
    // AIChatScreen(),
    // AIChatApp(),
    const DevicesScreen(),
    const CameraDroneScreen(),
    const FarmManagementScreen(),
    const FarmManagementScreen(),
    // const RealTimeChartsScreen()
  ];

  void _onNavBarTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenType = ScreenTypeDetector.of(context);
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Broka Farm App'),
      //   backgroundColor: Colors.white, // AppBar color to white
      // ),
      body: _pages[_selectedIndex],
      // body: Center(
      //   child: Text(
      //     'Screen Type: ${screenType.toString().split('.').last}',
      //     style: const TextStyle(fontSize: 24),
      //   ),
      // ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: _onNavBarTap,
      ),
    );
  }
}
