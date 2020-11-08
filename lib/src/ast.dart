import 'dart:ui';

import 'package:meta/meta.dart';

class ExecutionContext {}

abstract class ASTNode {
  // may be null
  int lineStart;
  int lineEnd;

  Future<void> execute(ExecutionContext context);

  final bool enableLogs = true;

  void log(String message) {
    if (!enableLogs) return;
    print('$runtimeType - $message');
  }
}

class ProgramNode extends ASTNode {
  ProgramNode({
    this.declarations,
    this.mainFlow,
    this.flows,
  });

  List<ASTNode> declarations;
  ASTNode mainFlow;
  List<ASTNode> flows;

  @override
  Future<void> execute(ExecutionContext context) async {
    log('execute - called - context: $context');

    if (declarations != null) {
      for (var statement in declarations) {
        await statement.execute(context);
      }
    }

    await mainFlow.execute(context);

    log('execute - finished - context: $context');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return false;
    }
    return other is ProgramNode;
  }

  @override
  int get hashCode => hashList([]);
}

class BlockNode extends ASTNode {
  BlockNode({
    @required this.statements,
  });

  final List<ASTNode> statements;

  @override
  Future<void> execute(ExecutionContext context) async {
    log('execute - called - context: $context');

    for (var statement in statements) {
      await statement.execute(context);
    }

    log('execute - finished - context: $context');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return false;
    }
    return other is BlockNode && this.statements == other.statements;
  }

  @override
  int get hashCode => hashList([this.statements]);
}

class FlowStatementNode extends ASTNode {
  FlowStatementNode({
    this.name,
    this.statements,
  });

  String name = '';
  List<ASTNode> statements = [];

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');
    log('execute - finished - context: $context');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return false;
    }
    return other is FlowStatementNode &&
        this.name == other.name &&
        this.statements == other.statements;
  }

  @override
  int get hashCode => hashList([this.name]);
}

enum EntityType { sender, counter }

class CreateStatementNode extends ASTNode {
  CreateStatementNode({
    this.entityType,
    this.entityName,
    this.params,
  });

  EntityType entityType;
  String entityName = '';
  Map<String, dynamic> params = {};

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');

    // todo

    log('execute - finished - context: $context');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return false;
    }
    return other is CreateStatementNode &&
        this.entityType == other.entityType &&
        this.entityName == other.entityName;
  }

  @override
  int get hashCode => hashList([this.entityType, this.entityName]);
}

class SetDelayStatementNode extends ASTNode {
  bool dynamicDelay = false;
  int delayInMilliseconds = 0;

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');

    // todo

    log('execute - finished - context: $context');
  }
}

class SetSenderStatementNode extends ASTNode {
  String senderName;

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');

    // todo

    log('execute - finished - context: $context');
  }
}

class StartFlowStatementNode extends ASTNode {
  String flowName;

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');

    // todo

    log('execute - finished - context: $context');
  }
}

class EndFlowStatementNode extends ASTNode {
  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');

    // todo

    log('execute - finished - context: $context');
  }
}

enum MessageType { text, image, audio, event }

class SendStatementNode extends ASTNode {
  SendStatementNode({
    this.messageType,
    this.messageBody,
    this.params,
  });

  MessageType messageType;
  String messageBody;
  Map<String, dynamic> params = {};

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');
    log('execute - finished - context: $context');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return false;
    }
    return other is SendStatementNode &&
        this.messageType == other.messageType &&
        this.messageBody == other.messageBody;
  }

  @override
  int get hashCode => hashList([this.messageType, this.messageBody]);
}

enum TriggerType { delay, click, event }

class WaitStatementNode extends ASTNode {
  TriggerType trigger;
  int delayInMilliseconds;
  int clickCount;
  String eventName;

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');
    log('execute - finished - context: $context');
  }
}

class SingleChoiceStatementNode extends ASTNode {
  List<ChoiceNode> choices;

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');
    log('execute - finished - context: $context');
  }
}

class ChoiceNode extends ASTNode {
  String title;
  List<ASTNode> statements = [];

  @override
  Future<void> execute(ExecutionContext context) {
    log('execute - called - context: $context');
    log('execute - finished - context: $context');
  }
}
