import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food/lib_brok_a/models/chat_message.dart';
import 'package:food/lib_brok_a/utils/screen_type.dart'
    show ScreenType, ScreenTypeDetector;
// import 'package:food/lib_brok_a/screens/chat_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart'; // Add this for kIsWeb

import 'screens/home_screen.dart';

// --- Theme Notifier ---
// Global ValueNotifier to hold the current theme mode
// We make it accessible globally for simplicity in this example.
// In larger apps, consider Provider, Riverpod, etc.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
// Key for storing theme preference
const String themePreferenceKey = 'app_theme_mode';
// --- End Theme Notifier ---

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

class MyApp extends StatelessWidget {
  // const MyApp({super.key});
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine screen type based on width
        ScreenType screenType;
        if (constraints.maxWidth < 600) {
          screenType = ScreenType.mobile;
        } else if (constraints.maxWidth < 1200) {
          screenType = ScreenType.tablet;
        } else {
          screenType = ScreenType.desktop;
        }

        // --- Listen to Theme Notifier ---

        return ScreenTypeDetector(
          screenType: screenType,
          child: ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, currentMode, __) {
              return MaterialApp(
                title: 'Broka App',
                // theme: ThemeData(
                //   // colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
                //   useMaterial3: true,
                // ),
                theme: ThemeData(
                  // Light Theme configuration
                  brightness: Brightness.light,
                  primarySwatch: Colors.green,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.greenAccent,
                    brightness: Brightness.light,
                  ),
                  useMaterial3: true,
                  cardColor: Colors.white,
                  scaffoldBackgroundColor: Colors.grey.shade100,
                ),
                darkTheme: ThemeData(
                  // Dark Theme configuration
                  brightness: Brightness.dark,
                  primarySwatch: Colors.green,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Colors.greenAccent,
                    brightness: Brightness.dark,
                  ),
                  useMaterial3: true,
                  cardColor: Colors.grey.shade900,
                  scaffoldBackgroundColor: Colors.black,
                ),
                themeMode:
                    currentMode, // Use the current mode from the notifier
                debugShowCheckedModeBanner: false,
                home: const HomeScreen(),
              );
            },
          ),
        );
      },
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await _requestPermissions();

  // Only request permissions if NOT on web
  if (!kIsWeb) {
    await _requestPermissions();
  }
  await dotenv.load();

  // --- Load Theme Preference ---
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString(themePreferenceKey);
    // if (savedTheme == 'light') {
    //   themeNotifier.value = ThemeMode.light;
    // } else if (savedTheme == 'dark') {
    //   themeNotifier.value = ThemeMode.dark;
    // } else {
    //   themeNotifier.value = ThemeMode.system;
    // }
    themeNotifier.value =
        savedTheme == 'light'
            ? ThemeMode.light
            : savedTheme == 'dark'
            ? ThemeMode.dark
            : ThemeMode.system;
  } catch (e) {
    debugPrint("Error loading theme preference: $e");
    themeNotifier.value = ThemeMode.system; // Default on error
  }
  // --- End Load Theme Preference ---

  // Hive Initialization (keep as before)
  try {
    // For non-web platforms, get the actual directory
    if (!kIsWeb) {
      // appDocumentDir = await getApplicationDocumentsDirectory();
      final appDocumentDir = await getApplicationDocumentsDirectory();
      await Hive.initFlutter(appDocumentDir.path); // Mobile platforms
      debugPrint("Hive initialized successfully at ${appDocumentDir.path}");
    } else {
      // For the web, mock a directory or provide a fallback
      // appDocumentDir = Directory('/'); // Example of a fallback directory
      await Hive.initFlutter(); // Web uses IndexedDB, no path needed
      debugPrint("Hive initialized successfully for web (IndexedDB).");
    }
    // final appDocumentDir = await getApplicationDocumentsDirectory();

    // await Hive.initFlutter(appDocumentDir.path);
    // Check if adapter is already registered before registering
    if (!Hive.isAdapterRegistered(ChatMessageAdapter().typeId)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
    // Check if box is already open before opening
    // Open box if not already open
    if (!Hive.isBoxOpen('chatMessages')) {
      await Hive.openBox<ChatMessage>('chatMessages');
    }

    if (Hive.isBoxOpen('chatMessages')) {
      debugPrint("Hive box 'chatMessages' opened successfully.");
    } else {
      debugPrint("Error: Hive box 'chatMessages' could not be opened.");
    }
  } catch (e) {
    debugPrint("Error initializing Hive: $e");
  }
  // runApp(AIChatApp());
  runApp(const MyApp());
}

// Helper function to save theme preference
Future<void> saveThemePreference(ThemeMode mode) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String valueToSave;
    if (mode == ThemeMode.light) {
      valueToSave = 'light';
    } else if (mode == ThemeMode.dark) {
      valueToSave = 'dark';
    } else {
      valueToSave = 'system';
    }
    await prefs.setString(themePreferenceKey, valueToSave);
  } catch (e) {
    debugPrint("Error saving theme preference: $e");
  }
}

Future<void> _requestPermissions() async {
  // Request both read and write permissions
  final statuses = await [Permission.storage].request();

  if (statuses[Permission.storage]!.isDenied) {
    // You can show a custom alert or request again
    print("Storage permission denied");
  }

  if (statuses[Permission.storage]!.isPermanentlyDenied) {
    // Open app settings if permanently denied
    await openAppSettings();
  }
}


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