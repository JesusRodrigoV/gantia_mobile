import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/models/gesture_config_model.dart';

void main() {
  group('MacroStep', () {
    test('fromJson parses action with value', () {
      final step = MacroStep.fromJson({
        'action': 'hotkey',
        'value': 'ctrl,c',
      });

      expect(step.action, 'hotkey');
      expect(step.value, 'ctrl,c');
    });

    test('fromJson parses action without value', () {
      final step = MacroStep.fromJson({
        'action': 'left_click',
      });

      expect(step.action, 'left_click');
      expect(step.value, isNull);
    });

    test('toJson serializes action with value', () {
      final step = MacroStep(action: 'delay', value: '0.5');
      final json = step.toJson();

      expect(json['action'], 'delay');
      expect(json['value'], '0.5');
    });

    test('toJson serializes action without value', () {
      final step = MacroStep(action: 'left_click');
      final json = step.toJson();

      expect(json['action'], 'left_click');
      expect(json.containsKey('value'), isFalse);
    });

    test('fromJson/toJson roundtrip preserves data', () {
      final original = MacroStep(action: 'type_string', value: 'hello');
      final json = original.toJson();
      final restored = MacroStep.fromJson(json);

      expect(restored.action, original.action);
      expect(restored.value, original.value);
    });

    test('constructor default value is null', () {
      final step = MacroStep(action: 'mute');
      expect(step.value, isNull);
    });
  });

  group('MacroData', () {
    final testSteps = [
      MacroStep(action: 'hotkey', value: 'win,d'),
      MacroStep(action: 'delay', value: '1'),
      MacroStep(action: 'left_click'),
    ];

    test('fromJson parses steps and repeat', () {
      final data = MacroData.fromJson({
        'steps': [
          {'action': 'hotkey', 'value': 'ctrl,c'},
          {'action': 'delay', 'value': '0.5'},
        ],
        'repeat': 3,
      });

      expect(data.steps.length, 2);
      expect(data.steps[0].action, 'hotkey');
      expect(data.steps[0].value, 'ctrl,c');
      expect(data.steps[1].action, 'delay');
      expect(data.steps[1].value, '0.5');
      expect(data.repeat, 3);
    });

    test('fromJson defaults repeat to 1', () {
      final data = MacroData.fromJson({
        'steps': [
          {'action': 'left_click'},
        ],
      });

      expect(data.steps.length, 1);
      expect(data.repeat, 1);
    });

    test('toJson serializes steps and repeat', () {
      final data = MacroData(steps: testSteps, repeat: 2);
      final json = data.toJson();

      expect(json['steps'], isA<List<dynamic>>());
      expect((json['steps'] as List<dynamic>).length, 3);
      expect(json['repeat'], 2);
      expect((json['steps'] as List)[0]['action'], 'hotkey');
    });

    test('toJson omits repeat when 1', () {
      final data = MacroData(steps: testSteps, repeat: 1);
      final json = data.toJson();

      expect(json['repeat'], isNull);
    });

    test('fromJson/toJson roundtrip preserves data', () {
      final original = MacroData(steps: testSteps, repeat: 4);
      final json = original.toJson();
      final restored = MacroData.fromJson(json);

      expect(restored.steps.length, original.steps.length);
      expect(restored.repeat, original.repeat);
      expect(restored.steps[0].action, original.steps[0].action);
      expect(restored.steps[0].value, original.steps[0].value);
    });

    test('empty steps list', () {
      final data = MacroData(steps: [], repeat: 1);
      expect(data.steps, isEmpty);
    });
  });
}
