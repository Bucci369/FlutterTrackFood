import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_providers.dart';
import '../../providers/chat_provider.dart'; // Import the file
import '../../widgets/chat_bubble.dart';
import '../../widgets/message_input.dart';
import '../../widgets/quick_actions.dart';
import '../../widgets/typing_indicator.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
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
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF6F1E7), // Apple White
      navigationBar: CupertinoNavigationBar(
        middle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                CupertinoIcons.sparkles,
                size: 18,
                color: CupertinoColors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'KI Ernährungsberater',
              style: AppTypography.headline.copyWith(color: AppColors.label),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFF6F1E7), // Apple White
        border: null,
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            ref.read(chatProvider).clearChat();
            setState(() {
              _showQuickActions = true;
            });
          },
          child: Icon(CupertinoIcons.refresh, color: AppColors.primary),
        ),
      ),
      child: Consumer(
        builder: (context, ref, child) {
          final chat = ref.watch(chatProvider);
          // Auto-scroll when new messages arrive
          if (chat.messages.isNotEmpty) {
            _scrollToBottom();
          }

          return Column(
            children: [
              // Messages Area
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount:
                      chat.messages.length +
                      (chat.isLoading ? 1 : 0) +
                      (_showQuickActions ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Quick Actions (shown at the beginning)
                    if (_showQuickActions && index == 0) {
                      return QuickActions(
                        actions:
                            kQuickActions, // Use the new top-level constant
                        onActionTap: (action) {
                          setState(() {
                            _showQuickActions = false;
                          });
                          chat.sendQuickAction(action);
                        },
                      );
                    }

                    // Adjust index for messages
                    final messageIndex = _showQuickActions ? index - 1 : index;

                    // Loading indicator
                    if (messageIndex >= chat.messages.length) {
                      return const TypingIndicator();
                    }

                    // Regular message
                    final message = chat.messages[messageIndex];
                    return ChatBubble(message: message);
                  },
                ),
              ),

              // Error Display
              if (chat.error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.systemRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.systemRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column( // Use a column for more complex layout
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_circle,
                            color: AppColors.systemRed,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Fehler', // Generic title
                              style: AppTypography.headline.copyWith(
                                color: AppColors.systemRed,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: chat.clearError,
                            child: Text(
                              'Schließen',
                              style: AppTypography.body.copyWith(
                                color: AppColors.systemRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 34, top: 4), // Align with title
                        child: Text(
                          chat.error!, // Display the user-friendly error message
                          style: AppTypography.body.copyWith(
                            color: AppColors.systemRed,
                          ),
                        ),
                      ),
                      // Add retry button if the last message failed
                      if (chat.messages.isNotEmpty && chat.messages.last.isError)
                        Padding(
                          padding: const EdgeInsets.only(left: 34, top: 8),
                          child: CupertinoButton.filled(
                            onPressed: chat.retryLastMessage,
                            child: const Text('Erneut versuchen'),
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
                  chat.sendMessage(message);
                },
                isLoading: chat.isLoading,
              ),
            ],
          );
        },
      ),
    );
  }
}
