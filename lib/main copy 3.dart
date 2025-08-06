// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:food/lib_brok_a/screens/ai_chat_screen.dart';

// import 'lib_brok_a/main.dart' as brok_a;
// // import 'lib_tikto_k/main.dart' as tikto_k;
// // import 'lib_famil_y/main.dart' as famil_y;
// // import 'lib_tod_o_app/main.dart' as tod_o_app;
// // import 'lib_profil_e/main.dart' as profil_e;
// // import 'lib_chatap_p/main.dart' as chatap_p;
// // import 'lib_insta_app/main.dart' as insta_app;
// // import 'lib_flemo_ap_p/main.dart' as flemo_ap_p;
// // import 'lib_nouva_neon_ap_p/main.dart' as nouva_neon_ap_p;
// // import 'lib_nouva_neon_ap_p_2/main.dart' as nouva_neon_ap_p_2;
// // import 'lib_nouva_neon_ap_p_3/main.dart' as nouva_neon_ap_p_3;
// // import 'lib_broka/main.dart' as broka;

// // void main() {
// //   brok_a.main();
// //   // tikto_k.main();
// //   // famil_y.main();
// //   // tod_o_app.main();
// //   // profil_e.main();
// //   // chatap_p.main();
// //   // insta_app.main();
// //   // flemo_ap_p.main();
// //   // nouva_neon_ap_p.main();
// //   // nouva_neon_ap_p_2.main();
// //   // nouva_neon_ap_p_3.main();
// //   // broka.main();
// // }

// // void main() async {
// //   await dotenv.load(fileName: ".env");
// //   runApp(AIChatScreen());
// //   // AIChatScreen();
// // }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await dotenv.load(fileName: ".env");
//     print("API Key: ${dotenv.env['OPENAI_API_KEY']}"); // ✅ Test output
//     print("API Key: ${dotenv.env['OPENAI_API_KEY']}"); // ✅ Test output
//   } catch (e) {
//     print("Could not load .env file: $e");
//   }
//   runApp(AIChatScreen());
// }

// #######################################################

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:food/lib_brok_a/models/chat_message.dart';
// import 'package:food/lib_brok_a/screens/chat_screen.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';

// // Import Model and Screen
// // import 'models/chat_message.dart'; // Import ChatMessage for adapter registration
// // import 'screens/chat_screen.dart'; // Import the main screen

// // Generated Hive adapter file (relative path from main.dart)
// // Make sure this matches the location of chat_message.dart
// // part './lib_brok_a/models/chat_message.g.dart'; // Use relative path based on file structure
// // part 'chat_message.g.dart'; // ✅ Correct place to include the generated file

// // lib/lib_brok_a/models/chat_message.g.dart
// // lib/main.dart
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await dotenv.load();

//   // Hive Initialization
//   try {
//     final appDocumentDir = await getApplicationDocumentsDirectory();
//     await Hive.initFlutter(appDocumentDir.path);
//     Hive.registerAdapter(
//       ChatMessageAdapter(),
//     ); // Register adapter from chat_message.dart
//     await Hive.openBox<ChatMessage>('chatMessages'); // Open the box
//     debugPrint("Hive initialized successfully at ${appDocumentDir.path}");
//   } catch (e) {
//     debugPrint("Error initializing Hive: $e");
//     // Handle Hive initialization error (e.g., show error message, exit app)
//     // For now, we'll print the error and continue, but a real app should handle this
//   }

//   runApp(AIChatApp());
// }

// class AIChatApp extends StatelessWidget {
//   const AIChatApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Farm Assistant Chat',
//       theme: ThemeData(
//         primarySwatch: Colors.green, // Example theme color
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.greenAccent,
//         ), // Modern color scheme
//         useMaterial3: true, // Enable Material 3 features
//         // Define card color explicitly if needed for input field background consistency
//         cardColor: Colors.white, // Or determine based on brightness
//         scaffoldBackgroundColor: Colors.grey.shade100, // Light background
//       ),
//       darkTheme: ThemeData(
//         brightness: Brightness.dark,
//         primarySwatch: Colors.green,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.greenAccent,
//           brightness: Brightness.dark,
//         ),
//         useMaterial3: true,
//         cardColor: Colors.grey.shade900, // Dark card color
//         scaffoldBackgroundColor: Colors.black, // Dark background
//       ),
//       themeMode: ThemeMode.system, // Or ThemeMode.light / ThemeMode.dark
//       debugShowCheckedModeBanner: false,
//       home: ChatScreen(), // Start with the chat screen
//     );
//   }
// }

// #######################################################

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:food/lib_brok_a/models/chat_message.dart';
// import 'package:food/lib_brok_a/screens/chat_screen.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
// import 'package:permission_handler/permission_handler.dart';
// import 'lib_brok_a/main.dart' as brok_a;

// // --- Theme Notifier ---
// // Global ValueNotifier to hold the current theme mode
// // We make it accessible globally for simplicity in this example.
// // In larger apps, consider Provider, Riverpod, etc.
// final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
// // Key for storing theme preference
// const String themePreferenceKey = 'app_theme_mode';
// // --- End Theme Notifier ---

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await _requestPermissions();
//   await dotenv.load();

