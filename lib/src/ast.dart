import 'dart:ui';

import 'package:interpreter/src/chatbot.dart';

import 'interpreter.dart';

abstract class ASTNode {
  // may be null
  int lineStart;
  int lineEnd;

  Future<void> execute(RuntimeContext context);

  void log(RuntimeContext context, String message) {
    if (!context.enableLogs) return;
    print('$runtimeType - $message - context=$context');
  }
}

class ProgramNode extends ASTNode {
  ProgramNode({
    this.declarations,
    this.mainFlow,
    this.flows,
  });

  List<ASTNode> declarations;
  FlowNode mainFlow;
  List<FlowNode> flows;

  @override
  Future<void> execute(RuntimeContext context) async {
    log(context, 'execute - called');

    // clear any previous chatbot state when starting a new program
    context.chatbot.clear();

    // put all flows into the context´s lookup table
    // this is required especially by the startFlow statement
    context.flows.putIfAbsent(mainFlow.name, () => mainFlow);
    if (flows != null) {
      for (var flow in flows) {
        context.flows.putIfAbsent(flow.name, () => flow);
      }
    }

    // execute all declarative statments before starting the main flow
    if (declarations != null) {
      for (var statement in declarations) {
        await statement.execute(context);
      }
    }

    // the actual entry point of the conversation
    await mainFlow.execute(context);

    log(context, 'execute - finished');
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

class FlowNode extends ASTNode {
  FlowNode({
    this.name,
    this.statements,
  });

  String name = '';
  List<ASTNode> statements = [];

  @override
  Future<void> execute(RuntimeContext context) async {
    log(context, 'execute - called - FLOW $name');

    // add this flow to the stack because it is now open
    context.openedFlowsStack.add(name);

    // execute all statements of this flow
    for (var statement in statements) {
      await statement.execute(context);

      // end the flow if an endFlow statement was previously executed
      if (statement is EndFlowStatementNode) {
        break;
      }
    }

    // make sure all sub-flows that this flow has opened with a startFlow
    // statement have already ended before this one
    assert(context.currentFlow == name);

    // remove this flow from the stack because it is no longer open
    context.openedFlowsStack.removeLast();

    log(context, 'execute - called - FLOW $name');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return false;
    }
    return other is FlowNode &&
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
    this.params = const {},
  });

  EntityType entityType;
  String entityName = '';
  Map<String, dynamic> params;

  @override
  Future<void> execute(RuntimeContext context) {
    log(context,
        'execute - CREATE ENTITY [type=$entityType, name=$entityName]');
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
  Future<void> execute(RuntimeContext context) {
    log(context,
        'execute - SETTING DELAY [dynamic=$dynamicDelay, millis=$delayInMilliseconds]');
    if (dynamicDelay) {
      context.config.dynamiciallyDelayMessages = true;
    } else {
      context.config.delayInMilliseconds = delayInMilliseconds;
    }
    return Future.value();
  }
}

class SetSenderStatementNode extends ASTNode {
  String senderName;

  @override
  Future<void> execute(RuntimeContext context) {
    log(context, 'execute - SETTING SENDER [name=$senderName]');
  }
}

class StartFlowStatementNode extends ASTNode {
  String flowName;

  @override
  Future<void> execute(RuntimeContext context) async {
    log(context, 'execute - STARTING NEW FLOW $flowName');

    // lookup the flow by its name
    if (!context.flows.containsKey(flowName)) {
      throw 'Flow $flowName does not exist!';
    }
    var flow = context.flows[flowName];

    // start the flow
    await flow.execute(context);
  }
}

class EndFlowStatementNode extends ASTNode {
  @override
  Future<void> execute(RuntimeContext context) {
    log(context, 'execute - FORCEFULLY ENDING CURRENT FLOW');
    return Future.value();
  }
}

enum SendMessageType { text, image, audio, event }

class SendStatementNode extends ASTNode {
  SendStatementNode({
    this.messageType,
    this.messageBody,
    this.params = const {},
  });

  SendMessageType messageType;
  String messageBody;
  Map<String, dynamic> params;

  @override
  Future<void> execute(RuntimeContext context) async {
    log(context, 'execute - called [type=$messageType, body=$messageBody]');

    // determine the delay before sending the message
    int delayInMilliseconds = 0;
    if (params.containsKey('delay') && params['delay'] is int) {
      delayInMilliseconds = params['delay'];
    } else if (context.config.dynamiciallyDelayMessages) {
      // compute delay for this message based on type and body
      // todo
      delayInMilliseconds = 300;
    } else {
      delayInMilliseconds = context.config.delayInMilliseconds;
    }

    if (delayInMilliseconds > 0) {
      // signal the user that the chatbot is typing a message
      context.chatbot.appendMessage(Message.typing());
      // wait for the given amount of time
      await Future.delayed(Duration(milliseconds: delayInMilliseconds));
      // remove the typing indicator
      context.chatbot.removeLastMessage();
    }

    // create the message to be sent
    MessageType type;
    switch (this.messageType) {
      case SendMessageType.text:
        type = MessageType.text;
        break;
      case SendMessageType.image:
        type = MessageType.image;
        break;
      case SendMessageType.audio:
        type = MessageType.audio;
        break;
      case SendMessageType.event:
        type = MessageType.event;
        break;
    }
    Message message = Message(
      type: type,
      body: messageBody,
      params: params,
    );

    // append the new message to the chat
    context.chatbot.appendMessage(message);

    log(context, 'execute - finished [type=$messageType, body=$messageBody]');
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
  int delayInMilliseconds = 0;
  int clickCount = 0;
  String eventName = '';

  @override
  Future<void> execute(RuntimeContext context) {
    log(context, 'execute - called - WAITING [trigger=$trigger]');
    log(context, 'execute - finished');
    throw UnimplementedError();
  }
}

class SingleChoiceStatementNode extends ASTNode {
  List<ChoiceNode> choices;

  @override
  Future<void> execute(RuntimeContext context) {
    log(context, 'execute - called');
    log(context, 'execute - finished');
  }
}

class ChoiceNode extends ASTNode {
  String title;
  List<ASTNode> statements = [];

  @override
  Future<void> execute(RuntimeContext context) {
    log(context, 'execute - called');
    log(context, 'execute - finished');
  }
}
