import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food/lib_brok_a/models/env.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

void main() {
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

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.profileUrl,
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
    // final apiKey = String.fromEnvironment('AZURE_DEPLOYMENT_TOKEN');
    final apiKey = Env.apiKey; // Use Env.apiKey from env.dart
    const apiVersion = "2024-02-15-preview";
    final deploymentName = "gpt-4o-mini";
    final endpointUrl = "https://22071-ma0ywu5s-eastus2.openai.azure.com";

    if (apiKey.isEmpty) {
      debugPrint('Error: AZURE_DEPLOYMENT_TOKEN not found.');
      throw Exception("API key not configured.");
    }

    final url = Uri.parse(
      "$endpointUrl/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion",
    );

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
