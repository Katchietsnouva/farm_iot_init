import 'package:broka/lib_tikto_k/tiktok_components/TikTokHomeScreen.dart';
import 'package:flutter/material.dart';
// import 'home_screen.dart';

void main() {
  runApp(const TikTokMockApp());
}

class TikTokMockApp extends StatelessWidget {
  const TikTokMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TikTokHomeScreen(),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'screens/home_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Broka App',
//       theme: ThemeData(
//         // colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }
