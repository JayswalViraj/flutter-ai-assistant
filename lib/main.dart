
import 'package:flutter/material.dart';
import 'package:flutterecel/app/bindings/chat_bindings.dart';
import 'package:get/get.dart';

import 'features/chat/views/chat_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Assistant',
      initialBinding: ChatBinding(),
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3772FF),
      ),
      home: const ChatView(),
    );
  }
}
