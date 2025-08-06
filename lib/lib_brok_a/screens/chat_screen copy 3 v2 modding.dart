import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle (if needed for package name) or SystemChrome
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:intl/intl.dart'; // For date formatting in export
// Remove package_info_plus import if only used for package name in the old path
// import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart'; // To get directories
import 'package:permission_handler/permission_handler.dart'; // For permissions
import 'package:path/path.dart' as p; // Use p alias for path package
import '../../main.dart'; // Import main to access themeNotifier
// Import Model and Widgets
import '../models/chat_message.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/typing_indicator.dart';
import '../main.dart'; // Import main to access themeNotifier and saveThemePreference

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State {
  late Box<ChatMessage> _chatBox; // Specify the type for the Box
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;
  bool _isLoading = true;
  static const String userProfileUrl = "assets/user.jpg";
  static const String aiProfileUrl = "assets/ai_profile.jpg";
  static const String errorProfileUrl = "assets/ai_profile.jpg";

  @override
  void initState() {
    super.initState();
    // Ensure box is open before accessing
    if (Hive.isBoxOpen('chatMessages')) {
      _chatBox = Hive.box<ChatMessage>('chatMessages'); // Specify type
      setState(() => _isLoading = false);
    } else {
      // Handle case where box didn't open in main? Retry or show error.
      Hive.openBox<ChatMessage>('chatMessages') // Specify type
          .then((box) {
            _chatBox = box;
            if (mounted) setState(() => _isLoading = false);
          })
          .catchError((e) {
            debugPrint("Error opening chat box in initState: $e");
            if (mounted) {
              setState(() => _isLoading = false); // Stop loading even on error
            }
            _showErrorSnackbar("Error loading chat history.");
          });
    }
    // Use WidgetsBinding to ensure layout is complete before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom(delayMillis: 300);
    });
  }

  // --- Export Chat Logic ---
  Future<void> _exportChat() async {
    if (_isLoading || !Hive.isBoxOpen('chatMessages')) {
      _showErrorSnackbar("Chat history not available yet.");
      return;
    }

    // Cast to List<ChatMessage> for type safety
    final messages =
        _chatBox.values.toList().cast<ChatMessage>()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (messages.isEmpty) {
      _showErrorSnackbar("Nothing to export.", isError: false);
      return;
    }

    // --- 1. Request Storage Permission ---
    final status = await Permission.storage.request();

    if (!mounted) return; // Check if widget is still mounted after async gap

    if (status.isDenied) {
      _showErrorSnackbar("Storage permission denied. Cannot export chat.");
      return;
    }

    if (status.isPermanentlyDenied) {
      _showErrorSnackbar(
        "Storage permission permanently denied. Please enable it in settings.",
      );
      openAppSettings(); // Helper function from permission_handler
      return;
    }

    if (status.isGranted) {
      // --- Permission Granted - Proceed with Export ---

      // 2. Format chat content (Same as before)
      final buffer = StringBuffer();
      buffer.writeln(
        "Chat Export - ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
      );
      buffer.writeln("========================================");
      for (final message in messages) {
        final sender = message.isSentByMe ? "User" : "AI";
        final time = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).format(message.timestamp);
        buffer.write("[$time] $sender: ${message.text}");
        if (message.imagePath != null && message.imagePath!.isNotEmpty) {
          // Extract filename from full path for clarity
          final imageName = p.basename(message.imagePath!);
          buffer.write(" [Image Attached: $imageName]");
        }
        buffer.writeln(); // New line after each message
      }
      final formattedChat = buffer.toString();

      // 3. Get target directory path (User's Documents/ai_chats)
      Directory? targetDir;
      try {
        // Get the app-specific external storage directory first
        final Directory? appSpecificExternalDir =
            await getExternalStorageDirectory();

        if (appSpecificExternalDir == null) {
          throw Exception(
            "Could not determine external storage directory path.",
          );
        }

        // Attempt to find the root external storage path
        // This often looks like /storage/emulated/0
        // We find it by splitting the app-specific path
        final String externalStoragePath =
            appSpecificExternalDir.path.split('/Android/')[0];

        if (externalStoragePath.isEmpty) {
          // Fallback or alternative if parsing fails
          throw Exception("Could not parse root external storage path.");
        }

        // Construct the path to Documents/ai_chats
        // Use p.join for cross-platform path joining
        final documentsPath = p.join(externalStoragePath, 'Documents');
        final targetPath = p.join(documentsPath, 'ai_chats');

        targetDir = Directory(targetPath);

        // 4. Ensure directory exists
        if (!await targetDir.exists()) {
          await targetDir.create(recursive: true);
          debugPrint("Created directory: ${targetDir.path}");
        } else {
          debugPrint("Directory already exists: ${targetDir.path}");
        }
      } catch (e) {
        debugPrint("Error preparing/creating directory: $e");
        _showErrorSnackbar("Error preparing export path: $e");
        return;
      }

      // 5. Create filename & write file
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'chat_export_$timestamp.txt';
      final file = File(
        p.join(targetDir.path, fileName),
      ); // Use p.join here too

      try {
        await file.writeAsString(formattedChat);
        debugPrint("Chat exported successfully to: ${file.path}");
        // Provide a clearer path hint to the user
        _showErrorSnackbar(
          "Chat exported to Documents/ai_chats/$fileName",
          isError: false,
        );
      } catch (e) {
        debugPrint("Error writing export file: $e");
        _showErrorSnackbar("Failed to save export file: $e");
      }
    } // End if (status.isGranted)
  }

  // --- API Call Logic (_fetchAIResponse) ---
  Future<String> _fetchAIResponse(String prompt, {File? imageFile}) async {
    final apiKey = dotenv.env['AZURE_DEPLOYMENT_TOKEN'];
    const apiVersion = "2024-02-15-preview";
    final deploymentName = "gpt-4o-mini";
    final endpointUrl = "https://22071-ma0ywu5s-eastus2.openai.azure.com";

    final url = Uri.parse(
      "$endpointUrl/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion",
    );

    if (apiKey == null || apiKey.isEmpty) {
      // Check if empty too
      debugPrint('Error: AZURE_DEPLOYMENT_TOKEN not found or is empty.');
      throw Exception("API key not configured.");
    }

    List<Map<String, dynamic>> messagesPayload = [
      {
        "role": "system",
        "content":
            "You are an intelligent farm assistant capable of analyzing text and images related to farming.",
      },
      {
        "role": "user",
        "content": [
          {"type": "text", "text": prompt},
          if (imageFile != null)
            {
              "type": "image_url",
              "image_url": {
                "url":
                    "data:image/${p.extension(imageFile.path).substring(1).toLowerCase()};base64,${base64Encode(await imageFile.readAsBytes())}",
                // Ensure extension is lowercase for content type
              },
            },
        ],
      },
    ];

    // Limit logging very large payloads (like base64 images)
    String payloadLog = jsonEncode({"messages": messagesPayload});
    if (payloadLog.length > 1000) {
      payloadLog = payloadLog.substring(0, 997) + "..."; // Truncate log
    }
    debugPrint("Sending payload: $payloadLog");

    try {
      final response = await http
          .post(
            url,
            headers: {"Content-Type": "application/json", "api-key": apiKey},
            body: jsonEncode({
              "messages": messagesPayload,
              "temperature": 0.7,
              "max_tokens":
                  1000, // Consider if this is enough for image analysis
              "top_p": 0.95,
            }),
          )
          .timeout(const Duration(seconds: 90)); // Add a timeout

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Add more robust checking for response structure
        if (data['choices'] is List &&
            (data['choices'] as List).isNotEmpty &&
            data['choices'][0] is Map &&
            data['choices'][0]['message'] is Map &&
            data['choices'][0]['message']['content'] is String) {
          debugPrint(
            'Success Response Body Length: ${response.bodyBytes.length}',
          ); // Use bodyBytes for accurate length
          return data['choices'][0]['message']['content'];
        } else {
          debugPrint(
            'Error: Invalid response structure. Body: ${response.body}',
          );
          throw Exception("Invalid response structure from AI.");
        }
      } else {
        debugPrint('Error: ${response.statusCode}, Body: ${response.body}');
        // Provide more specific error messages based on status code if possible
        throw Exception("Failed AI request. Status: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Error during API call: $e');
      // Rethrow a slightly cleaner error message
      throw Exception("Network error or timeout communicating with AI: $e");
    }
  }

  // --- Handle Sending Message (_handleSendMessage) ---
  Future<void> _handleSendMessage(String text, File? image) async {
    // Trim whitespace from text input
    final trimmedText = text.trim();
    if (trimmedText.isEmpty && image == null) {
      // Don't send empty messages unless an image is attached
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    // Check if *any* connection type exists (more robust)
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showErrorSnackbar("No network connection.");
      return;
    }

    final userMessage = ChatMessage(
      text: trimmedText, // Use trimmed text
      isSentByMe: true,
      timestamp: DateTime.now(),
      profileUrl: userProfileUrl,
      imagePath: image?.path,
    );

    // Add to box *before* making the API call for immediate UI update
    await _chatBox.add(userMessage);
    _scrollToBottom();

    // Set AI typing state immediately after adding user message
    if (mounted) {
      setState(() {
        _isAiTyping = true;
      });
      _scrollToBottom(); // Scroll again after typing indicator appears
    }

    try {
      // Pass trimmed text to the API
      String aiResponseText = await _fetchAIResponse(
        trimmedText,
        imageFile: image,
      );
      final aiMessage = ChatMessage(
        text: aiResponseText.trim(), // Trim AI response too
        isSentByMe: false,
        timestamp: DateTime.now(),
        profileUrl: aiProfileUrl,
      );
      await _chatBox.add(aiMessage);
    } catch (e) {
      debugPrint("Error handling send message: $e");
      final errorMessage = ChatMessage(
        text: "Error: Failed to get response.\n${e.toString()}",
        isSentByMe: false,
        timestamp: DateTime.now(),
        profileUrl: errorProfileUrl,
      );
      await _chatBox.add(errorMessage);
      // Show error specific to the failure
      _showErrorSnackbar(
        "Couldn't get AI response: ${e.toString()}",
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAiTyping = false;
        });
        _scrollToBottom();
      }
    }
  }

  // --- UI Helpers (_scrollToBottom, _showErrorSnackbar) ---
  void _scrollToBottom({int delayMillis = 100}) {
    // No need for WidgetsBinding here if called after state updates or in initState's postFrameCallback
    if (_scrollController.hasClients) {
      Future.delayed(Duration(milliseconds: delayMillis), () {
        if (_scrollController.hasClients) {
          // Check again after delay
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _showErrorSnackbar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError
                ? Colors.redAccent
                : (isError == false
                    ? Colors.green
                    : Colors.orangeAccent), // Kept ternary structure
        duration: const Duration(seconds: 4), // Slightly longer for readability
        behavior: SnackBarBehavior.floating, // Optional: make it float
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Assistant Chat'), // Use const
        elevation: 1,
        // Let theme handle AppBar color unless specific override needed
        // backgroundColor: Theme.of(context).colorScheme.surface, // Use colorScheme
        actions: [
          // --- Theme Toggle Button ---
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier, // Listen to the global notifier
            builder: (context, currentMode, child) {
              ThemeMode nextMode;
              IconData iconData;
              String tooltip;

              // Determine current effective brightness
              Brightness platformBrightness = MediaQuery.platformBrightnessOf(
                context,
              );
              bool isCurrentlyDark =
                  (currentMode == ThemeMode.dark) ||
                  (currentMode == ThemeMode.system &&
                      platformBrightness == Brightness.dark);

              if (isCurrentlyDark) {
                nextMode = ThemeMode.light;
                iconData = Icons.light_mode_outlined;
                tooltip = 'Switch to Light Theme';
              } else {
                nextMode = ThemeMode.dark;
                iconData = Icons.dark_mode_outlined;
                tooltip = 'Switch to Dark Theme';
              }

              return IconButton(
                icon: Icon(iconData),
                tooltip: tooltip,
                onPressed: () {
                  themeNotifier.value = nextMode;
                  saveThemePreference(nextMode); // Save preference
                },
              );
            },
          ),
          // --- Export Chat Menu Item ---
          PopupMenuButton<String>(
            onSelected: (String result) {
              if (result == 'export') {
                _exportChat(); // Call the updated export function
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    // Use const
                    value: 'export',
                    child: ListTile(
                      leading: Icon(Icons.download_rounded),
                      title: Text('Export Chat'),
                    ),
                  ),

                  // Add other menu items here if needed
                ],
            icon: const Icon(Icons.more_vert), // Use const
          ),
          ElevatedButton(
            onPressed: () async {
              print("TEST: Requesting storage permission...");
              PermissionStatus status = await Permission.storage.request();
              print("TEST: Permission status: $status");
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("TEST Permission status: $status")),
                );
              }
            },
            child: Text("Test Permission Request"),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(),
                    ) // Use const
                    : ValueListenableBuilder<Box<ChatMessage>>(
                      valueListenable: _chatBox.listenable(),
                      builder: (context, box, _) {
                        // Sort messages directly here
                        final messages =
                            box.values.toList()..sort(
                              (a, b) => a.timestamp.compareTo(b.timestamp),
                            );

                        // Scroll to bottom after build completes if needed
                        // Moved scrolling logic mainly to initState and _handleSendMessage
                        // WidgetsBinding.instance.addPostFrameCallback((_) {
                        //   if (_scrollController.hasClients && messages.isNotEmpty) {
                        //      _scrollToBottom(delayMillis: 50); // Gentle scroll on new message add
                        //   }
                        // });

                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            vertical: 8.0,
                          ), // Use const
                          itemCount: messages.length + (_isAiTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (_isAiTyping && index == messages.length) {
                              return const TypingIndicator(
                                // Use const
                                aiProfileImageUrl: aiProfileUrl,
                              );
                            }
                            // No need for index check >= messages.length as itemCount is correct
                            final message = messages[index];
                            return ChatMessageBubble(message: message);
                          },
                        );
                      },
                    ),
          ),
          ChatInputField(onSendMessage: _handleSendMessage),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Hive box is generally kept open globally, no need to close here
    super.dispose();
  }
}

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart'; // For rootBundle (if needed for package name) or SystemChrome
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:intl/intl.dart'; // For date formatting in export
// import 'package:package_info_plus/package_info_plus.dart'; // To get package name
// import 'package:path_provider/path_provider.dart'; // To get directories
// import 'package:permission_handler/permission_handler.dart'; // For permissions
// import 'package:path/path.dart' as p;
// import '../../main.dart'; // Import main to access themeNotifier

