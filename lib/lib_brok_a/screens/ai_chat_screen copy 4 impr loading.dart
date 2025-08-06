import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(AIChatScreen());
}

class AIChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isTyping = false;
  bool errorOccurred = false;

  Future<String> fetchAIResponse(String prompt) async {
    final apiKey = dotenv.env['AZURE_DEPLOYMENT_TOKEN'];

    try {
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
        throw HttpException('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection.');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessage(text: text, isSentByMe: true, timestamp: DateTime.now()),
      );
      isTyping = true;
      errorOccurred = false;
      _controller.clear();
    });

    _scrollToBottom();

    try {
      final aiResponse = await fetchAIResponse(text);

      setState(() {
        messages.add(
          ChatMessage(
            text: aiResponse,
            isSentByMe: false,
            timestamp: DateTime.now(),
          ),
        );
        isTyping = false;
      });
    } catch (e) {
      setState(() {
        isTyping = false;
        errorOccurred = true;
        messages.add(
          ChatMessage(
            text: "⚠️ ${e.toString()}",
            isSentByMe: false,
            timestamp: DateTime.now(),
            isError: true,
          ),
        );
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() async {
    await Future.delayed(Duration(milliseconds: 300));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(ChatMessage message) {
    final isMe = message.isSentByMe;
    final bgColor =
        message.isError
            ? Colors.redAccent.withOpacity(0.7)
            : isMe
            ? Colors.deepPurpleAccent
            : Colors.grey.shade300;
    final textColor = isMe || message.isError ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              message.text,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
          SizedBox(height: 4),
          Text(
            DateFormat('hh:mm a').format(message.timestamp),
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text("AI is typing...", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.grey[700]),
              onPressed: () {
                // Future feature: upload images or files
              },
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: "Type your message...",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded, color: Colors.deepPurple),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with AI 🚜"),
        backgroundColor: Colors.deepPurpleAccent,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < messages.length) {
                  return _buildMessage(messages[index]);
                } else {
                  return _buildTypingIndicator();
                }
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
  final bool isError;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.isError = false,
  });
}
