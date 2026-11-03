
class ChatMessage {
  final String role;
  final String text;

  ChatMessage({
    required this.role,
    required this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'parts': [
        {'text': text},
      ],
    };
  }
}
