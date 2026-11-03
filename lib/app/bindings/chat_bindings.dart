
import 'package:flutterecel/core/services/speech_service.dart';
import 'package:flutterecel/core/services/tts_service.dart';
import 'package:get/get.dart';

import '../../core/services/ai_service.dart';
import '../../features/chat/controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiService>(
      () => AiService(),
    );

    Get.lazyPut<ChatController>(
      () => ChatController(),
    );

      Get.lazyPut<SpeechService>(() => SpeechService());
      Get.lazyPut<TtsService>(() => TtsService());

  }
}
