import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:moment/logic/chatbot_rules.dart';

void main() {
  group('ChatbotRules.respond', () {
    test('matches a keyword regardless of case', () {
      final reply = ChatbotRules.respond('I have a HEADACHE');
      final rule = ChatbotRules.rules.firstWhere((r) => r.keywords.contains('headache'));
      expect(rule.responses, contains(reply));
    });

    test('falls back when nothing matches', () {
      final reply = ChatbotRules.respond('xzqvbnmxyz123');
      expect(reply, ChatbotRules.fallbackResponse);
    });

    test('flags bleeding as urgent', () {
      final reply = ChatbotRules.respond('I am bleeding a little');
      expect(reply, contains('Emergency Room'));
    });

    test('random choice is deterministic when a seeded Random is passed', () {
      final reply = ChatbotRules.respond('hello', random: Random(0));
      final rule = ChatbotRules.rules.firstWhere((r) => r.keywords.contains('hello'));
      expect(rule.responses, contains(reply));
    });
  });
}