// // Import Model and Widgets
// import '../models/chat_message.dart';
// import '../widgets/chat_message_bubble.dart';
// import '../widgets/chat_input_field.dart';
// import '../widgets/typing_indicator.dart';
// import '../main.dart'; // Import main to access themeNotifier and saveThemePreference

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);

//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   late Box<ChatMessage> _chatBox;
//   final ScrollController _scrollController = ScrollController();
//   bool _isAiTyping = false;
//   bool _isLoading = true;

//   static const String userProfileUrl = "assets/user.jpg";
//   static const String aiProfileUrl = "assets/ai_profile.jpg";
//   static const String errorProfileUrl = "assets/ai_profile.jpg";

//   @override
//   void initState() {
//     super.initState();
//     // Ensure box is open before accessing
//     if (Hive.isBoxOpen('chatMessages')) {
//       _chatBox = Hive.box<ChatMessage>('chatMessages');
//       setState(() => _isLoading = false);
//     } else {
//       // Handle case where box didn't open in main? Retry or show error.
//       Hive.openBox<ChatMessage>('chatMessages')
//           .then((box) {
//             _chatBox = box;
//             if (mounted) setState(() => _isLoading = false);
//           })
//           .catchError((e) {
//             debugPrint("Error opening chat box in initState: $e");
//             if (mounted)
//               setState(() => _isLoading = false); // Stop loading even on error
//             _showErrorSnackbar("Error loading chat history.");
//           });
//     }
//     _scrollToBottom(delayMillis: 300);
//   }

