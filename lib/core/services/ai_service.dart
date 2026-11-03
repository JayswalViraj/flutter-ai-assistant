import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../../features/chat/models/chat_message.dart';

class AiService {
  late final Dio _dio;

  AiService() {
    if (ApiConstants.apiKey.isEmpty) {
      throw Exception(
        'Gemini API key is missing. '
        'Run the app with GEMINI_API_KEY.',
      );
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 90),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': ApiConstants.apiKey,
        },
      ),
    );
  }

  Future<String> sendMessage(List<ChatMessage> messages, {
  required CancelToken cancelToken,
} ) async {
    int retry = 0;


    final requestBody = {
      'contents': messages.map((message) => message.toJson()).toList(),
    };



    while (retry < 3) {
      try {
        final response = await _dio.post(
          ApiConstants.generateContent,
          data: requestBody,
            cancelToken: cancelToken,

        );

        final candidates = response.data['candidates'];

        if (candidates == null || candidates.isEmpty) {
          throw Exception('AI did not generate a response.');
        }

        return candidates[0]['content']['parts'][0]['text'];
      } on DioException catch (e) {

          if (CancelToken.isCancel(e)) {
  rethrow;
}

        // Retry only for 503
        if (e.response?.statusCode == 503 && retry < 2) {

          await Future.delayed(Duration(seconds: 1 << retry));
          retry++;
          continue;
        }

        throw Exception(
          e.response?.data?['error']?['message'] ?? 'Network error',
        );
      }
    }

    throw Exception('Unable to get response.');
  }
}
