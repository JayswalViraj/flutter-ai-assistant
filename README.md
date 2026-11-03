# AI Assistant – Flutter & Gemini AI

A Flutter-based AI Assistant application powered by Google's Gemini API. The application supports text conversations, voice input, text-to-speech, and voice commands.

## 1. Project Overview

The goal of this project is to build an AI-powered mobile assistant that allows users to interact with AI through text and voice.

The application uses Flutter for the frontend, GetX for state management and dependency injection, Dio for HTTP requests, and Google's Gemini API for AI responses.

## 2. Features Implemented

### AI Chat
- AI-powered conversations using Gemini API.
- Send text messages and receive AI responses.
- Display Markdown-formatted AI responses.
- Display images included in AI responses.
- Typewriter animation for AI responses.
- Copy AI responses.
- Stop response generation.
- Retry failed requests when Gemini returns HTTP 503.

### Voice Interaction
- Speech-to-text for voice input.
- Text-to-speech for AI responses.
- Auto Read toggle.
- Auto Send toggle.
- Automatically send recognized text when speech recognition finishes.
- Manually send recognized text when Auto Send is disabled.
- Stop text-to-speech.

### Voice Commands
- Clear chat.
- Delete chat.
- Clear conversation.

### Chat Management
- Clear conversation.
- Display user and AI messages separately.
- Show loading and error states.
- Cancel ongoing AI requests.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Programming language |
| GetX | State management and dependency injection |
| Dio | HTTP API communication |
| Gemini API | AI response generation |
| flutter_dotenv | Environment variable configuration |
| speech_to_text | Speech recognition |
| flutter_tts | Text-to-speech |
| flutter_markdown | Markdown rendering |

## 4. Architecture

This project follows a **Feature-First Architecture with a layered separation of responsibilities**, using GetX for state management and dependency injection.

The main idea is to keep API communication, business logic, data models, and UI separate.

### Folder Structure

```text
lib/
│
├── main.dart
│
├── app/
│   ├── routes/
│   │
│   ├── bindings/
│   │   └── chat_binding.dart
│   │
│   └── theme/
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   │
│   └── services/
│       ├── ai_service.dart
│       ├── speech_service.dart
│       └── tts_service.dart
│
└── features/
    └── chat/
        ├── controllers/
        │   └── chat_controller.dart
        │
        ├── models/
        │   └── chat_message.dart
        │
        └── views/
            └── chat_view.dart
```

### Architecture Responsibilities

**1. App Layer**

Contains application-level configuration.

- `routes/`: Application navigation and routes.
- `bindings/`: GetX dependency registration.
- `theme/`: Application themes and styling.

**2. Core Layer**

Contains reusable services and shared configurations.

- `constants/`: API URLs, model configuration, and API settings.
- `services/`: External API communication and device-level services.

**3. Feature Layer**

Contains functionality related to individual application features.

- `controllers/`: Business logic and reactive state management.
- `models/`: Data models and JSON serialization.
- `views/`: User interface and screen widgets.

## 5. State Management – GetX

GetX is used for:

- Reactive state management using `Rx` and `Obx`.
- Dependency injection using `Get.lazyPut()` and `Get.find()`.
- Controller lifecycle management.
- Managing chat messages, loading states, voice states, and application settings.

Example:

```dart
final RxList<ChatMessage> messages = <ChatMessage>[].obs;

final RxBool isLoading = false.obs;

final RxBool isListening = false.obs;

final RxBool isAutoReadEnabled = false.obs;

final RxBool isAutoSendEnabled = false.obs;
```

### Dependency Injection

Dependencies are registered through `ChatBinding`.

```dart
class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiService>(() => AiService());
    Get.lazyPut<SpeechService>(() => SpeechService());
    Get.lazyPut<TtsService>(() => TtsService());
    Get.lazyPut<ChatController>(() => ChatController());
  }
}
```

## 6. Gemini API Integration

The application communicates with Google's Gemini API using Dio.

### API Configuration

- Base URL: `https://generativelanguage.googleapis.com/v1beta`
- Model: `gemini-3.5-flash-lite`
- Endpoint: `/models/{model}:generateContent`

### Request Flow

