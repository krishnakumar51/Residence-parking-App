import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_app/controllers/chat_controller.dart';

class FloatingChatOverlay extends GetView<ChatController> {
  FloatingChatOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final overlayWidth = screenSize.width * 0.85;
    final overlayHeight = screenSize.height * 0.55;

    return Material(
      type: MaterialType.card,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: overlayWidth,
        height: overlayHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Professor',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            // Chat area
            Expanded(
              child: Obx(() => ListView.builder(
                    controller: controller.scrollController,
                    reverse: true,
                    itemCount: controller.messages.length,
                    itemBuilder: (context, index) {
                      final message = controller.messages[index];
                      final isUser = message.startsWith("You:");
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isUser ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              message.substring(message.indexOf(":") + 2),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
            ),
            // Input area
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Obx(() => controller.isListening.value
                      ? Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            controller.recognizedText.value,
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                      : SizedBox.shrink()),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.textController.value,
                          focusNode: controller.focusNode,
                          decoration: InputDecoration(
                            hintText: 'Type a message',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                          ),
                          onSubmitted: (_) => controller.sendMessage(),
                        ),
                      ),
                      SizedBox(width: 8),
                      Obx(() => GestureDetector(
                            onLongPressStart: (_) =>
                                controller.startListening(),
                            onLongPressEnd: (_) => controller.stopListening(),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.all(
                                  controller.isListening.value ? 12 : 8),
                              decoration: BoxDecoration(
                                color: controller.isListening.value
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (controller.isListening.value)
                                    PulsatingCircle(),
                                  Icon(
                                    controller.isListening.value
                                        ? Icons.mic
                                        : Icons.mic_none,
                                    color: Colors.blue,
                                    size:
                                        controller.isListening.value ? 28 : 24,
                                  ),
                                ],
                              ),
                            ),
                          )),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.blue),
                        onPressed: () => controller.sendMessage(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PulsatingCircle extends StatefulWidget {
  @override
  _PulsatingCircleState createState() => _PulsatingCircleState();
}

class _PulsatingCircleState extends State<PulsatingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 40 * _animation.value,
          height: 40 * _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.withOpacity(0.3),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
