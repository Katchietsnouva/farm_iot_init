import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() async {
  await dotenv
      .load(); // Ensure .env is loaded before using any environment variables
  runApp(AIChatScreen());
}

class AIChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Chat',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<String> fetchAIResponse(String prompt) async {
    final apiKey = dotenv.env['AZURE_DEPLOYMENT_TOKEN'];

    final response = await http.post(
      Uri.parse(
        "https://22071-ma0ywu5s-eastus2.openai.azure.com/openai/deployments/gpt-4o-mini/chat/completions?api-version=2023-07-01-preview",
      ),

      headers: {"Content-Type": "application/json", "api-key": apiKey!},
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": "You are an intelligent farm assistant.",
          },
          {"role": "user", "content": prompt},
        ],
        "temperature": 1,
        "max_tokens": 4096,
        "top_p": 1,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      debugPrint('Error: ${response.statusCode}');
      debugPrint(response.body);
      return "Sorry, something went wrong.";
    }
  }

  // List of chat messages (simulated)
  List<ChatMessage> messages = [
    ChatMessage(
      text: "Hello! Can you give me an analysis of the farm output?",
      isSentByMe: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      profileUrl: "assets/user.jpg", // Example profile image
    ),
    ChatMessage(
      text: "Hello! According to the data retrieved, here is your analysis:",
      isSentByMe: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 4)),
      profileUrl: "assets/ai_profile.jpg", // Example profile image
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Function to send a message and get AI response
  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isSentByMe: true,
          timestamp: DateTime.now(),
          profileUrl: "assets/user.jpg", // Example profile image
        ),
      );
      _controller.clear();
    });

    // Scroll to bottom after sending message
    await Future.delayed(Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Get AI response
    String aiResponse = await fetchAIResponse(text);

    setState(() {
      messages.add(
        ChatMessage(
          text: aiResponse,
          isSentByMe: false,
          timestamp: DateTime.now(),
          profileUrl: "assets/ai_profile.jpg", // Example profile image
        ),
      );
    });

    // Scroll again after adding AI response
    await Future.delayed(Duration(milliseconds: 100));
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Build message UI for chat
  Widget _buildMessage(ChatMessage message) {
    final bubbleColor =
        message.isSentByMe ? Colors.blueAccent : Colors.grey.shade300;
    final textColor = message.isSentByMe ? Colors.white : Colors.black87;
    final borderRadius =
        message.isSentByMe
            ? BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            )
            : BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment:
            message.isSentByMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children:
            message.isSentByMe
                ? [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: borderRadius,
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(color: textColor, fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(message.timestamp),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(message.profileUrl),
                  ),
                ]
                : [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage(message.profileUrl),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: borderRadius,
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(color: textColor, fontSize: 16),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(message.timestamp),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
      ),
    );
  }

  // Build the chat input UI
  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.attach_file, color: Colors.grey[600]),
            onPressed: () {
              // Handle file attachment action
            },
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index]);
              },
            ),
          ),
          _buildChatInput(),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final String profileUrl;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    required this.profileUrl,
  });
}
