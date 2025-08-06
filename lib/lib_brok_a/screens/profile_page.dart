import 'package:flutter/material.dart';
import 'package:food/lib_brok_a/main.dart' show themeNotifier;
import '../components/app_bar.dart';

import 'package:food/lib_brok_a/components/drawer.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Profile")),
      appBar: NouvaCustomAppBar(
        themeNotifier: themeNotifier,
        // onExportChat: _exportChat(),
      ),
      drawer: MyDrawerWidget(),
      body: const Center(
        child: Text("Profile Page ", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Settings")),
      appBar: NouvaCustomAppBar(
        themeNotifier: themeNotifier,
        // onExportChat: _exportChat(),
      ),
      body: const Center(
        child: Text("Settings Page ", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("About")),
      appBar: NouvaCustomAppBar(
        themeNotifier: themeNotifier,
        // onExportChat: _exportChat(),
      ),
      body: const Center(
        child: Text("About Page ", style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
