import 'package:flutter_test/flutter_test.dart';
import 'package:interpreter/src/lexer.dart';
import 'package:interpreter/src/parser.dart';

void main() {
  test('hello world', () {
    String program = '''
    flow 'main'
      send text 'Hello World'
    ''';
    var lexer = Lexer(program);
    var parser = Parser(lexer: lexer);
    var parsedAST = parser.parse();
    // todo: expect AST
  });
}
