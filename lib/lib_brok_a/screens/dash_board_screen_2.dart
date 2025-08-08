import 'package:food/lib_brok_a/components/drawer.dart';
import 'package:flutter/material.dart';
import 'package:food/lib_brok_a/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../components/app_bar.dart';

void main() {
  runApp(DashboardScreen_2_screen());
}

class DashboardScreen_2_screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardScreen_2(),
    );
  }
}

class DashboardScreen_2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Calculate available width for two tiles per row with 16px padding and 10px spacing.
    final double tileWidth = (MediaQuery.of(context).size.width - 32 - 10) / 2;
    return Scaffold(
      appBar: NouvaCustomAppBar(
        themeNotifier: themeNotifier,
        // onExportChat: _exportChat(),
      ),
      drawer: MyDrawerWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Tiles using Wrap
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: DashboardTile(
                      'IoT Monitoring',
                      Icons.speed,
                      Colors.blue.shade50,
                      Colors.blue.shade500,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: DashboardTile(
                      'Drone Control',
                      Icons.control_camera,
                      Colors.green.shade50,
                      Colors.green.shade500,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: DashboardTile(
                      'VR View',
                      Icons.vrpano,
                      Colors.purple.shade50,
                      Colors.purple.shade500,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: DashboardTile(
                      'AI Assistant',
                      Icons.smart_toy,
                      Colors.orange.shade50,
                      Colors.orange.shade500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // GridView.count(
              //   crossAxisCount: 2,
              //   shrinkWrap: true,
              //   crossAxisSpacing: 10,
              //   childAspectRatio: 2,
              //   mainAxisSpacing: 10,
              //   children: [
              //     FeatureCard(title: 'IoT Monitoring', icon: Iconsax.chart),
              //     FeatureCard(title: 'Drone Control', icon: Iconsax.airplane),
              //     FeatureCard(title: 'VR View', icon: Iconsax.glass4),
              //     FeatureCard(title: 'AI Assistant', icon: Iconsax.cpu),
              //   ],
              // ),
              // SizedBox(height: 10),

              // Wrap(
              //   spacing: 10,
              //   runSpacing: 10,
              //   children: [
              //     SizedBox(
              //       width: tileWidth,
              //       child:
              //           MonitoringCard('Temperature', '22°C', Icons.thermostat),
              //     ),
              //   ],
              // ),
              Text(
                'Real-time Monitoring',
                // style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                crossAxisSpacing: 10,
                childAspectRatio: 1.5,
                mainAxisSpacing: 10,
                children: [
                  InfoCard(
                    title: 'Temperature',
                    value: '22°C',
                    icon: Icons.thermostat,
                  ),
                  InfoCard(
                    title: 'Soil Moisture',
                    value: '65%',
                    icon: Icons.water_drop,
                  ),
                  InfoCard(title: 'Humidity', value: '78%', icon: Icons.air),
                  InfoCard(
                    title: 'Light',
                    value: '850 lux',
                    icon: Icons.wb_sunny,
                  ),
                ],
              ),
              SizedBox(height: 20),

              SizedBox(height: 20),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Text('Map View Placeholder')),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ActionButton('Start Drone', Icons.flight_takeoff),
                  ActionButton('Check Sensors', Icons.sensors),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Recent Activities',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ActivityItem(
                'Drone Mission Completed',
                'Field inspection completed successfully',
                Icons.check_circle,
                Colors.green,
              ),
              SizedBox(height: 10),
              ActivityItem(
                'Moisture Alert',
                'Section B requires irrigation',
                Icons.warning,
                Colors.orange,
              ),
              SizedBox(height: 10),
              ActivityItem(
                'AI Analysis',
                'Crop health report generated',
                Icons.analytics,
                Colors.blue,
              ),
              SizedBox(height: 20), // Extra bottom padding if needed.
              // Expanded(
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/user.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Replace Iconsax.airdrop1 with a valid icon, e.g., Iconsax.airdrop
                  ActionButtonn(text: 'Start Drone', icon: Iconsax.airdrop),
                  // Replace Iconsax.send1 with a valid icon, e.g., Iconsax.send
                  ActionButtonn(text: 'Check Sensors', icon: Iconsax.send),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.speed), label: 'Monitor'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Control'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final IconData icon;

  FeatureCard({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          SizedBox(height: 10),
          // Text(title, style: GoogleFonts.poppins(fontSize: 16)),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  InfoCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(height: 10),
          // Text(title, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 5),
          // Text(value, style: GoogleFonts.poppins( fontSize: 18, fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Roboto',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtonn extends StatelessWidget {
  final String text;
  final IconData icon;

  ActionButtonn({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(text, style: GoogleFonts.poppins(fontSize: 14)),
    );
  }
}

class DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Color colorIcon;

  DashboardTile(this.title, this.icon, this.color, this.colorIcon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: colorIcon),
            SizedBox(height: 5),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class MonitoringCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  MonitoringCard(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30),
            SizedBox(height: 5),
            Text(title),
            Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;

  ActionButton(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class ActivityItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  ActivityItem(this.title, this.subtitle, this.icon, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.shade200,
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}
