import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/message_input.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showQuickActions = true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade400],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'KI Ernährungsberater',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChatProvider>().clearChat();
              setState(() {
                _showQuickActions = true;
              });
            },
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          // Auto-scroll when new messages arrive
          if (chatProvider.messages.isNotEmpty) {
            _scrollToBottom();
          }

          return Column(
            children: [
              // Messages Area
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: chatProvider.messages.length +
                      (chatProvider.isLoading ? 1 : 0) +
                      (_showQuickActions ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Quick Actions (shown at the beginning)
                    if (_showQuickActions && index == 0) {
                      return QuickActions(
                        actions: ChatProvider.quickActions,
                        onActionTap: (action) {
                          setState(() {
                            _showQuickActions = false;
                          });
                          chatProvider.sendQuickAction(action);
                        },
                      );
                    }

                    // Adjust index for messages
                    final messageIndex = _showQuickActions ? index - 1 : index;

                    // Loading indicator
                    if (messageIndex >= chatProvider.messages.length) {
                      return const TypingIndicator();
                    }

                    // Regular message
                    final message = chatProvider.messages[messageIndex];
                    return ChatBubble(message: message);
                  },
                ),
              ),

              // Error Display
              if (chatProvider.error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fehler: ${chatProvider.error}',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                      TextButton(
                        onPressed: chatProvider.clearError,
                        child: Text(
                          'Schließen',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Message Input
              MessageInput(
                onSendMessage: (message) {
                  setState(() {
                    _showQuickActions = false;
                  });
                  chatProvider.sendMessage(message);
                },
                isLoading: chatProvider.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