//   // --- Export Chat Logic ---
//   Future<void> _exportChat() async {
//     if (_isLoading || !Hive.isBoxOpen('chatMessages')) {
//       _showErrorSnackbar("Chat history not available yet.");
//       return;
//     }

//     final messages =
//         _chatBox.values.toList()
//           ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

//     if (messages.isEmpty) {
//       _showErrorSnackbar("Nothing to export.", isError: false);
//       return;
//     }

//     // 1. Format chat content
//     final buffer = StringBuffer();
//     buffer.writeln(
//       "Chat Export - ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}",
//     );
//     buffer.writeln("========================================");
//     for (final message in messages) {
//       final sender = message.isSentByMe ? "User" : "AI";
//       final time = DateFormat('yyyy-MM-dd HH:mm:ss').format(message.timestamp);
//       buffer.write("[$time] $sender: ${message.text}");
//       if (message.imagePath != null) {
//         buffer.write(" [Image Attached: ${message.imagePath}]");
//       }
//       buffer.writeln(); // New line after each message
//     }
//     final formattedChat = buffer.toString();

//     // // 2. Get directory path (Android/media/your.package.name/ai_chats)
//     // Directory? externalDir;
//     // String? packageName;
//     // try {
//     //   // Use getExternalStorageDirectories with media type - preferred modern approach
//     //   // This often points to /storage/emulated/0/Android/media/your.package.name
//     //   final List<Directory>? dirs = await getExternalStorageDirectories(
//     //     type: StorageDirectory.documents,
//     //   );
//     //   if (dirs != null && dirs.isNotEmpty) {
//     //     externalDir =
//     //         dirs[0]; // Use the first one, typically the primary external storage
//     //   } else {
//     //     // Fallback if media directory isn't directly available
//     //     externalDir =
//     //         await getExternalStorageDirectory(); // Might be /storage/emulated/0/Android/data/your.package.name/files
//     //   }

