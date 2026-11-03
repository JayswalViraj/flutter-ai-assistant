import 'package:flutter/widgets.dart';
import 'package:flutterecel/core/services/speech_service.dart';
import 'package:flutterecel/core/services/tts_service.dart';
import 'package:get/get.dart';

import '../../../core/services/ai_service.dart';
import '../models/chat_message.dart';
import 'dart:async';
import 'package:dio/dio.dart';

class ChatController extends GetxController {
  // Controls the current Gemini API request.
  CancelToken? _cancelToken;

  // Controls the character-by-character animation.
  bool _stopTyping = false;

  final AiService _aiService = Get.find<AiService>();

  final SpeechService _speechService = Get.find<SpeechService>();

  final RxBool isListening = false.obs;
  final RxBool isSpeechAvailable = false.obs;

  // Text input controller
  final TextEditingController inputController = TextEditingController();

  // Chat messages
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Error state
  final RxString errorMessage = ''.obs;

  final TtsService _ttsService = Get.find<TtsService>();

  // Auto-read setting. Disabled by default.
  final RxBool isAutoReadEnabled = false.obs;

  final RxBool isAutoSendEnabled = false.obs;

  // Tracks whether voice recognition has actually started.
  bool _hasVoiceSessionStarted = false;

  void toggleAutoSend() {
    isAutoSendEnabled.toggle();
  }

  Future<void> initializeSpeech() async {
    try {
      isSpeechAvailable.value = await _speechService.initialize(
        onStatus: (status) {
          if (status == 'listening') {
            isListening.value = true;
            _hasVoiceSessionStarted = true;
          }

          if (status == 'done' || status == 'notListening') {
            isListening.value = false;

            // Process only after voice recognition has started.
            if (_hasVoiceSessionStarted) {
              _hasVoiceSessionStarted = false;

              if (isAutoSendEnabled.value) {
                final voiceText = inputController.text.trim();

                if (voiceText.isNotEmpty) {
                  inputController.clear();

                  final isCommand = handleVoiceCommand(voiceText);

                  if (!isCommand) {
                    sendMessage(voiceText);
                  }
                }
              }
            }
          }
        },
        onError: (error) {
          isListening.value = false;
          _hasVoiceSessionStarted = false;
          errorMessage.value = error;
        },
      );
    } catch (e) {
      isListening.value = false;
      errorMessage.value = 'Speech initialization failed: $e';
    }
  }

  @override
  void onInit() {
    super.onInit();
    initializeSpeech();
    _ttsService.initialize();
  }

  void toggleAutoRead() {
    isAutoReadEnabled.toggle();

    // Stop current speech when auto-read is disabled.
    if (!isAutoReadEnabled.value) {
      _ttsService.stop();
    }
  }

  Future<void> speakMessage(String text) async {
    await _ttsService.stop();

    final cleanText = removeMarkdownFormatting(text);

    await _ttsService.speak(cleanText);
  }

  Future<void> stopSpeaking() async {
    await _ttsService.stop();
  }

  Future<void> readAnswer(String answer) async {
    if (!isAutoReadEnabled.value) return;

    final cleanText = removeMarkdownFormatting(answer);

    await _ttsService.speak(cleanText);
  }

  Future<void> sendMessage(String value) async {
    final text = value.trim();

    if (text.isEmpty || isLoading.value) return;

    errorMessage.value = '';

    messages.add(ChatMessage(role: 'user', text: text));

    isLoading.value = true;
    _stopTyping = false;

    // Create a new cancellation token for this request.
    final cancelToken = CancelToken();
    _cancelToken = cancelToken;

    try {
      final answer = await _aiService.sendMessage(
        messages.toList(),
        cancelToken: cancelToken,
      );

      // Start typing the AI response.
      if (!_stopTyping) {
        // Start text typing and audio speaking simultaneously.
        final typingFuture = typeMessage(answer);
        final speakingFuture = readAnswer(answer);

        // Wait for text typing to finish.
        await Future.wait([typingFuture, speakingFuture]);
      }
    } catch (e) {
      // Manual cancellation is not an error.
      if (e is DioException && CancelToken.isCancel(e)) {
        return;
      }

      if (e.toString().contains('high demand')) {
        errorMessage.value =
            'AI server is busy. Please try again in a few seconds.';
      } else {
        errorMessage.value = e.toString();
      }
    } finally {
      _cancelToken = null;
      isLoading.value = false;
    }
  }

  // Start voice recognition
  Future<void> startVoiceInput() async {
    if (!isSpeechAvailable.value) {
      await initializeSpeech();
    }

    if (!isSpeechAvailable.value) {
      errorMessage.value = 'Speech recognition is not available.';
      return;
    }

    errorMessage.value = '';

    await _speechService.startListening(
      onResult: (text) {
        inputController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      },
    );

    isListening.value = _speechService.isListening;
  }

  // Stop voice recognition
  Future<void> stopVoiceInput() async {
    await _speechService.stopListening();
    isListening.value = false;
  }

  Future<void> typeMessage(String answer) async {
    final message = ChatMessage(role: 'model', text: '');

    messages.add(message);

    final characters = answer.runes.toList();
    String displayedText = '';

    for (final character in characters) {
      await Future.delayed(const Duration(milliseconds: 20));

      // Stop typing if the user presses Stop.
      if (_stopTyping) break;

      displayedText += String.fromCharCode(character);

      messages[messages.length - 1] = ChatMessage(
        role: 'model',
        text: displayedText,
      );
    }
  }

  bool handleVoiceCommand(String text) {
    final command = text.trim().toLowerCase();

    if (command == 'clear chat' ||
        command == 'clear the chat' ||
        command == 'clear conversation' ||
        command == 'delete chat') {
      clearConversation();
      inputController.clear();
      return true;
    }

    return false;
  }

  String removeMarkdownFormatting(String text) {
    return text
        // Remove bold and italic markers
        .replaceAll(RegExp(r'\*{1,3}'), '')
        // Remove heading markers
        .replaceAll(RegExp(r'^#{1,6}\s*', multiLine: true), '')
        // Remove inline code markers
        .replaceAll('`', '')
        // Remove strikethrough markers
        .replaceAll('~~', '')
        // Remove link formatting but keep link text
        .replaceAllMapped(
          RegExp(r'\[([^\]]+)\]\([^)]+\)'),
          (match) => match.group(1) ?? '',
        );
  }

  void stopGeneration() {
    // Stop text typing.
    _stopTyping = true;

    // Stop audio playback.
    _ttsService.stop();

    // Cancel Gemini API request if running.
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('Stopped by user');
    }
  }

  void clearConversation() {
    messages.clear();
    errorMessage.value = '';
    inputController.clear();
  }

  @override
  void onClose() {
    _speechService.cancelListening();
    inputController.dispose();
    super.onClose();
  }
}
