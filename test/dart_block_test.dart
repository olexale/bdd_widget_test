import 'package:bdd_widget_test/src/step_generator.dart';
import 'package:bdd_widget_test/src/util/dart_block.dart';
import 'package:test/test.dart';

void main() {
  group('readDartBlock', () {
    // Each case is a block at the start of the text; the value is the block,
    // or null when nothing closes it.
    const cases = <String, String?>{
      '{42} tail': '{42}',
      '{const {1: 2}} tail': '{const {1: 2}}',
      "{'a{b'} tail": "{'a{b'}",
      "{'}'} tail": "{'}'}",
      '{"{"} tail': '{"{"}',
      '''{"it's"} tail''': '''{"it's"}''',
      r"{'it\'s }'} tail": r"{'it\'s }'}",
      r"{'a\\'} tail": r"{'a\\'}",
      "{func foo(){} func bar() {print('hey');}} code":
          "{func foo(){} func bar() {print('hey');}}",
      // A string nothing closes: braces are counted alone.
      "{it's} tail": "{it's}",
      "{'a}' + 'b} tail": "{'a}",
      '{unclosed': null,
    };
    cases.forEach((text, block) {
      test(text, () {
        final end = readDartBlock(text, 0)?.end;
        expect(end == null ? null : text.substring(0, end), block);
      });
    });

    test('starts at the given brace', () {
      expect(readDartBlock("I see {'}'} text", 6)?.end, 11);
    });

    List<(String, String)>? strings(String block) => readDartBlock(
      block,
      0,
    )?.strings.map((s) => (block.substring(s.start, s.end), s.quote)).toList();

    test('reports the text of each string with its quote', () {
      expect(strings(r"""{'a' + "b\"" + 'c{'}"""), [
        ('a', "'"),
        (r'b\"', '"'),
        ('c{', "'"),
      ]);
    });

    test('code outside strings is not a string', () {
      expect(strings('{1 + 1}'), isEmpty);
    });

    test('a block read by counting has no strings', () {
      expect(strings("{it's}"), isEmpty);
    });
  });

  group('parseRawStepLine', () {
    test('a brace inside a string stays in its parameter', () {
      expect(parseRawStepLine("I see {'a{b'} and {'}'} text"), [
        'I see  and  text',
        "'a{b'",
        "'}'",
      ]);
    });

    test('a block with a string nothing closes is split by counting', () {
      expect(parseRawStepLine("I see {it's} text"), [
        'I see  text',
        "it's",
      ]);
    });

    test('a block nothing closes is dropped with the rest of the line', () {
      expect(parseRawStepLine('I see {oops text'), ['I see ']);
    });
  });
}
