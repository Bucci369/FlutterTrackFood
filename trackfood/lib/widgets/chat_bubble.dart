import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, top: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 20,
                color: Colors.green.shade700,
              ),
            ),
          ],
          Expanded(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? LinearGradient(
                        colors: [Colors.green.shade600, Colors.green.shade500],
                      )
                    : null,
                color: isUser ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomRight: isUser ? const Radius.circular(4) : null,
                  bottomLeft: !isUser ? const Radius.circular(4) : null,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: isUser
                        ? Text(
                            message.content,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              height: 1.4,
                            ),
                          )
                        : MarkdownBody(
                            data: message.content,
                            styleSheet: MarkdownStyleSheet(
                              p: TextStyle(
                                color: Colors.grey.shade800,
                                fontSize: 16,
                                height: 1.4,
                              ),
                              strong: TextStyle(
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                              em: TextStyle(
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                              listBullet: TextStyle(
                                color: Colors.green.shade600,
                              ),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                    child: Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(
                        color: isUser ? Colors.white70 : Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, top: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                size: 20,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'jetzt';
    }
  }
}