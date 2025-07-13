import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isLoading;

  const MessageInput({
    super.key,
    required this.onSendMessage,
    this.isLoading = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _controller.text.trim();
    if (message.isNotEmpty && !widget.isLoading) {
      widget.onSendMessage(message);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: CupertinoColors.systemGrey4),
                ),
                child: CupertinoTextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  enabled: !widget.isLoading,
                  placeholder: 'Frage mich etwas über deine Ernährung...',
                  placeholderStyle: TextStyle(
                    color: CupertinoColors.placeholderText,
                    letterSpacing: -0.41,
                  ),
                  style: const TextStyle(
                    letterSpacing: -0.41,
                  ),
                  decoration: const BoxDecoration(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade600, Colors.green.shade500],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(24),
                onPressed: widget.isLoading ? null : _sendMessage,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CupertinoActivityIndicator(
                            color: CupertinoColors.white,
                          ),
                        )
                      : const Icon(
                          CupertinoIcons.paperplane_fill,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
