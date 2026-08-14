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

  group('GestureConfig', () {
    final fullJson = {
      'id': 'cfg-1',
      'movement': 'SWIPE_UP',
      'orientation': 'PALM_UP',
      'index_state': 1,
      'middle_state': 0,
      'action_key': 'volume_up',
      'action_value': '2',
      'context': 'AUDIO',
    };

    test('fromJson parses all fields', () {
      final config = GestureConfig.fromJson(fullJson);

      expect(config.id, 'cfg-1');
      expect(config.movement, 'SWIPE_UP');
      expect(config.orientation, 'PALM_UP');
      expect(config.indexState, 1);
      expect(config.middleState, 0);
      expect(config.actionKey, 'volume_up');
      expect(config.actionValue, '2');
      expect(config.context, 'AUDIO');
    });

    test('fromJson applies defaults for missing fields', () {
      final config = GestureConfig.fromJson({'id': 'cfg-2'});

      expect(config.movement, 'NONE');
      expect(config.orientation, 'ANY');
      expect(config.indexState, 0);
      expect(config.middleState, 0);
      expect(config.actionKey, '');
      expect(config.actionValue, isNull);
      expect(config.context, 'GLOBAL');
    });

    test('fromJson coerces numeric strings', () {
      final config = GestureConfig.fromJson({
        'id': 'cfg-3',
        'action_key': 123,
        'action_value': 42,
      });

      expect(config.actionKey, '123');
      expect(config.actionValue, '42');
    });

    test('toJson serializes all fields', () {
      final config = GestureConfig.fromJson(fullJson);
      final json = config.toJson();

      expect(json['id'], 'cfg-1');
      expect(json['movement'], 'SWIPE_UP');
      expect(json['action_key'], 'volume_up');
      expect(json['action_value'], '2');
      expect(json['context'], 'AUDIO');
    });

    test('toJson omits action_value when null', () {
      final config = GestureConfig.fromJson({'id': 'cfg-4'});
      final json = config.toJson();

      expect(json['action_value'], isNull);
    });

    test('fromJson/toJson roundtrip preserves data', () {
      final original = GestureConfig.fromJson(fullJson);
      final restored = GestureConfig.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.movement, original.movement);
      expect(restored.orientation, original.orientation);
      expect(restored.indexState, original.indexState);
      expect(restored.middleState, original.middleState);
      expect(restored.actionKey, original.actionKey);
      expect(restored.actionValue, original.actionValue);
      expect(restored.context, original.context);
    });
  });
}
