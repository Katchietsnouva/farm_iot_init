import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  final String aiProfileImageUrl; // Pass the AI profile image path

  const TypingIndicator({Key? key, required this.aiProfileImageUrl})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final bubbleColor =
        isDarkMode ? Colors.grey.shade800 : Colors.grey.shade300;
    final textColor =
        theme.textTheme.bodyLarge?.color ??
        (isDarkMode ? Colors.white : Colors.black87);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage(aiProfileImageUrl),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              "AI is typing...", // TODO: Implement animation later if desired
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
