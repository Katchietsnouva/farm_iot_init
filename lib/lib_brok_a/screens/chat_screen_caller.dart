import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food/lib_brok_a/models/chat_message.dart';
import 'package:food/lib_brok_a/screens/chat_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'package:permission_handler/permission_handler.dart';

// --- Theme Notifier ---
// Global ValueNotifier to hold the current theme mode
// We make it accessible globally for simplicity in this example.
// In larger apps, consider Provider, Riverpod, etc.
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
// Key for storing theme preference
const String themePreferenceKey = 'app_theme_mode';
// --- End Theme Notifier ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestPermissions();
  await dotenv.load();

  // --- Load Theme Preference ---
  try {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString(themePreferenceKey);
    if (savedTheme == 'light') {
      themeNotifier.value = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.system;
    }
  } catch (e) {
    debugPrint("Error loading theme preference: $e");
    themeNotifier.value = ThemeMode.system; // Default on error
  }
  // --- End Load Theme Preference ---

  // Hive Initialization (keep as before)
  try {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    // Check if adapter is already registered before registering
    if (!Hive.isAdapterRegistered(ChatMessageAdapter().typeId)) {
      Hive.registerAdapter(ChatMessageAdapter());
    }
    // Check if box is already open before opening
    if (!Hive.isBoxOpen('chatMessages')) {
      await Hive.openBox<ChatMessage>('chatMessages');
    }
    debugPrint("Hive initialized successfully at ${appDocumentDir.path}");
  } catch (e) {
    debugPrint("Error initializing Hive: $e");
  }

  runApp(AIChatApp());
}

class AIChatApp extends StatelessWidget {
  const AIChatApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // --- Listen to Theme Notifier ---
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        // --- Return MaterialApp ---
        return MaterialApp(
          title: 'Farm Assistant Chat',
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
          themeMode: currentMode, // Use the current mode from the notifier
          debugShowCheckedModeBanner: false,
          home: ChatScreen(),
        );
        // --- End Return MaterialApp ---
      },
    );
    // --- End Listen to Theme Notifier ---
  }
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
