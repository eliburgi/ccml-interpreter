import 'package:flutter_test/flutter_test.dart';
import 'package:interpreter/src/interpreter.dart';

void main() {
  test('hello world', () {
    String program = '''
flow 'main'
  send text 'Hello World'
''';

    var interpreter = Interpreter();
    interpreter.interpret(program);
  });
}
