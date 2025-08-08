// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// // import 'screens/quiz_screen.dart'; // We will create this file next

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// Future<void> main() async {
//   // Load the environment variables from the .env file
//   await dotenv.load(fileName: ".env");
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Farm Quiz Assistant',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
//         useMaterial3: true,
//       ),
//       darkTheme: ThemeData.dark(useMaterial3: true),
//       themeMode: ThemeMode.system,
//       home: const QuizScreen(),
//     );
//   }
// }

// // --- Data Model for a Message ---
// class ChatMessage {
//   final String text;
//   final bool isUser;

//   ChatMessage({required this.text, required this.isUser});
// }

// // --- The Main Screen Widget ---
// class QuizScreen extends StatefulWidget {
//   const QuizScreen({super.key});

//   @override
//   State<QuizScreen> createState() => _QuizScreenState();
// }

// class _QuizScreenState extends State<QuizScreen> {
//   final TextEditingController _textController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<ChatMessage> _messages = [];
//   bool _isAiTyping = false;
//   bool _isQuizActive = false;

//   // --- Quiz Content ---
//   final List<String> _quizQuestions = [
//     "What type of crop are you primarily growing?",
//     "What is the approximate size of your farm in acres?",
//     "What is the biggest challenge you're facing? (e.g., pests, irrigation, soil quality)",
//     "Are you using any technology (like drones or sensors) on your farm right now?",
//   ];
//   final List<String> _userAnswers = [];
//   int _currentQuestionIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     // Start with a welcome message
//     _addMessage(
//       "Hello! I'm your farm assistant. Tap 'Start Quiz' to begin.",
//       isUser: false,
//     );
//   }

//   void _addMessage(String text, {required bool isUser}) {
//     setState(() {
//       _messages.insert(0, ChatMessage(text: text, isUser: isUser));
//     });
//     // Scroll to the latest message
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }

//   void _startQuiz() {
//     setState(() {
//       _isQuizActive = true;
//       _userAnswers.clear();
//       _currentQuestionIndex = 0;
//     });
//     // Ask the first question
//     _addMessage(_quizQuestions[_currentQuestionIndex], isUser: false);
//   }

//   void _handleSubmittedAnswer(String text) {
//     if (text.trim().isEmpty) return;

//     // Add user's answer to the chat and data list
//     _addMessage(text, isUser: true);
//     _userAnswers.add(text);
//     _textController.clear();

//     // Move to the next question or end the quiz
//     _currentQuestionIndex++;
//     if (_currentQuestionIndex < _quizQuestions.length) {
//       // Ask the next question after a short delay
//       Future.delayed(const Duration(milliseconds: 500), () {
//         _addMessage(_quizQuestions[_currentQuestionIndex], isUser: false);
//       });
//     } else {
//       // Quiz finished, send to AI
//       setState(() {
//         _isQuizActive = false;
//       });
//       _submitQuizToAI();
//     }
//   }

//   Future<void> _submitQuizToAI() async {
//     _addMessage("Thanks! Analyzing your answers...", isUser: false);
//     setState(() {
//       _isAiTyping = true;
//     });

//     // Format the prompt for the AI
//     final promptBuffer = StringBuffer();
//     promptBuffer.writeln(
//       "Analyze the following farm quiz results and provide personalized advice and insights:\n",
//     );
//     for (int i = 0; i < _quizQuestions.length; i++) {
//       promptBuffer.writeln("Question: ${_quizQuestions[i]}");
//       promptBuffer.writeln("Answer: ${_userAnswers[i]}\n");
//     }

//     try {
//       final aiResponse = await _fetchAIResponse(promptBuffer.toString());
//       _addMessage(aiResponse, isUser: false);
//     } catch (e) {
//       _addMessage("Sorry, an error occurred: $e", isUser: false);
//     } finally {
//       setState(() {
//         _isAiTyping = false;
//       });
//     }
//   }

