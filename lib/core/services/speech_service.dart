
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();

  // Initialize speech recognition
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(String error)? onError,
  }) async {
    return await _speechToText.initialize(
      onStatus: onStatus,
      onError: (error) {
        onError?.call(error.errorMsg);
      },
    );
  }

  // Check whether microphone is listening
  bool get isListening => _speechToText.isListening;

  // Start listening to the user's voice
  Future<void> startListening({
    required Function(String text) onResult,
  }) async {
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
      ),
    );
  }

  // Stop listening
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  // Cancel listening
  Future<void> cancelListening() async {
    await _speechToText.cancel();
  }
}
