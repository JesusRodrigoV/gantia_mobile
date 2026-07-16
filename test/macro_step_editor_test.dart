import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/widgets/macro_step_utils.dart';

void main() {
  group('parsePipeToSteps', () {
    test('parses single step without value', () {
      final steps = parsePipeToSteps('left_click');
      expect(steps.length, 1);
      expect(steps[0].action, 'left_click');
      expect(steps[0].value, isNull);
    });

    test('parses single step with value', () {
      final steps = parsePipeToSteps('open_browser:url');
      expect(steps.length, 1);
      expect(steps[0].action, 'open_browser');
      expect(steps[0].value, 'url');
    });

    test('parses multiple steps', () {
      final steps = parsePipeToSteps('open_browser:url|delay:2|hotkey:f11');
      expect(steps.length, 3);
      expect(steps[0].action, 'open_browser');
      expect(steps[0].value, 'url');
      expect(steps[1].action, 'delay');
      expect(steps[1].value, '2');
      expect(steps[2].action, 'hotkey');
      expect(steps[2].value, 'f11');
    });

    test('returns empty list for empty string', () {
      expect(parsePipeToSteps(''), isEmpty);
    });

    test('returns empty list for null', () {
      expect(parsePipeToSteps(null), isEmpty);
    });

    test('trims whitespace from actions and values', () {
      final steps = parsePipeToSteps(' hotkey : ctrl,c | delay : 0.5 ');
      expect(steps.length, 2);
      expect(steps[0].action, 'hotkey');
      expect(steps[0].value, 'ctrl,c');
      expect(steps[1].action, 'delay');
      expect(steps[1].value, '0.5');
    });

    test('handles multiple colons by using only first as separator', () {
      final steps = parsePipeToSteps('type_string:hello:world');
      expect(steps.length, 1);
      expect(steps[0].action, 'type_string');
      expect(steps[0].value, 'hello:world');
    });
  });
}
