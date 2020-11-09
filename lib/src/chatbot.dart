import 'package:meta/meta.dart';

abstract class Chatbot {
  /// Clears the current state of the chatbot.
  ///
  /// This includes clearing the chat history, any user input that is shown,
  /// etc.
  void clear();

  /// Appends a new message to the chat.
  void appendMessage(Message message);

  /// Removes the latest appended message.
  void removeLastMessage();

  /// Prompts the user to input something and waits for the user to
  /// input something.
  Future<UserInputResponse> waitForInput(UserInput input);
}

enum MessageType { text, image, audio, event, typing }

class Message {
  Message({
    @required this.type,
    @required this.body,
    this.params = const {},
  });

  const Message.typing()
      : type = MessageType.typing,
        body = '',
        params = const {};

  final MessageType type;
  final String body;
  final Map<String, dynamic> params;
}

enum UserInputType { singleChoice }

class UserInput {
  UserInput.singleChoice({@required this.choiceTitles})
      : assert(choiceTitles.isNotEmpty),
        type = UserInputType.singleChoice;

  final UserInputType type;

  // for single choice
  final List<String> choiceTitles;
}

class UserInputResponse {
  UserInputResponse.singleChoice({@required this.selectedChoice})
      : type = UserInputType.singleChoice;

  final UserInputType type;

  // for single choice
  final int selectedChoice;
}
