import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p; // For basename

// Callback type for sending message
typedef SendMessageCallback = void Function(String text, File? image);

class ChatInputField extends StatefulWidget {
  final SendMessageCallback onSendMessage;

  const ChatInputField({Key? key, required this.onSendMessage})
    : super(key: key);

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      // Show confirmation (optional)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Image selected: ${p.basename(pickedFile.path)}"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    final image = _selectedImage;

    if (text.isEmpty && image == null) {
      return; // Don't send empty message
    }

    widget.onSendMessage(text, image); // Pass data up via callback

    // Reset input field state
    _controller.clear();
    setState(() {
      _selectedImage = null;
    });
    FocusScope.of(context).unfocus(); // Hide keyboard
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Take minimum space needed
          children: [
            // --- Image Preview Area ---
            if (_selectedImage != null)
              Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 50,
                              width: 50,
                              color: Colors.grey.shade300,
                              child: Icon(Icons.error),
                            ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.basename(_selectedImage!.path),
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Colors.grey.shade700,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(), // Remove default padding
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      tooltip: 'Remove Image',
                    ),
                  ],
                ),
              ),
            // --- Text Input Row ---
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Align items vertically
              children: [
                // Attach Button
                IconButton(
                  icon: Icon(
                    Icons.attach_file_rounded,
                    color: theme.iconTheme.color?.withOpacity(0.7),
                  ),
                  onPressed: _pickImage,
                  tooltip: 'Attach Image',
                ),
                SizedBox(width: 4), // Small space
                // Text Field
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 2,
                    ), // Adjust padding
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: theme.dividerColor,
                        width: 0.5,
                      ), // Subtle border
                    ),
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        border: InputBorder.none,
                        isDense:
                            true, // Reduces vertical padding inside TextField
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                        ), // Adjust internal padding
                        hintStyle: TextStyle(color: Colors.grey.shade500),
                      ),
                      onSubmitted:
                          (_) => _handleSend(), // Send on keyboard submit
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // Send Button
                Material(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: _handleSend, // Use the handler
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.send_rounded,
                        color: theme.colorScheme.onPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