//   // --- Load Theme Preference ---
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     final String? savedTheme = prefs.getString(themePreferenceKey);
//     if (savedTheme == 'light') {
//       themeNotifier.value = ThemeMode.light;
//     } else if (savedTheme == 'dark') {
//       themeNotifier.value = ThemeMode.dark;
//     } else {
//       themeNotifier.value = ThemeMode.system;
//     }
//   } catch (e) {
//     debugPrint("Error loading theme preference: $e");
//     themeNotifier.value = ThemeMode.system; // Default on error
//   }
//   // --- End Load Theme Preference ---

//   // Hive Initialization (keep as before)
//   try {
//     final appDocumentDir = await getApplicationDocumentsDirectory();
//     await Hive.initFlutter(appDocumentDir.path);
//     // Check if adapter is already registered before registering
//     if (!Hive.isAdapterRegistered(ChatMessageAdapter().typeId)) {
//       Hive.registerAdapter(ChatMessageAdapter());
//     }
//     // Check if box is already open before opening
//     if (!Hive.isBoxOpen('chatMessages')) {
//       await Hive.openBox<ChatMessage>('chatMessages');
//     }
//     debugPrint("Hive initialized successfully at ${appDocumentDir.path}");
//   } catch (e) {
//     debugPrint("Error initializing Hive: $e");
//   }
//   brok_a.main();

//   runApp(AIChatApp());
// }

// class AIChatApp extends StatelessWidget {
//   const AIChatApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // --- Listen to Theme Notifier ---
//     return ValueListenableBuilder<ThemeMode>(
//       valueListenable: themeNotifier,
//       builder: (_, currentMode, __) {
//         // --- Return MaterialApp ---
//         return MaterialApp(
//           title: 'Farm Assistant Chat',
//           theme: ThemeData(
//             // Light Theme configuration
//             brightness: Brightness.light,
//             primarySwatch: Colors.green,
//             colorScheme: ColorScheme.fromSeed(
//               seedColor: Colors.greenAccent,
//               brightness: Brightness.light,
//             ),
//             useMaterial3: true,
//             cardColor: Colors.white,
//             scaffoldBackgroundColor: Colors.grey.shade100,
//           ),
//           darkTheme: ThemeData(
//             // Dark Theme configuration
//             brightness: Brightness.dark,
//             primarySwatch: Colors.green,
//             colorScheme: ColorScheme.fromSeed(
//               seedColor: Colors.greenAccent,
//               brightness: Brightness.dark,
//             ),
//             useMaterial3: true,
//             cardColor: Colors.grey.shade900,
//             scaffoldBackgroundColor: Colors.black,
//           ),
//           themeMode: currentMode, // Use the current mode from the notifier
//           debugShowCheckedModeBanner: false,
//           home: ChatScreen(),
//         );
//         // --- End Return MaterialApp ---
//       },
//     );
//     // --- End Listen to Theme Notifier ---
//   }
// }

// // Helper function to save theme preference
// Future<void> saveThemePreference(ThemeMode mode) async {
//   try {
//     final prefs = await SharedPreferences.getInstance();
//     String valueToSave;
//     if (mode == ThemeMode.light) {
//       valueToSave = 'light';
//     } else if (mode == ThemeMode.dark) {
//       valueToSave = 'dark';
//     } else {
//       valueToSave = 'system';
//     }
//     await prefs.setString(themePreferenceKey, valueToSave);
//   } catch (e) {
//     debugPrint("Error saving theme preference: $e");
//   }
// }

// Future<void> _requestPermissions() async {
//   // Request both read and write permissions
//   final statuses = await [Permission.storage].request();

//   if (statuses[Permission.storage]!.isDenied) {
//     // You can show a custom alert or request again
//     print("Storage permission denied");
//   }

//   if (statuses[Permission.storage]!.isPermanentlyDenied) {
//     // Open app settings if permanently denied
//     await openAppSettings();
//   }
// }

// #######################################################

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:food/lib_brok_a/screens/ai_chat_screen.dart';
import 'lib_brok_a/main.dart' as brok_a;

// void main() {
//   brok_a.main();
// }

// void main() async {
//   await dotenv.load(fileName: ".env");
//   runApp(AIChatScreen());
//   // AIChatScreen();
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: ".env");
    print("API Key: ${dotenv.env['OPENAI_API_KEY']}"); // ✅ Test output
    print("API Key: ${dotenv.env['OPENAI_API_KEY']}"); // ✅ Test output
  } catch (e) {
    print("Could not load .env file: $e");
  }
  brok_a.main();
  // runApp(AIChatScreen());
}

// import 'dart:html';

// void main() {
//   // Creating a simple HTML page dynamically using Dart
//   final header = HeadingElement.h1()..text = 'Hello from Dart Web!';
//   final button = ButtonElement()
//     ..text = 'Click me!'
//     ..onClick.listen((e) {
//       window.alert('You clicked the button!');
//     });

//   // Append elements to the document body
//   document.body!.append(header);
//   document.body!.append(button);
// }