//     //   if (externalDir == null) {
//     //     throw Exception("Could not determine external storage directory.");
//     //   }

//     //   PackageInfo packageInfo = await PackageInfo.fromPlatform();
//     //   packageName = packageInfo.packageName;

//     //   // Construct the final path within the external directory
//     //   // Note: If using the fallback getExternalStorageDirectory(), the path might be inside Android/data instead of Android/media
//     //   // Writing directly to Android/media might be preferable if possible.
//     //   // Let's try creating within the obtained externalDir structure.
//     //   final targetPath = '${externalDir.path}/ai_chats';
//     //   externalDir = Directory(targetPath);
//     // } catch (e) {
//     //   debugPrint("Error getting directory or package info: $e");
//     //   _showErrorSnackbar("Error preparing export path: $e");
//     //   return;
//     // }

//     // 2. Get user-accessible Documents/ai_chats directory
//     Directory? externalDir;
//     try {
//       final hasPermission = await Permission.storage.request();
//       if (!hasPermission.isGranted) {
//         _showErrorSnackbar("Storage permission denied.");
//         return;
//       }

//       // Get true external storage root path (e.g., /storage/emulated/0)
//       final rootPath = "/storage/emulated/0";
//       final targetPath = '$rootPath/Documents/ai_chats';
//       externalDir = Directory(targetPath);
//     } catch (e) {
//       debugPrint("Error accessing Documents directory: $e");
//       _showErrorSnackbar("Failed to access Documents directory.");
//       return;
//     }

