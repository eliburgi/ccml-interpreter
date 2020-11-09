import 'package:flutter_test/flutter_test.dart';

import 'package:interpreter/src/chatbot.dart';
import 'package:interpreter/src/interpreter.dart';

class MockedChatbot implements Chatbot {
  @override
  void clear() {}

  @override
  void appendMessage(Message message) {}

  @override
  Future<UserInputResponse> waitForInput(UserInput input) {
    return Future.sync(() => null);
  }

  @override
  void removeLastMessage() {}
}

void main() {
  test('hello world', () {
    String program = '''
flow 'main'
  send text 'Hello World'
''';

    var interpreter = Interpreter(MockedChatbot());
    interpreter.interpret(program);
  });
}
