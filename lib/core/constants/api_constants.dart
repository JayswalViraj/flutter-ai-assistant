
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  static const String model = 'gemini-3.5-flash-lite';

  // Read API key from Flutter build configuration.
  // static const String apiKey = String.fromEnvironment(
  //   'GEMINI_API_KEY',
  // );

  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

  static const String generateContent =
      '/models/$model:generateContent';
}