//   Future<String> _fetchAIResponse(String prompt) async {
//     final apiKey = dotenv.env['AZURE_DEPLOYMENT_TOKEN'];
//     if (apiKey == null) {
//       throw Exception("API Key not found in .env file.");
//     }

//     const endpointUrl = "https://22071-ma0ywu5s-eastus2.openai.azure.com";
//     const deploymentName = "gpt-4o-mini";
//     const apiVersion = "2024-02-15-preview";
//     final url = Uri.parse(
//       "$endpointUrl/openai/deployments/$deploymentName/chat/completions?api-version=$apiVersion",
//     );

//     final messagesPayload = [
//       {
//         "role": "system",
//         "content":
//             "You are an intelligent farm assistant who analyzes quiz results.",
//       },
//       {"role": "user", "content": prompt},
//     ];

//     final response = await http.post(
//       url,
//       headers: {"Content-Type": "application/json", "api-key": apiKey},
//       body: jsonEncode({
//         "messages": messagesPayload,
//         "temperature": 0.7,
//         "max_tokens": 1000,
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       return data['choices'][0]['message']['content'];
//     } else {
//       throw Exception("API Error: ${response.statusCode}\n${response.body}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Farm Quiz Assistant 🧑‍🌾"),
//         backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
//       ),
//       body: Column(
//         children: [
//           // Chat Messages
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               reverse: true, // To show new messages at the bottom
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 return _ChatMessageBubble(message: message);
//               },
//             ),
//           ),
//           if (_isAiTyping)
//             const Padding(
//               padding: EdgeInsets.all(8.0),
//               child: _TypingIndicator(),
//             ),
//           // Input Area
//           const Divider(height: 1.0),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//             child: _buildInputArea(),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInputArea() {
//     if (_isQuizActive) {
//       // Show text field for answering questions
//       return Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _textController,
//               decoration: InputDecoration(
//                 hintText: "Type your answer here...",
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
//               ),
//               onSubmitted: _handleSubmittedAnswer,
//             ),
//           ),
//           const SizedBox(width: 8.0),
//           IconButton.filled(
//             icon: const Icon(Icons.send),
//             onPressed: () => _handleSubmittedAnswer(_textController.text),
//           ),
//         ],
//       );
//     } else {
//       // Show "Start Quiz" button
//       return Center(
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.quiz_outlined),
//           label: Text(_userAnswers.isEmpty ? "Start Quiz" : "Start a New Quiz"),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//             textStyle: const TextStyle(fontSize: 16),
//           ),
//           onPressed: _isAiTyping ? null : _startQuiz,
//         ),
//       );
//     }
//   }
// }

// // --- Reusable Chat Bubble Widget ---
// class _ChatMessageBubble extends StatelessWidget {
//   const _ChatMessageBubble({required this.message});
//   final ChatMessage message;

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isUser = message.isUser;
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
//       child: Row(
//         mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 vertical: 10.0,
//                 horizontal: 16.0,
//               ),
//               decoration: BoxDecoration(
//                 color:
//                     isUser
//                         ? theme.colorScheme.primary
//                         : theme.colorScheme.secondaryContainer,
//                 borderRadius: BorderRadius.circular(18.0),
//               ),
//               child: Text(
//                 message.text,
//                 style: TextStyle(
//                   color:
//                       isUser
//                           ? theme.colorScheme.onPrimary
//                           : theme.colorScheme.onSecondaryContainer,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // --- Simple Typing Indicator ---
// class _TypingIndicator extends StatelessWidget {
//   const _TypingIndicator();
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
//           child: Container(
//             padding: const EdgeInsets.symmetric(
//               vertical: 14.0,
//               horizontal: 16.0,
//             ),
//             decoration: BoxDecoration(
//               color: Theme.of(context).colorScheme.secondaryContainer,
//               borderRadius: BorderRadius.circular(18.0),
//             ),
//             child: const SizedBox(width: 40, child: LinearProgressIndicator()),
//           ),
//         ),
//       ],
//     );
//   }
// }
