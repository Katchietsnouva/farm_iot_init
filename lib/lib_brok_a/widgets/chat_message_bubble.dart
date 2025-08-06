import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart'; // Import the ChatMessage model

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubble({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final bubbleColor =
        message.isSentByMe
            ? theme.colorScheme.primary
            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300);
    final textColor =
        message.isSentByMe
            ? theme.colorScheme.onPrimary
            : theme.textTheme.bodyLarge?.color ??
                (isDarkMode ? Colors.white : Colors.black87);

    final borderRadius = BorderRadius.circular(18);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisAlignment:
            message.isSentByMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // AI Profile Pic on Left
          if (!message.isSentByMe) ...[
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(message.profileUrl),
              backgroundColor: Colors.transparent,
            ),
            SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isSentByMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
              children: [
                // Display Image if available
                if (message.imagePath != null &&
                    File(
                      message.imagePath!,
                    ).existsSync()) // Check if file exists
                  Container(
                    margin: EdgeInsets.only(
                      bottom: message.text.isNotEmpty ? 8 : 0,
                    ),
                    constraints: BoxConstraints(
                      maxHeight: 200,
                      maxWidth: MediaQuery.of(context).size.width * 0.6,
                    ),
                    decoration: BoxDecoration(borderRadius: borderRadius),
                    child: ClipRRect(
                      borderRadius: borderRadius,
                      child: Image.file(
                        File(message.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Simple error display if image file is invalid/missing
                          return Container(
                            height: 50,
                            color: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                // Message Text Bubble
                if (message.text.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: borderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                  ),

                SizedBox(height: 5),
                Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // User Profile Pic on Right
          if (message.isSentByMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage(message.profileUrl),
              backgroundColor: Colors.transparent,
            ),
          ],
        ],
      ),
    );
  }
}
