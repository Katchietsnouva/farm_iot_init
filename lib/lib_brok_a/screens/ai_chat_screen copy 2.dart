import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:food/lib_brok_a/components/app_bar.dart';
import 'package:food/lib_brok_a/components/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() {
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

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final String profileUrl; // Profile picture URL for each message

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    required this.profileUrl,
  });
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<String> fetchAIResponse(String prompt) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        // "model": "gpt-4",
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You're an expert in farm analytics."},
          {"role": "user", "content": prompt},
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      print(response.body);
      return "Sorry, something went wrong.";
    }
  }

  List<ChatMessage> messages = [
    ChatMessage(
      text: "Hello! Can you give me an analysis of the farm output?",
      isSentByMe: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 5)),
      // AssetImage("assets/user.jpg")
      // profileUrl: "https://randomuser.me/api/portraits/men/45.jpg",
      profileUrl: "assets/user.jpg",
    ),
    ChatMessage(
      text: "Hello! According to the data retrieved, here is your analysis:",
      isSentByMe: false,
      timestamp: DateTime.now().subtract(Duration(minutes: 4)),
      profileUrl: "assets/user.jpg",
    ),
    ChatMessage(
      text:
          "Predict the produce under the analysed data and compare them against an optimised scale, then calculate tme the percentage error of what i am doing wrong.",
      isSentByMe: true,
      timestamp: DateTime.now().subtract(Duration(minutes: 2)),
      profileUrl: "assets/user.jpg",
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // void _sendMessage() {
  //   String text = _controller.text.trim();
  //   if (text.isEmpty) return;
  //   setState(() {
  //     messages.add(
  //       ChatMessage(
  //         text: text,
  //         isSentByMe: true,
  //         timestamp: DateTime.now(),
  //         profileUrl: "https://randomuser.me/api/portraits/women/46.jpg",
  //       ),
  //     );
  //     _controller.clear();
  //   });
  //   Future.delayed(Duration(milliseconds: 100), () {
  //     if (_scrollController.hasClients) {
  //       _scrollController.animateTo(
  //         _scrollController.position.maxScrollExtent,
  //         duration: Duration(milliseconds: 300),
  //         curve: Curves.easeOut,
  //       );
  //     }
  //   });
  // }

  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(
          text: text,
          isSentByMe: true,
          timestamp: DateTime.now(),
          profileUrl: "assets/user.jpg",
        ),
      );
      _controller.clear();
    });

    // Scroll to bottom
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
          profileUrl: "assets/user.jpg",
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

  Widget _buildMessage(ChatMessage message) {
    // Define colors and border radius based on sender
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

    // For sent messages, display bubble then avatar; for received, avatar then bubble.
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
                    // backgroundImage: NetworkImage(message.profileUrl),
                    backgroundImage: AssetImage(message.profileUrl),
                  ),
                ]
                : [
                  CircleAvatar(
                    radius: 20,
                    // backgroundImage: NetworkImage(message.profileUrl),
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

  Widget _buildChatInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, -1),
            blurRadius: 4,
          ),
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
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Type a message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.grey[100],
                filled: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueAccent,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          // Handle back navigation
        },
      ),
      title: Row(
        children: [
          CircleAvatar(
            // backgroundImage: NetworkImage("https://randomuser.me/api/portraits/men/32.jpg")),
            backgroundImage: AssetImage("assets/user.jpg"),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("John Doe", style: TextStyle(fontSize: 18)),
              Text(
                "Online",
                style: TextStyle(fontSize: 12, color: Colors.greenAccent),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert),
          onPressed: () {
            // Handle more options action
          },
        ),
      ],
      elevation: 0,
      backgroundColor: Colors.blueAccent,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NouvaCustomAppBar(),
      drawer: MyDrawerWidget(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(top: 8, bottom: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index]);
              },
            ),
          ),
          // Input field
          _buildChatInput(),
        ],
      ),
    );
  }
}