//     // 3. Ensure directory exists
//     try {
//       if (!await externalDir.exists()) {
//         await externalDir.create(recursive: true);
//         debugPrint("Created directory: ${externalDir.path}");
//       } else {
//         debugPrint("Directory already exists: ${externalDir.path}");
//       }
//     } catch (e) {
//       debugPrint("Error creating directory: $e");
//       _showErrorSnackbar("Could not create export directory: $e");
//       return;
//     }

//     // 4. Create filename & write file
//     final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
//     final fileName = 'chat_export_$timestamp.txt';
//     final file = File('${externalDir.path}/$fileName');

//     try {
//       await file.writeAsString(formattedChat);
//       debugPrint("Chat exported successfully to: ${file.path}");
//       _showErrorSnackbar(
//         "Chat exported to ${externalDir.path}/$fileName",
//         isError: false,
//       );
//     } catch (e) {
//       debugPrint("Error writing export file: $e");
//       _showErrorSnackbar("Failed to save export file: $e");
//     }
//   }

//   // --- API Call Logic (_fetchAIResponse) ---
//   // ... (Keep your existing _fetchAIResponse function here) ...
//   Future<String> _fetchAIResponse(String prompt, {File? imageFile}) async {
//     final apiKey = dotenv.env['AZURE_DEPLOYMENT_TOKEN'];
//     const apiVersion =
//         "2024-02-15-preview"; // Use a version known for vision support
//     final deploymentName = "gpt-4o-mini";
//     final endpointUrl = "https://22071-ma0ywu5s-eastus2.openai.azure.com";