1. User enters a message.
2. ChatController receives the message.
3. ChatController sends the conversation history to AiService.
4. AiService sends an HTTP request using Dio.
5. Gemini generates the response.
6. AiService returns the response to ChatController.
7. ChatController updates the reactive message list.
8. ChatView displays the response.

### API Handling

- Connection timeout: 30 seconds.
- Send timeout: 30 seconds.
- Receive timeout: 90 seconds.
- Retry failed requests for HTTP 503.
- Retry delay increases exponentially.
- CancelToken supports request cancellation.
- API errors are handled and displayed in the UI.

## 7. Environment Configuration

The project uses `flutter_dotenv` to load environment variables.

### Create `.env`

```env
GEMINI_API_KEY=your_gemini_api_key
```

### pubspec.yaml

```yaml
flutter:
  uses-material-design: true

  assets:
    - .env
```

### Load Environment Variables

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}
```

### API Constants

The API key is accessed through:

```dart
static String get apiKey =>
    dotenv.env['GEMINI_API_KEY'] ?? '';
```

### Git Protection

Add the following to `.gitignore`:

```gitignore
.env
```

**Security Note:** A `.env` file bundled as a Flutter asset does not protect API keys in a distributed APK. For production, Gemini API requests should be handled through a secure backend.

## 8. Speech Recognition

The `SpeechService` manages speech recognition using the `speech_to_text` package.

Responsibilities:

- Initialize speech recognition.
- Check speech recognition availability.
- Start listening.
- Receive partial speech results.
- Stop listening.
- Cancel listening.
- Handle speech status and errors.

The ChatController receives recognized text and updates the input field.

When Auto Send is enabled, the recognized message is automatically sent after speech recognition finishes.

## 9. Text-to-Speech

The `TtsService` manages AI response audio using `flutter_tts`.

Responsibilities:

- Initialize text-to-speech.
- Configure language and speech rate.
- Speak AI responses.
- Stop speech playback.

The application supports:

- Auto Read: Automatically read AI responses.
- Manual Read: Read an individual AI response using the speaker button.
- Stop Reading: Stop current speech playback.

Markdown formatting is cleaned before sending text to the TTS service.

## 10. Application Workflow

```text
                User
                  |
                  v
             ChatView
                  |
                  v
           ChatController
                  |
          +-------+-------+
          |       |       |
          v       v       v
       AiService Speech  TtsService
          |      Service    |
          v        |        v
      Gemini API   v     Device Audio
                Speech
              Recognition
```

## 11. Installation and Setup

### Requirements

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Gemini API key
- Android device or emulator

### Clone the Project

```bash
git clone YOUR_REPOSITORY_URL
```

### Install Dependencies

```bash
flutter pub get
```

### Configure API Key

Create `.env` in the project root and add your Gemini API key.

### Run the Application

```bash
flutter run
```

## 12. Current Development Status

| Module | Status |
|---|---|
| Flutter project setup | Completed |
| GetX architecture | Implemented |
| Gemini API integration | Implemented |
| Dio networking | Implemented |
| Environment configuration | Configured |
| Text chat | Implemented |
| Markdown responses | Implemented |
| Typewriter animation | Implemented |
| Speech-to-text | Implemented |
| Text-to-speech | Implemented |
| Auto Read | Implemented |
| Auto Send | Implemented |
| Voice commands | Implemented |
| Stop generation | Implemented |
| Copy response | Implemented |
| UI/UX refinement | In progress |
| Store information management | Not implemented |
| Secure backend integration | Planned |

## 13. Future Improvements

- Improve overall UI/UX.
- Add store information management.
- Allow the assistant to answer questions using configured store data.
- Add stronger validation for store-specific answers.
- Implement secure backend integration.
- Improve error handling and API security.
- Add persistent conversation history.
- Explore additional AI assistant capabilities.

## 14. Learning Outcomes

Through this project, I am exploring:

- Integrating AI APIs into Flutter applications.
- Managing API requests using Dio.
- Building scalable Flutter architecture.
- Implementing GetX state management.
- Working with speech recognition.
- Implementing text-to-speech.
- Handling asynchronous operations.
- Managing API errors and request cancellation.
- Building voice-based AI interactions.

---

**Project:** AI Assistant

**Platform:** Flutter / Android

**AI Provider:** Google Gemini

**Architecture:** Feature-First Architecture with layered separation of responsibilities

**State Management:** GetX

**Development:** Personal Project