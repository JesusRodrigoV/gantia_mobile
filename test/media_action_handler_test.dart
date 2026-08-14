import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/media_action_handler.dart';

import 'helpers/fakes.dart';

void main() {
  late FakeWsClient ws;
  late FakeBtService bt;
  late MediaActionHandler handler;

  setUp(() {
    ws = FakeWsClient();
    bt = FakeBtService();
    handler = MediaActionHandler(ws, bt);
  });

  tearDown(() {
    handler.dispose();
    ws.dispose();
  });

  void emitActionTriggered({
    required String actionKey,
    String? target,
  }) {
    ws.emit({
      'action': 'action_triggered',
      'target': target,
      'action_key': actionKey,
      'action_value': '',
    });
  }

  group('target routing', () {
    test('routes actions with target mobile', () async {
      emitActionTriggered(actionKey: 'play_pause', target: 'mobile');
      await pumpEventQueue();
      expect(bt.commands, ['playPause']);
    });

    test('routes actions when target is null (assumes mobile)', () async {
      emitActionTriggered(actionKey: 'next');
      await pumpEventQueue();
      expect(bt.commands, ['next']);
    });

    test('ignores actions addressed to other targets', () async {
      emitActionTriggered(actionKey: 'play_pause', target: 'pc');
      await pumpEventQueue();
      expect(bt.commands, isEmpty);
    });
  });

  group('action mapping', () {
    test('maps next and next_track to BtService.next', () async {
      emitActionTriggered(actionKey: 'next');
      await pumpEventQueue();
      emitActionTriggered(actionKey: 'next_track');
      await pumpEventQueue();
      expect(bt.commands, ['next', 'next']);
    });

    test('maps prev and prev_track to BtService.prev', () async {
      emitActionTriggered(actionKey: 'prev');
      await pumpEventQueue();
      emitActionTriggered(actionKey: 'prev_track');
      await pumpEventQueue();
      expect(bt.commands, ['prev', 'prev']);
    });

    test('maps mute and hard_mute to BtService.mute', () async {
      emitActionTriggered(actionKey: 'mute');
      await pumpEventQueue();
      emitActionTriggered(actionKey: 'hard_mute');
      await pumpEventQueue();
      expect(bt.commands, ['mute', 'mute']);
    });

    test('maps volume_up and volume_down', () async {
      emitActionTriggered(actionKey: 'volume_up');
      await pumpEventQueue();
      emitActionTriggered(actionKey: 'volume_down');
      await pumpEventQueue();
      expect(bt.commands, ['volumeUp', 'volumeDown']);
    });
  });

  group('filtering', () {
    test('ignores lifecycle messages', () async {
      ws.emit({'\$type': 'connected'});
      ws.emit({'\$type': 'reconnecting', 'attempt': 1});
      await pumpEventQueue();
      expect(bt.commands, isEmpty);
    });

    test('ignores telemetry messages', () async {
      ws.emit({'accel_x': 1.0, 'accel_y': 1.0, 'accel_z': 1.0});
      await pumpEventQueue();
      expect(bt.commands, isEmpty);
    });

    test('ignores non action_triggered action messages', () async {
      ws.emit({'action': 'set_mode', 'value': 'AUDIO'});
      await pumpEventQueue();
      expect(bt.commands, isEmpty);
    });

    test('ignores unknown action keys without crashing', () async {
      emitActionTriggered(actionKey: 'some_unknown_action');
      await pumpEventQueue();
      expect(bt.commands, isEmpty);
    });
  });

  group('lifecycle', () {
    test('dispose stops receiving messages', () async {
      handler.dispose();
      emitActionTriggered(actionKey: 'play_pause');
      await pumpEventQueue();
      expect(bt.commands, isEmpty);
    });
  });
}