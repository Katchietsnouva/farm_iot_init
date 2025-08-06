// dart run build_runner build --delete-conflicting-outputs

import 'package:hive/hive.dart';
import 'dart:io'; // Needed only if using File type directly, often path is enough

// This tells the build runner where to put the generated Hive adapter code
part 'chat_message.g.dart';

@HiveType(typeId: 0) // Unique ID for this Hive object type
class ChatMessage extends HiveObject {
  @HiveField(0)
  final String text;

  @HiveField(1)
  final bool isSentByMe;

  @HiveField(2)
  final DateTime timestamp;

  @HiveField(3)
  final String profileUrl;

  // Store the local path of the image if one was attached
  @HiveField(4)
  final String? imagePath;

  // Constructor
  ChatMessage({
    required this.text,
    required this.isSentByMe,
    required this.timestamp,
    required this.profileUrl,
    this.imagePath, // Make optional
  });
}
