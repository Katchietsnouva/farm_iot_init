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

// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'package:food/lib_brok_a/screens/ai_chat_screen.dart';
// import 'lib_brok_a/main.dart' as brok_a;
// import 'package:flutter/foundation.dart'; // Add this for kIsWeb

// // void main() {
// //   brok_a.main();
// // }

// // void main() async {
// //   await dotenv.load(fileName: ".env");
// //   runApp(AIChatScreen());
// //   // AIChatScreen();
// // }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // try {
//   //   await dotenv.load(fileName: ".env");
//   //   print("API Key: ${dotenv.env['OPENAI_API_KEY']}"); // ✅ Test output
//   //   print("API Key: ${dotenv.env['OPENAI_API_KEY']}"); // ✅ Test output
//   // } catch (e) {
//   //   print("Could not load .env file: $e");
//   // }
//   brok_a.main();
//   // runApp(AIChatScreen());
// }

// import 'dart:html';

// void main() {
//   // Creating a simple HTML page dynamically using Dart
//   final header = HeadingElement.h1()..text = 'Hello from Dart Web!';
//   final button =
//       ButtonElement()
//         ..text = 'Click me!'
//         ..onClick.listen((e) {
//           window.alert('You clicked the button!');
//         });

//   // Append elements to the document body
//   document.body!.append(header);
//   document.body!.append(button);
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: ChatScreen());
  }
}

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final String? profileUrl;
  final String? imagePath;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.profileUrl,
    this.imagePath,
  });
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;
  final String userProfileUrl = 'https://example.com/user.png';
  final String aiProfileUrl = 'https://example.com/ai.png';
  final String errorProfileUrl = 'https://example.com/error.png';

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<String> _fetchAIResponse(String prompt) async {
    final apiKey = dotenv.env['AZURE_DEPLOYMENT_TOKEN'];
    const apiVersion = "2024-02-15-preview";
    final deploymentName = "gpt-4o-mini";
    final endpointUrl = "https://22071-ma0ywu5s-eastus2.openai.azure.com";

    final url = Uri.parse(
      "$endpointUrl/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion",
    );

    if (apiKey == null) {
      debugPrint('Error: AZURE_DEPLOYMENT_TOKEN not found.');
      throw Exception("API key not configured.");
    }

    List<Map<String, dynamic>> messagesPayload = [
      {
        "role": "system",
        "content":
            "You are an intelligent assistant capable of answering questions.",
      },
      {
        "role": "user",
        "content": [
          {"type": "text", "text": prompt},
        ],
      },
    ];

    debugPrint(
      "Sending payload: (Content length: ${jsonEncode({"messages": messagesPayload}).length})",
    );

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json", "api-key": apiKey},
      body: jsonEncode({
        "messages": messagesPayload,
        "temperature": 0.7,
        "max_tokens": 1000,
        "top_p": 0.95,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Success Response Body Length: ${response.body.length}');
      if (data['choices'] != null &&
          data['choices'].isNotEmpty &&
          data['choices'][0]['message']?['content'] != null) {
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception("Invalid response structure from AI.");
      }
    } else {
      debugPrint('Error: ${response.statusCode}, Body: ${response.body}');
      throw Exception("Failed AI request. Status: ${response.statusCode}");
    }
  }

  Future<void> _handleSendMessage(String text) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showErrorSnackbar("No network connection.");
      return;
    }

    final userMessage = ChatMessage(
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      profileUrl: userProfileUrl,
    );

    setState(() {
      _messages.add(userMessage);
      _isAiTyping = true;
    });
    _scrollToBottom();

    try {
      String aiResponseText = await _fetchAIResponse(text);
      final aiMessage = ChatMessage(
        text: aiResponseText,
        isSentByMe: false,
        timestamp: DateTime.now(),
        profileUrl: aiProfileUrl,
      );
      setState(() {
        _messages.add(aiMessage);
      });
    } catch (e) {
      debugPrint("Error handling send message: $e");
      final errorMessage = ChatMessage(
        text: "Error: Failed to get response.\n${e.toString()}",
        isSentByMe: false,
        timestamp: DateTime.now(),
        profileUrl: errorProfileUrl,
      );
      setState(() {
        _messages.add(errorMessage);
      });
      _showErrorSnackbar("Couldn't get AI response.", isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _showErrorSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat Screen'), backgroundColor: Colors.blue),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isAiTyping && index == _messages.length) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(aiProfileUrl),
                    ),
                    title: Text('AI is typing...'),
                  );
                }
                final message = _messages[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      message.isSentByMe ? userProfileUrl : aiProfileUrl,
                    ),
                  ),
                  title: Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color:
                          message.isSentByMe
                              ? Colors.blue[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message.text),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        _handleSendMessage(value);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _handleSendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