//     final url = Uri.parse(
//       "$endpointUrl/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion",
//     );

//     if (apiKey == null) {
//       debugPrint('Error: AZURE_DEPLOYMENT_TOKEN not found.');
//       throw Exception("API key not configured.");
//     }

//     List<Map<String, dynamic>> messagesPayload = [
//       {
//         "role": "system",
//         "content":
//             "You are an intelligent farm assistant capable of analyzing text and images related to farming.",
//       },
//       {
//         "role": "user",
//         "content": [
//           {"type": "text", "text": prompt},
//           if (imageFile != null)
//             {
//               "type": "image_url",
//               "image_url": {
//                 "url":
//                     "data:image/${p.extension(imageFile.path).substring(1)};base64,${base64Encode(await imageFile.readAsBytes())}",
//               },
//             },
//         ],
//       },
//     ];

//     debugPrint(
//       "Sending payload: (Content length: ${jsonEncode({"messages": messagesPayload}).length})",
//     );

//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json", "api-key": apiKey},
//       body: jsonEncode({
//         "messages": messagesPayload,
//         "temperature": 0.7,
//         "max_tokens": 1000,
//         "top_p": 0.95,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       debugPrint('Success Response Body Length: ${response.body.length}');
//       if (data['choices'] != null &&
//           data['choices'].isNotEmpty &&
//           data['choices'][0]['message']?['content'] != null) {
//         return data['choices'][0]['message']['content'];
//       } else {
//         throw Exception("Invalid response structure from AI.");
//       }
//     } else {
//       debugPrint('Error: ${response.statusCode}, Body: ${response.body}');
//       throw Exception("Failed AI request. Status: ${response.statusCode}");
//     }
//   }

//   // --- Handle Sending Message (_handleSendMessage) ---
//   // ... (Keep your existing _handleSendMessage function here) ...
//   Future<void> _handleSendMessage(String text, File? image) async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     if (connectivityResult.contains(ConnectivityResult.none)) {
//       _showErrorSnackbar("No network connection.");
//       return;
//     }
//     final userMessage = ChatMessage(
//       text: text,
//       isSentByMe: true,
//       timestamp: DateTime.now(),
//       profileUrl: userProfileUrl,
//       imagePath: image?.path,
//     );
//     await _chatBox.add(userMessage);
//     _scrollToBottom();
//     setState(() {
//       _isAiTyping = true;
//     });
//     _scrollToBottom();

//     try {
//       String aiResponseText = await _fetchAIResponse(text, imageFile: image);
//       final aiMessage = ChatMessage(
//         text: aiResponseText,
//         isSentByMe: false,
//         timestamp: DateTime.now(),
//         profileUrl: aiProfileUrl,
//       );
//       await _chatBox.add(aiMessage);
//     } catch (e) {
//       debugPrint("Error handling send message: $e");
//       final errorMessage = ChatMessage(
//         text: "Error: Failed to get response.\n${e.toString()}",
//         isSentByMe: false,
//         timestamp: DateTime.now(),
//         profileUrl: errorProfileUrl,
//       );
//       await _chatBox.add(errorMessage);
//       _showErrorSnackbar("Couldn't get AI response.", isError: true);
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAiTyping = false;
//         });
//         _scrollToBottom();
//       }
//     }
//   }

//   // --- UI Helpers (_scrollToBottom, _showErrorSnackbar) ---
//   // ... (Keep your existing helper functions here) ...
//   void _scrollToBottom({int delayMillis = 100}) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         Future.delayed(Duration(milliseconds: delayMillis), () {
//           if (_scrollController.hasClients) {
//             // Check again after delay
//             _scrollController.animateTo(
//               _scrollController.position.maxScrollExtent,
//               duration: Duration(milliseconds: 300),
//               curve: Curves.easeOut,
//             );
//           }
//         });
//       }
//     });
//   }

