import 'package:interpreter/src/ast.dart';
import 'package:meta/meta.dart';

import 'chatbot.dart';
import 'lexer.dart';
import 'parser.dart';

class Interpreter {
  Interpreter(this.chatbot);

  final Chatbot chatbot;

  Future<void> interpret(String program) async {
    var lexer = Lexer(program);
    var parser = Parser(lexer);

    var tree = parser.parse();
    var context = RuntimeContext(
      chatbot: chatbot,
    );
    await tree.execute(context);
  }
}

class RuntimeContext {
  RuntimeContext({
    @required this.chatbot,
    this.enableLogs = true,
  });

  final Chatbot chatbot;
  final Config config = Config();

  final bool enableLogs;

  /// A lookup table that contains references to all flows with their
  /// names as keys.
  Map<String, ASTNode> flows = {};

  /// A stack containing all currently open flows.
  List<String> openedFlowsStack = [];

  /// The most recent flow that is currently open.
  ///
  /// Represented by the top-most flow on the [openedFlowsStack].
  String get currentFlow =>
      openedFlowsStack.isNotEmpty ? openedFlowsStack.last : null;

  bool get hasCurrentFlow => currentFlow != null;
}

class Config {
  bool dynamiciallyDelayMessages = false;
  int delayInMilliseconds = 0;
}
