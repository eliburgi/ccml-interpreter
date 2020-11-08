import 'package:flutter_test/flutter_test.dart';
import 'package:interpreter/src/lexer.dart';
import 'package:interpreter/src/token.dart';

void main() {
  test('hello world', () {
    String program = '''
flow 'main'
  send text 'Hello World'
''';

    var lexer = Lexer(program);
    var parsedTokens = <Token>[];
    var token = lexer.next();
    while (token.type != TokenType.eof) {
      parsedTokens.add(token);
      token = lexer.next();
    }
    parsedTokens.add(token);

    expect(parsedTokens, [
      Token(type: TokenType.flow),
      Token(type: TokenType.string, value: 'main'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.indent),
      Token(type: TokenType.send),
      Token(type: TokenType.text),
      Token(type: TokenType.string, value: 'Hello World'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.dedent),
      Token(type: TokenType.eof),
    ]);
  });

  test('hello world with missing indent', () {
    String program = '''
flow 'main'
send text 'Hello World'
''';

    var lexer = Lexer(program);
    var parsedTokens = <Token>[];
    var token = lexer.next();
    while (token.type != TokenType.eof) {
      parsedTokens.add(token);
      token = lexer.next();
    }
    parsedTokens.add(token);

    expect(parsedTokens, [
      Token(type: TokenType.flow),
      Token(type: TokenType.string, value: 'main'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.send),
      Token(type: TokenType.text),
      Token(type: TokenType.string, value: 'Hello World'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.eof),
    ]);
  });

  test('hello world with too many indents', () {
    String program = '''
flow 'main'
    send text 'Hello World'
''';

    var lexer = Lexer(program);
    var parsedTokens = <Token>[];
    var token = lexer.next();
    while (token.type != TokenType.eof) {
      parsedTokens.add(token);
      token = lexer.next();
    }
    parsedTokens.add(token);

    expect(parsedTokens, [
      Token(type: TokenType.flow),
      Token(type: TokenType.string, value: 'main'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.indent),
      Token(type: TokenType.indent),
      Token(type: TokenType.send),
      Token(type: TokenType.text),
      Token(type: TokenType.string, value: 'Hello World'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.dedent),
      Token(type: TokenType.dedent),
      Token(type: TokenType.eof),
    ]);
  });

  test('invalid indent', () {
    String program = '''
flow 'main'
  send text 'valid indent (2 whitespace)'
   send text 'invalid indent (3 whitespace)'
''';

    var lexer = Lexer(program);
    var parsedTokens = <Token>[];
    var token = lexer.next();
    while (token.type != TokenType.eof) {
      parsedTokens.add(token);
      token = lexer.next();
    }
    parsedTokens.add(token);

    expect(lexer.errors.isNotEmpty, true);
  });

  test('invalid dedent', () {
    String program = '''
flow 'main'
  send text 'valid indent'
 send text 'invalid dedent'
''';

    var lexer = Lexer(program);
    var parsedTokens = <Token>[];
    var token = lexer.next();
    while (token.type != TokenType.eof) {
      parsedTokens.add(token);
      token = lexer.next();
    }
    parsedTokens.add(token);

    expect(lexer.errors.isNotEmpty, true);
  });

  test('send statements', () {
    String program = '''
flow 'main'
  send text 'Hello World'
  send image ''
  send audio 'url'
  send event 'eventId'
    data = 123
''';

    var lexer = Lexer(program);
    var parsedTokens = <Token>[];
    var token = lexer.next();
    while (token.type != TokenType.eof) {
      parsedTokens.add(token);
      token = lexer.next();
    }
    parsedTokens.add(token);

    expect(parsedTokens, [
      Token(type: TokenType.flow),
      Token(type: TokenType.string, value: 'main'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.indent),
      Token(type: TokenType.send),
      Token(type: TokenType.text),
      Token(type: TokenType.string, value: 'Hello World'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.send),
      Token(type: TokenType.image),
      Token(type: TokenType.string, value: ''),
      Token(type: TokenType.newLine),
      Token(type: TokenType.send),
      Token(type: TokenType.audio),
      Token(type: TokenType.string, value: 'url'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.send),
      Token(type: TokenType.event),
      Token(type: TokenType.string, value: 'eventId'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.indent),
      Token(type: TokenType.name, value: 'data'),
      Token(type: TokenType.assign),
      Token(type: TokenType.integer, value: 123),
      Token(type: TokenType.newLine),
      Token(type: TokenType.dedent),
      Token(type: TokenType.dedent),
      Token(type: TokenType.eof),
    ]);
  });

  test('multiple flows', () {
    String program = '''
flow 'main'
  send text 'Hello World'
flow 'welcome'
  send text 'Welcome'



flow 'bye'
  send text 'Bye bye'
''';

    var lexer = Lexer(program);
    var parsedTokens = <Token>[];
    var token = lexer.next();
    while (token.type != TokenType.eof) {
      parsedTokens.add(token);
      token = lexer.next();
    }
    parsedTokens.add(token);

    expect(parsedTokens, [
      Token(type: TokenType.flow),
      Token(type: TokenType.string, value: 'main'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.indent),
      Token(type: TokenType.send),
      Token(type: TokenType.text),
      Token(type: TokenType.string, value: 'Hello World'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.dedent),
      Token(type: TokenType.newLine),
      Token(type: TokenType.newLine),
      Token(type: TokenType.newLine),
      Token(type: TokenType.flow),
      Token(type: TokenType.string, value: 'welcome'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.indent),
      Token(type: TokenType.send),
      Token(type: TokenType.text),
      Token(type: TokenType.string, value: 'Welcome'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.dedent),
      Token(type: TokenType.flow),
      Token(type: TokenType.string, value: 'bye'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.indent),
      Token(type: TokenType.send),
      Token(type: TokenType.text),
      Token(type: TokenType.string, value: 'Bye bye'),
      Token(type: TokenType.newLine),
      Token(type: TokenType.dedent),
      Token(type: TokenType.eof),
    ]);
  });
}
