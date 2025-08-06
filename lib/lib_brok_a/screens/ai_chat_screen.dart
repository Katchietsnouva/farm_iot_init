import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart'; // For picking images

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
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

enum MessageStatus { sending, sent, failed }

class ChatMessage {
  final String text;
  final bool isSentByMe;
  final DateTime timestamp;
  final String profileUrl;
  late final MessageStatus status;
  final String? imagePath;

  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    required this.profileUrl,
    this.status = MessageStatus.sent,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isSentByMe': isSentByMe,
      'timestamp': timestamp.toIso8601String(),
      'profileUrl': profileUrl,
      'status': status.index,
      'imagePath': imagePath,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isSentByMe: json['isSentByMe'],
      timestamp: DateTime.parse(json['timestamp']),
      profileUrl: json['profileUrl'],
      status: MessageStatus.values[json['status']],
      imagePath: json['imagePath'],
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

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
            "content": "You are an intelligent farm assistantt.",
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
      throw Exception('Failed to fetch AI response');
    }
  }

  void _loadMessages() async {
    final file = await _getLocalFile();
    if (await file.exists()) {
      final content = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(content);
      setState(() {
        messages = jsonData.map((e) => ChatMessage.fromJson(e)).toList();
      });
    }
  }

  void _saveMessages() async {
    final file = await _getLocalFile();
    final jsonData = jsonEncode(messages.map((m) => m.toJson()).toList());
    await file.writeAsString(jsonData);
  }

  Future<File> _getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/chat_history.json');
  }

  void _exportChat() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/chat_export.txt');

    String content = messages
        .map((m) {
          return '${m.isSentByMe ? "Me" : "AI"} (${DateFormat('hh:mm a').format(m.timestamp)}): ${m.text}';
        })
        .join('\n\n');

    await file.writeAsString(content);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Chat exported to chat_export.txt')));
  }

  void _sendMessage({String? imagePath}) async {
    if (isSending) return;
    String text = _controller.text.trim();
    if (text.isEmpty && imagePath == null) return;

    setState(() {
      isSending = true;
    });

    ChatMessage userMessage = ChatMessage(
      text: text,
      isSentByMe: true,
      timestamp: DateTime.now(),
      profileUrl: "assets/user.jpg",
      status: MessageStatus.sending,
      imagePath: imagePath,
    );

    setState(() {
      messages.add(userMessage);
      _controller.clear();
    });

    await Future.delayed(Duration(milliseconds: 300));
    _scrollToBottom();

    try {
      if (imagePath == null) {
        String aiResponse = await fetchAIResponse(text);
        setState(() {
          messages.last.status = MessageStatus.sent;
          messages.add(
            ChatMessage(
              text: aiResponse,
              isSentByMe: false,
              timestamp: DateTime.now(),
              profileUrl: "assets/ai_profile.jpg",
              status: MessageStatus.sent,
            ),
          );
        });
      } else {
        setState(() {
          messages.last.status = MessageStatus.sent;
        });
      }
    } catch (e) {
      setState(() {
        messages.last.status = MessageStatus.failed;
      });
    }

    _saveMessages();
    setState(() {
      isSending = false;
    });

    await Future.delayed(Duration(milliseconds: 300));
    _scrollToBottom();
  }

  void _retryMessage(int index) {
    setState(() {
      messages[index].status = MessageStatus.sending;
    });
    _sendMessage();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null) {
      String path = result.files.single.path!;
      _sendMessage(imagePath: path);
    }
  }

  Widget _buildMessage(ChatMessage message, int index) {
    final isMe = message.isSentByMe;
    final bubbleColor = isMe ? Colors.blueAccent : Colors.grey.shade300;
    final textColor = isMe ? Colors.white : Colors.black87;

    final borderRadius =
        isMe
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
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(message.profileUrl),
                ),
              SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imagePath != null)
                        Image.file(File(message.imagePath!), width: 200),
                      if (message.text.isNotEmpty)
                        Text(
                          message.text,
                          style: TextStyle(color: textColor, fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
              if (isMe) SizedBox(width: 8),
              if (isMe)
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(message.profileUrl),
                ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Text(
                DateFormat('hh:mm a').format(message.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(width: 8),
              if (isMe) _buildStatusIcon(message.status, index),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(MessageStatus status, int index) {
    switch (status) {
      case MessageStatus.sending:
        return Text(
          'Sending...',
          style: TextStyle(fontSize: 12, color: Colors.orange),
        );
      case MessageStatus.sent:
        return Text(
          'Sent',
          style: TextStyle(fontSize: 12, color: Colors.green),
        );
      case MessageStatus.failed:
        return GestureDetector(
          onTap: () => _retryMessage(index),
          child: Text(
            'Failed. Tap to Retry.',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with AI'),
        actions: [
          IconButton(icon: Icon(Icons.file_upload), onPressed: _exportChat),
          IconButton(icon: Icon(Icons.image), onPressed: _pickImage),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(messages[index], index);
              },
            ),
          ),
          _buildChatInput(),
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
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }
}
