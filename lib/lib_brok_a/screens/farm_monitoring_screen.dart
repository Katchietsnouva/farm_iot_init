import 'package:food/lib_brok_a/components/drawer.dart';
import 'package:flutter/material.dart';
import 'package:food/lib_brok_a/main.dart' show themeNotifier;

import '../components/app_bar.dart';

import 'package:food/lib_brok_a/utils/screen_type.dart'
    show ScreenTypeDetector, ScreenType;
// Add this import

class FarmMonitoringApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return MaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   home: DashboardScreen(),
    // );
    return DashboardScreen();
  }
}

class AppColors {
  static Color getIoTTileColor(BuildContext context, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (type) {
      case "temperature":
        return isDark ? Colors.red.shade900 : Colors.red.shade50;
      case "moisture":
        return isDark ? Colors.blue.shade900 : Colors.blue.shade50;
      case "humidity":
        return isDark ? Colors.green.shade900 : Colors.green.shade50;
      case "light":
        return isDark ? Colors.yellow.shade700 : Colors.yellow.shade50;
      default:
        return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
    }
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).cardColor,
      // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // backgroundColor: Theme.of(context).colorScheme.surface,
      // backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // backgroundColor: Colors.red, // ← Add this line
      appBar: NouvaCustomAppBar(
        themeNotifier: themeNotifier,
        // onExportChat: _exportChat(),
      ),
      drawer: MyDrawerWidget(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeatherCard(context),
            SizedBox(height: 16.0),
            _buildQuickActions(),
            SizedBox(height: 16.0),
            _buildIotMonitoring(context),
            SizedBox(height: 16.0),
            _buildDroneStatus(),
            SizedBox(height: 16.0),
            _buildAIInsights(),
            SizedBox(height: 16.0),
            _buildRiskAssessment(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green[800]!, Colors.green[400]!],
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "22°C",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                // style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text("Partly Cloudy", style: TextStyle(color: Colors.white)),
            ],
          ),
          Icon(Icons.wb_sunny, color: Colors.white, size: 32),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Action",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 65,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _quickActionItem(Icons.sensors, "IoT Monitor"),
                SizedBox(width: 6),
                _quickActionItem(Icons.control_camera, "Drone Control"),
                SizedBox(width: 6),
                _quickActionItem(Icons.vrpano, "VR View"),
                SizedBox(width: 6),
                _quickActionItem(Icons.smart_toy, "AI Assist"),
                SizedBox(width: 6),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickActionItem(IconData icon, String label) {
    return AspectRatio(
      aspectRatio: 1.6 / 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [Icon(icon, size: 40, color: Colors.blue), Text(label)],
        ),
      ),
    );
  }

  // Widget _buildIotMonitoring(context) {
  Widget _buildIotMonitoring(BuildContext context) {
    final screenType = ScreenTypeDetector.of(context);
    int crossAxisCount;
    switch (screenType) {
      case ScreenType.mobile:
        crossAxisCount = 2;
        break;
      case ScreenType.tablet:
        crossAxisCount = 4;
        break;
      case ScreenType.desktop:
        crossAxisCount = 6;
        break;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "IoT Monitoring",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.0,
          children: [
            _iotTile(
              "warning_amber",
              "Soil Moisture",
              "65%",
              AppColors.getIoTTileColor(context, "moisture"),
            ),
            _iotTile(
              "thermostat",
              "Temperature",
              "22°C",
              AppColors.getIoTTileColor(context, "temperature"),
            ),
            _iotTile(
              "water_drop",
              "Humidity",
              "45%",
              AppColors.getIoTTileColor(context, "humidity"),
            ),
            _iotTile(
              "light",
              "Light",
              "850 lux",
              AppColors.getIoTTileColor(context, "light"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _iotTile(String iconName, title, String value, Color color) {
    Map<String, IconData> iconMap = {
      "warning_amber": Icons.warning_amber,
      "thermostat": Icons.thermostat,
      "water_drop": Icons.water_drop,
      "light": Icons.light_mode_rounded,
    };

    return Container(
      padding: EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(iconMap[iconName]),
              SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 14)),
            ],
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDroneStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Drone Status",
          style: (TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.airplanemode_active, color: Colors.green),
                title: Text("DJI Phantom 4"),
                subtitle: Text("Ready to fly"),
                trailing: Text("Active", style: TextStyle(color: Colors.green)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "AI Insights",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(
                  Icons.insights_outlined,
                  color: Colors.green.shade900,
                ),
                title: Text("Crop Health Alert"),
                subtitle: Text(
                  "Potential pest infestation detected in Section B.",
                ),
              ),

              // ElevatedButton(onPressed: () {}, child: Text("View Details")),
              ElevatedButton(
                onPressed: () {},
                child: Text(
                  "View Details",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 36),
                  backgroundColor: Color.fromRGBO(39, 140, 39, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRiskAssessment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Risk Assessment",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 100,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _riskTile(
                  "warning_amber",
                  "Pest Risk",
                  "Low",
                  Colors.green.shade50,
                ),
                _riskTile(
                  "thermostat",
                  "Heat Stress",
                  "Medium",
                  Colors.yellow.shade50,
                ),
                _riskTile("water_drop", "Drought", "Low", Colors.blue.shade50),
                _riskTile(
                  "light",
                  "Light Intensity",
                  "Low",
                  Colors.blue.shade50,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _riskTile(String iconName, String title, String level, Color color) {
    Map<String, IconData> iconMap = {
      "warning_amber": Icons.warning_amber,
      "thermostat": Icons.thermostat,
      "water_drop": Icons.water_drop,
      "light": Icons.light_mode_rounded,
    };

    return AspectRatio(
      aspectRatio: 1.6 / 1.0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(iconMap[iconName]),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(level, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}









// import 'package:flutter/material.dart';
// import 'package:food/lib_brok_a/components/drawer.dart';
// import 'package:food/lib_brok_a/main.dart' show themeNotifier;
// import 'package:food/lib_brok_a/components/app_bar.dart';
// import 'package:food/lib_brok_a/utils/screen_type.dart'
//     show ScreenTypeDetector, ScreenType;

// class FarmMonitoringApp extends StatelessWidget {
//   const FarmMonitoringApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const DashboardScreen();
//   }
// }

// class AppColors {
//   static Color getIoTTileColor(BuildContext context, String type) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final colorScheme = Theme.of(context).colorScheme;

//     switch (type) {
//       case "temperature":
//         return isDark
//             ? colorScheme.error.withOpacity(0.2)
//             : colorScheme.error.withOpacity(0.1);
//       case "moisture":
//         return isDark
//             ? colorScheme.primary.withOpacity(0.2)
//             : colorScheme.primary.withOpacity(0.1);
//       case "humidity":
//         return isDark
//             ? colorScheme.secondary.withOpacity(0.2)
//             : colorScheme.secondary.withOpacity(0.1);
//       case "light":
//         return isDark
//             ? Colors.yellow.shade700.withOpacity(0.2)
//             : Colors.yellow.shade100.withOpacity(0.1);
//       default:
//         return isDark
//             ? colorScheme.surface.withOpacity(0.5)
//             : colorScheme.surface.withOpacity(0.3);
//     }
//   }

//   static LinearGradient getWeatherCardGradient(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return LinearGradient(
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//       colors:
//           isDark
//               ? [
//                 const Color(0xFF00FF99).withOpacity(0.7),
//                 const Color(0xFF121212),
//               ]
//               : [
//                 const Color(0xFF00D4FF).withOpacity(0.7),
//                 const Color(0xFF0A0E21),
//               ],
//     );
//   }
// }

// class DashboardScreen extends StatelessWidget {
//   const DashboardScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       appBar: NouvaCustomAppBar(themeNotifier: themeNotifier),
//       drawer: const MyDrawerWidget(),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildWeatherCard(context),
//             const SizedBox(height: 16.0),
//             _buildQuickActions(context),
//             const SizedBox(height: 16.0),
//             _buildIotMonitoring(context),
//             const SizedBox(height: 16.0),
//             _buildDroneStatus(context),
//             const SizedBox(height: 16.0),
//             _buildAIInsights(context),
//             const SizedBox(height: 16.0),
//             _buildRiskAssessment(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildWeatherCard(BuildContext context) {
//     final theme = Theme.of(context);
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         gradient: AppColors.getWeatherCardGradient(context),
//         borderRadius: BorderRadius.circular(16.0),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "22°C",
//                 style: theme.textTheme.headlineSmall?.copyWith(
//                   color: Colors.white,
//                 ),
//               ),
//               Text(
//                 "Partly Cloudy",
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   color: Colors.white70,
//                 ),
//               ),
//             ],
//           ),
//           Icon(Icons.wb_sunny, color: theme.colorScheme.secondary, size: 32),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActions(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Quick Action",
//           style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 65,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _quickActionItem(context, Icons.sensors, "IoT Monitor"),
//                 const SizedBox(width: 6),
//                 _quickActionItem(
//                   context,
//                   Icons.control_camera,
//                   "Drone Control",
//                 ),
//                 const SizedBox(width: 6),
//                 _quickActionItem(context, Icons.vrpano, "VR View"),
//                 const SizedBox(width: 6),
//                 _quickActionItem(context, Icons.smart_toy, "AI Assist"),
//                 const SizedBox(width: 6),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _quickActionItem(BuildContext context, IconData icon, String label) {
//     final theme = Theme.of(context);
//     return AspectRatio(
//       aspectRatio: 1.6 / 1.0,
//       child: Container(
//         decoration: BoxDecoration(
//           color: theme.cardColor,
//           borderRadius: BorderRadius.circular(12.0),
//           boxShadow: [
//             BoxShadow(
//               color: theme.colorScheme.primary.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, size: 40, color: theme.colorScheme.primary),
//             Text(
//               label,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildIotMonitoring(BuildContext context) {
//     final screenType = ScreenTypeDetector.of(context);
//     final theme = Theme.of(context);
//     int crossAxisCount;
//     switch (screenType) {
//       case ScreenType.mobile:
//         crossAxisCount = 2;
//         break;
//       case ScreenType.tablet:
//         crossAxisCount = 4;
//         break;
//       case ScreenType.desktop:
//         crossAxisCount = 6;
//         break;
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "IoT Monitoring",
//           style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
//         ),
//         const SizedBox(height: 8),
//         GridView.count(
//           shrinkWrap: true,
//           crossAxisCount: crossAxisCount,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: 2.0,
//           physics: const NeverScrollableScrollPhysics(),
//           children: [
//             _iotTile(
//               context,
//               "warning_amber",
//               "Soil Moisture",
//               "65%",
//               AppColors.getIoTTileColor(context, "moisture"),
//             ),
//             _iotTile(
//               context,
//               "thermostat",
//               "Temperature",
//               "22°C",
//               AppColors.getIoTTileColor(context, "temperature"),
//             ),
//             _iotTile(
//               context,
//               "water_drop",
//               "Humidity",
//               "45%",
//               AppColors.getIoTTileColor(context, "humidity"),
//             ),
//             _iotTile(
//               context,
//               "light",
//               "Light",
//               "850 lux",
//               AppColors.getIoTTileColor(context, "light"),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _iotTile(
//     BuildContext context,
//     String iconName,
//     String title,
//     String value,
//     Color color,
//   ) {
//     final theme = Theme.of(context);
//     Map<String, IconData> iconMap = {
//       "warning_amber": Icons.warning_amber,
//       "thermostat": Icons.thermostat,
//       "water_drop": Icons.water_drop,
//       "light": Icons.light_mode_rounded,
//     };

//     return Container(
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(12.0),
//         boxShadow: [
//           BoxShadow(
//             color: theme.colorScheme.primary.withOpacity(0.2),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(iconMap[iconName], color: theme.colorScheme.primary),
//               const SizedBox(width: 10),
//               Text(
//                 title,
//                 style: theme.textTheme.bodyMedium?.copyWith(
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 5),
//           Text(
//             value,
//             style: theme.textTheme.bodyLarge?.copyWith(
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDroneStatus(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Drone Status",
//           style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             color: theme.cardColor,
//             borderRadius: BorderRadius.circular(12.0),
//             boxShadow: [
//               BoxShadow(
//                 color: theme.colorScheme.primary.withOpacity(0.2),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ListTile(
//             leading: Icon(
//               Icons.airplanemode_active,
//               color: theme.colorScheme.primary,
//             ),
//             title: Text("DJI Phantom 4", style: theme.textTheme.bodyLarge),
//             subtitle: Text("Ready to fly", style: theme.textTheme.bodyMedium),
//             trailing: Text(
//               "Active",
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 color: theme.colorScheme.primary,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildAIInsights(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "AI Insights",
//           style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
//         ),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             color: theme.cardColor,
//             borderRadius: BorderRadius.circular(12.0),
//             boxShadow: [
//               BoxShadow(
//                 color: theme.colorScheme.primary.withOpacity(0.2),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               ListTile(
//                 leading: Icon(
//                   Icons.insights_outlined,
//                   color: theme.colorScheme.primary,
//                 ),
//                 title: Text(
//                   "Crop Health Alert",
//                   style: theme.textTheme.bodyLarge,
//                 ),
//                 subtitle: Text(
//                   "Potential pest infestation detected in Section B.",
//                   style: theme.textTheme.bodyMedium,
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 36),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8.0),
//                   ),
//                 ),
//                 child: Text(
//                   "View Details",
//                   style: theme.textTheme.bodyMedium?.copyWith(
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildRiskAssessment(BuildContext context) {
//     final theme = Theme.of(context);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Risk Assessment",
//           style: theme.textTheme.headlineSmall?.copyWith(fontSize: 18),
//         ),
//         const SizedBox(height: 8),
//         SizedBox(
//           height: 100,
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: [
//                 _riskTile(
//                   context,
//                   "warning_amber",
//                   "Pest Risk",
//                   "Low",
//                   AppColors.getIoTTileColor(context, "humidity"),
//                 ),
//                 _riskTile(
//                   context,
//                   "thermostat",
//                   "Heat Stress",
//                   "Medium",
//                   AppColors.getIoTTileColor(context, "temperature"),
//                 ),
//                 _riskTile(
//                   context,
//                   "water_drop",
//                   "Drought",
//                   "Low",
//                   AppColors.getIoTTileColor(context, "moisture"),
//                 ),
//                 _riskTile(
//                   context,
//                   "light",
//                   "Light Intensity",
//                   "Low",
//                   AppColors.getIoTTileColor(context, "light"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _riskTile(
//     BuildContext context,
//     String iconName,
//     String title,
//     String level,
//     Color color,
//   ) {
//     final theme = Theme.of(context);
//     Map<String, IconData> iconMap = {
//       "warning_amber": Icons.warning_amber,
//       "thermostat": Icons.thermostat,
//       "water_drop": Icons.water_drop,
//       "light": Icons.light_mode_rounded,
//     };

//     return AspectRatio(
//       aspectRatio: 1.6 / 1.0,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8.0),
//         padding: const EdgeInsets.all(12.0),
//         decoration: BoxDecoration(
//           color: color,
//           borderRadius: BorderRadius.circular(12.0),
//           boxShadow: [
//             BoxShadow(
//               color: theme.colorScheme.primary.withOpacity(0.2),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Icon(iconMap[iconName], color: theme.colorScheme.primary),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               style: theme.textTheme.bodyMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             Text(level, style: theme.textTheme.bodyLarge),
//           ],
//         ),
//       ),
//     );
//   }
// } 
