import 'package:meta/meta.dart';
import 'ast.dart';
import 'lexer.dart';

/// Parser using the recursive descent method.
class Parser {
  Parser({
    @required this.lexer,
  });

  final Lexer lexer;
  // todo: errors

  ASTNode parse() {
    return _parseProgram();
  }

  ASTNode _parseProgram() {
    return null;
  }
}
