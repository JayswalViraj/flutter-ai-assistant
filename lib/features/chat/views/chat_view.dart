import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/chat_controller.dart';
import '../models/chat_message.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFE8EFFF),
              child: Image(image: AssetImage('assets/images/ai_photo.png'),height: 25,width: 25,),
            ),

            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hey, Viraj',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF172B4D),
                  ),
                ),
                Text(
                  'AI Assistant',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Obx(() {
            final isEnabled = controller.isAutoSendEnabled.value;

            return GestureDetector(
              onTap: controller.toggleAutoSend,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? const Color(0xFF3772FF).withOpacity(0.10)
                      : Colors.grey.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isEnabled
                        ? const Color(0xFF3772FF)
                        : Colors.grey.shade400,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      size: 16,
                      color: isEnabled ? const Color(0xFF3772FF) : Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Voice Auto Send',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          isEnabled ? 'ON' : 'OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isEnabled
                                ? const Color(0xFF3772FF)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),

          // Auto Read ON/OFF button
          // Obx(() {
          //   final isEnabled = controller.isAutoReadEnabled.value;

          //   return IconButton(
          //     tooltip: isEnabled ? 'Disable Auto Read' : 'Enable Auto Read',
          //     onPressed: controller.toggleAutoRead,
          //     icon: Icon(
          //       isEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          //       color: isEnabled ? const Color(0xFF3772FF) : Colors.grey,
          //     ),
          //   );
          // }),

          // Clear conversation button
          IconButton(
            tooltip: 'Clear conversation',
            onPressed: controller.clearConversation,
            icon: const Icon(Icons.delete_outline, color: Color(0xFF3772FF)),
          ),
        ],
      ),

      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Obx(() {
              final messages = controller.messages;
              final loading = controller.isLoading.value;

              if (messages.isEmpty && !loading) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: AssetImage('assets/images/ai_photo.png'),
                        width: 55,
                        height: 55,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'How can I help you today?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Ask me anything!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length + (loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (loading && index == 0) {
                    return const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 12, top: 8, bottom: 14),
                        child: _TypingIndicator(),
                      ),
                    );
                  }

                  final messageIndex =
                      messages.length - 1 - (loading ? index - 1 : index);

                  return _messageBubble(messages[messageIndex]);
                },
              );
            }),
          ),

          // Error message
          Obx(() {
            if (controller.errorMessage.value.isEmpty) {
              return const SizedBox.shrink();
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.red.shade50,
              child: Text(
                controller.errorMessage.value,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            );
          }),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _messageBubble(ChatMessage message) {
    final isUser = message.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            constraints: const BoxConstraints(maxWidth: 320),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF3772FF) : Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: isUser
                ? Text(
                    message.text,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  )
                : MarkdownBody(
                    data: message.text,
                    selectable: true,
                    imageBuilder: (uri, title, alt) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            uri.toString(),
                            width: double.infinity,
                            fit: BoxFit.contain,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;

                              return const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text('Unable to load image.'),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF172B4D),
                        height: 1.5,
                      ),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                      code: const TextStyle(
                        backgroundColor: Color(0xFFF0F2F5),
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: const Color(0xFF172B4D),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      codeblockPadding: const EdgeInsets.all(12),
                      h1: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      h2: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                      h3: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),

          // Action icons outside the message bubble
          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message.text));
                    },
                    icon: const Icon(Icons.copy_outlined, size: 17),
                    color: Colors.grey,
                    tooltip: 'Copy',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.speakMessage(message.text);
                    },
                    icon: const Icon(Icons.volume_up_outlined, size: 19),
                    color: Colors.grey,
                    tooltip: 'Read aloud',
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.inputController,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,

                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: InputDecoration(
                  hintText: 'Ask anything...',

                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            Obx(() {
              if (controller.isLoading.value) {
                return CircleAvatar(
                  backgroundColor: Colors.red,
                  child: IconButton(
                    onPressed: controller.stopGeneration,
                    icon: const Icon(Icons.stop_rounded, color: Colors.white),
                  ),
                );
              }

              return CircleAvatar(
                backgroundColor: const Color(0xFF3772FF),
                child: IconButton(
                  onPressed: () {
                    final text = controller.inputController.text;

                    controller.inputController.clear();

                    controller.sendMessage(text);
                  },
                  icon: const Icon(Icons.send_rounded, color: Colors.white),
                ),
              );
            }),
            Obx(() {
              if (controller.isLoading.value) {
                return const SizedBox.shrink();
              }
              return IconButton(
                onPressed: () {
                  if (controller.isListening.value) {
                    controller.stopVoiceInput();
                  } else {
                    controller.startVoiceInput();
                  }
                },
                icon: Icon(
                  controller.isListening.value ? Icons.mic : Icons.mic_none,
                  color: controller.isListening.value
                      ? Colors.red
                      : Colors.blue,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    final text = controller.inputController.text.trim();

    if (text.isEmpty || controller.isLoading.value) return;

    controller.inputController.clear();
    controller.sendMessage(text);
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final activeDot = (_animationController.value * 3).floor();

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: activeDot == index ? 1.0 : 0.3,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF3772FF),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
