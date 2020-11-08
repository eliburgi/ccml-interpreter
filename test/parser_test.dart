import 'package:flutter_test/flutter_test.dart';
import 'package:interpreter/src/ast.dart';
import 'package:interpreter/src/lexer.dart';
import 'package:interpreter/src/parser.dart';

void main() {
  test('hello world', () {
    String program = '''
flow 'main'
  send text 'Hello World'
''';

    var lexer = Lexer(program, enableLogs: false);
    var parser = Parser(lexer);
    var tree = parser.parse();

    expect(
      tree,
      ProgramNode(
        mainFlow: FlowStatementNode(
          name: 'main',
          statements: [
            SendStatementNode(
              messageType: MessageType.text,
              messageBody: 'Hello World',
            ),
          ],
        ),
      ),
    );
  });
}