//   void _showErrorSnackbar(String message, {bool isError = true}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(
//       context,
//     ).removeCurrentSnackBar(); // Remove previous snackbar if any
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor:
//             isError
//                 ? Colors.redAccent
//                 : (isError == false ? Colors.green : Colors.orangeAccent),
//         duration: Duration(seconds: 3),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Farm Assistant Chhat'),
//         elevation: 1,
//         backgroundColor: Theme.of(context).cardColor,
//         actions: [
//           // --- Theme Toggle Button ---
//           ValueListenableBuilder<ThemeMode>(
//             valueListenable: themeNotifier, // Listen to the global notifier
//             builder: (context, currentMode, child) {
//               // Determine the next mode when tapped
//               ThemeMode nextMode;
//               IconData iconData;
//               String tooltip;

//               // Get the actual brightness based on system setting if mode is system
//               Brightness platformBrightness = MediaQuery.platformBrightnessOf(
//                 context,
//               );
//               bool isCurrentlyDark =
//                   (currentMode == ThemeMode.dark) ||
//                   (currentMode == ThemeMode.system &&
//                       platformBrightness == Brightness.dark);

//               if (isCurrentlyDark) {
//                 nextMode = ThemeMode.light;
//                 iconData = Icons.light_mode_outlined;
//                 tooltip = 'Switch to Light Theme';
//               } else {
//                 nextMode = ThemeMode.dark;
//                 iconData = Icons.dark_mode_outlined;
//                 tooltip = 'Switch to Dark Theme';
//               }
//               // Optional: Add system theme option
//               // if (currentMode == ThemeMode.light) {
//               //    nextMode = ThemeMode.dark; iconData = Icons.dark_mode_outlined; tooltip = 'Switch to Dark Theme';
//               // } else if (currentMode == ThemeMode.dark) {
//               //    nextMode = ThemeMode.system; iconData = Icons.brightness_auto_outlined; tooltip = 'Switch to System Theme';
//               // } else { // System
//               //    nextMode = ThemeMode.light; iconData = Icons.light_mode_outlined; tooltip = 'Switch to Light Theme';
//               // }

//               return IconButton(
//                 icon: Icon(iconData),
//                 tooltip: tooltip,
//                 onPressed: () {
//                   // Update the global notifier
//                   themeNotifier.value = nextMode;
//                   // Save the preference
//                   saveThemePreference(nextMode);
//                 },
//               );
//             },
//           ),
//           // --- Export Chat Menu Item ---
//           PopupMenuButton<String>(
//             onSelected: (String result) {
//               if (result == 'export') {
//                 _exportChat();
//               }
//             },
//             itemBuilder:
//                 (BuildContext context) => <PopupMenuEntry<String>>[
//                   const PopupMenuItem<String>(
//                     value: 'export',
//                     child: ListTile(
//                       leading: Icon(Icons.download_rounded),
//                       title: Text('Export Chat'),
//                     ),
//                   ),
//                   // Add other menu items here if needed
//                 ],
//             icon: Icon(Icons.more_vert), // Standard more options icon
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child:
//                 _isLoading
//                     ? Center(child: CircularProgressIndicator())
//                     : ValueListenableBuilder<Box<ChatMessage>>(
//                       valueListenable: _chatBox.listenable(),
//                       builder: (context, box, _) {
//                         // ... (keep existing ValueListenableBuilder logic for displaying messages) ...
//                         final messages =
//                             box.values.toList()..sort(
//                               (a, b) => a.timestamp.compareTo(b.timestamp),
//                             );
//                         WidgetsBinding.instance.addPostFrameCallback((_) {
//                           if (_scrollController.hasClients &&
//                               messages.isNotEmpty) {
//                             _scrollToBottom(delayMillis: 50);
//                           }
//                         });
//                         return ListView.builder(
//                           controller: _scrollController,
//                           padding: EdgeInsets.symmetric(vertical: 8),
//                           itemCount: messages.length + (_isAiTyping ? 1 : 0),
//                           itemBuilder: (context, index) {
//                             if (_isAiTyping && index == messages.length) {
//                               return TypingIndicator(
//                                 aiProfileImageUrl: aiProfileUrl,
//                               );
//                             }
//                             if (index >= messages.length)
//                               return SizedBox.shrink();
//                             final message = messages[index];
//                             return ChatMessageBubble(message: message);
//                           },
//                         );
//                       },
//                     ),
//           ),
//           ChatInputField(onSendMessage: _handleSendMessage),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     // Hive box is usually kept open
//     super.dispose();
//   }
// }
