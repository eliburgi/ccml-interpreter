import 'package:interpreter/src/ast.dart';

import 'lexer.dart';
import 'parser.dart';

class Interpreter {
  Future<void> interpret(String program) async {
    var lexer = Lexer(program);
    var parser = Parser(lexer);

    var tree = parser.parse();
    var context = ExecutionContext();
    await tree.execute(context);
  }
}

abstract class Chatbot {}
