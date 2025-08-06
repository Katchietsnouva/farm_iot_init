import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path/path.dart' as p; // For basename encoding

// Import Model and Widgets
import '../models/chat_message.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_input_field.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Box<ChatMessage> _chatBox;
  final ScrollController _scrollController = ScrollController();
  bool _isAiTyping = false;
  bool _isLoading = true; // To potentially show a loading indicator initially

  // Profile image URLs (constants for clarity)
  static const String userProfileUrl = "assets/user.jpg";
  static const String aiProfileUrl = "assets/ai_profile.jpg";
  static const String errorProfileUrl =
      "assets/ai_profile.jpg"; // Or use a specific error icon

  @override
  void initState() {
    super.initState();
    _chatBox = Hive.box<ChatMessage>('chatMessages');
    // Initial loading state can be set based on box content or other factors
    setState(() {
      _isLoading = false;
      // Optional: Add initial welcome message if box is empty
      // if (_chatBox.isEmpty) {
      //    _addInitialMessages();
      // }
    });
    _scrollToBottom(delayMillis: 300); // Scroll down initially
  }

  // Example: Add initial messages if the chat is empty
  // void _addInitialMessages() {
  //   final welcomeMessage = ChatMessage(
  //     text: "Hello! How can I help you with your farm today?",
  //     isSentByMe: false,
  //     timestamp: DateTime.now(),
  //     profileUrl: aiProfileUrl,
  //   );
  //   _chatBox.add(welcomeMessage);
  // }

  // --- API Call Logic ---
  Future<String> _fetchAIResponse(String prompt, {File? imageFile}) async {
    // ... (Keep the fetchAIResponse logic exactly as in the previous combined code)
    // ... (Make sure it uses dotenv, constructs the payload with image base64 etc.)
    // --- Using the previously refined version: ---
    final apiKey = dotenv.env['AZURE_DEPLOYMENT_TOKEN'];
    const apiVersion =
        "2024-02-15-preview"; // Use a version known for vision support
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
                    "data:image/${p.extension(imageFile.path).substring(1)};base64,${base64Encode(await imageFile.readAsBytes())}",
              },
            },
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

  // --- Handle Sending Message (Called by ChatInputField) ---
  Future<void> _handleSendMessage(String text, File? image) async {
    // Network Check
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      _showErrorSnackbar("No network connection.");
      return;
    }

    // Save user message
    final userMessage = ChatMessage(
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      profileUrl: userProfileUrl,
      imagePath: image?.path, // Save image path
    );
    await _chatBox.add(userMessage);
    _scrollToBottom(); // Scroll after adding user message

    // Show typing indicator
    setState(() {
      _isAiTyping = true;
    });
    _scrollToBottom(); // Scroll after adding indicator

    // Call AI
    try {
      String aiResponseText = await _fetchAIResponse(text, imageFile: image);

      final aiMessage = ChatMessage(
        text: aiResponseText,
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
        profileUrl: errorProfileUrl, // Use AI or error profile
      );
      await _chatBox.add(errorMessage);
      _showErrorSnackbar("Couldn't get AI response.", isError: true);
    } finally {
      // Hide typing indicator
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _isAiTyping = false;
        });
        _scrollToBottom(); // Scroll after potential content change
      }
    }
  }

  // --- UI Helpers ---
  void _scrollToBottom({int delayMillis = 100}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        Future.delayed(Duration(milliseconds: delayMillis), () {
          if (_scrollController.hasClients) {
            // Check again after delay
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _showErrorSnackbar(String message, {bool isError = true}) {
    if (!mounted) return; // Don't show if widget is disposed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.orangeAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Farm Assistant Chat'),
        elevation: 1,
        backgroundColor: Theme.of(context).cardColor,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(),
                    ) // Show loading initially
                    : ValueListenableBuilder<Box<ChatMessage>>(
                      valueListenable: _chatBox.listenable(),
                      builder: (context, box, _) {
                        final messages =
                            box.values.toList()..sort(
                              (a, b) => a.timestamp.compareTo(b.timestamp),
                            );

                        // Scroll after build if new messages added
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_scrollController.hasClients &&
                              messages.isNotEmpty) {
                            _scrollToBottom(delayMillis: 50);
                          }
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: 8),
                          itemCount:
                              messages.length +
                              (_isAiTyping
                                  ? 1
                                  : 0), // Add space for typing indicator
                          itemBuilder: (context, index) {
                            if (_isAiTyping && index == messages.length) {
                              // Use the TypingIndicator widget
                              return TypingIndicator(
                                aiProfileImageUrl: aiProfileUrl,
                              );
                            }
                            if (index >= messages.length)
                              return SizedBox.shrink();

                            final message = messages[index];
                            // Use the ChatMessageBubble widget
                            return ChatMessageBubble(message: message);
                          },
                        );
                      },
                    ),
          ),
          // Use the ChatInputField widget
          ChatInputField(onSendMessage: _handleSendMessage),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Hive box usually stays open, closing depends on app architecture
    // _chatBox.close();
    super.dispose();
  }
}
