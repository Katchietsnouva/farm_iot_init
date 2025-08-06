import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart'; // <--- New package for file handling
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

  late File chatFile;

  @override
  void initState() {
    super.initState();
    _initChatFile();
  }

  Future<void> _initChatFile() async {
    final directory = await getApplicationDocumentsDirectory();
    chatFile = File('${directory.path}/chat_log.json');
    if (await chatFile.exists()) {
      final content = await chatFile.readAsString();
      final List<dynamic> jsonList = jsonDecode(content);
      setState(() {
        messages.addAll(jsonList.map((e) => ChatMessage.fromJson(e)));
      });
      _scrollToBottom();
    }
  }

  Future<void> _saveChatToFile() async {
    final List<Map<String, dynamic>> jsonList =
        messages.map((msg) => msg.toJson()).toList();
    await chatFile.writeAsString(jsonEncode(jsonList));
  }

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

  void _sendMessage({String? textToSend, int? retryIndex}) async {
    final text = textToSend ?? _controller.text.trim();
    if (text.isEmpty) return;

    if (retryIndex == null) {
      setState(() {
        messages.add(
          ChatMessage(text: text, isSentByMe: true, timestamp: DateTime.now()),
        );
        isTyping = true;
        _controller.clear();
      });
    } else {
      setState(() {
        messages[retryIndex] = messages[retryIndex].copyWith(
          isError: false,
          isRetrying: false,
        );
        isTyping = true;
      });
    }

    _scrollToBottom();
    _saveChatToFile();

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
        messages.add(
          ChatMessage(
            text: "⚠️ Failed to get response. Tap to retry.",
            isSentByMe: false,
            timestamp: DateTime.now(),
            isError: true,
            originalText: text, // Save original input for retry
          ),
        );
        isTyping = false;
      });
    }

    _scrollToBottom();
    _saveChatToFile();
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

  Widget _buildMessage(ChatMessage message, int index) {
    final isMe = message.isSentByMe;
    final bgColor =
        message.isError
            ? Colors.redAccent.withOpacity(0.7)
            : isMe
            ? Colors.deepPurpleAccent
            : Colors.grey.shade300;
    final textColor = isMe || message.isError ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return GestureDetector(
      onTap:
          message.isError && message.originalText != null
              ? () => _sendMessage(
                textToSend: message.originalText,
                retryIndex: index,
              )
              : null,
      child: Padding(
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
                  return _buildMessage(messages[index], index);
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
  final String? originalText;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    this.isError = false,
    this.originalText,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isSentByMe': isSentByMe,
    'timestamp': timestamp.toIso8601String(),
    'isError': isError,
    'originalText': originalText,
  };

  static ChatMessage fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'],
    isSentByMe: json['isSentByMe'],
    timestamp: DateTime.parse(json['timestamp']),
    isError: json['isError'] ?? false,
    originalText: json['originalText'],
  );

  ChatMessage copyWith({
    String? text,
    bool? isSentByMe,
    DateTime? timestamp,
    bool? isError,
    String? originalText,
    bool? isRetrying,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isSentByMe: isSentByMe ?? this.isSentByMe,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      originalText: originalText ?? this.originalText,
    );
  }
}
