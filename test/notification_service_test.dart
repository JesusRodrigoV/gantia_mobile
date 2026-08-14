import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/action_log.dart';
import 'package:gantia_mobile/services/glove_state.dart';
import 'package:gantia_mobile/services/notification_service.dart';

import 'helpers/fakes.dart';

class _TrackingGloveState extends GloveState {
  _TrackingGloveState(super.client);
  int get listenerCount => hasListeners ? 1 : 0;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeWsClient fakeClient;
  late GloveState gloveState;
  late ActionLog actionLog;
  late NotificationService service;

  setUp(() {
    fakeClient = FakeWsClient();
    gloveState = GloveState(fakeClient);
    actionLog = ActionLog(fakeClient);
    service = NotificationService();
  });

  tearDown(() {
    service.dispose();
    actionLog.dispose();
    gloveState.dispose();
    fakeClient.dispose();
  });

  group('init', () {
    test('reports not operational when plugin init fails quietly', () async {
      expect(service.isOperational, isFalse);

      await service.init();

      expect(service.initError, isNotNull);
      expect(service.isOperational, isFalse);
    });
  });

  group('listening', () {
    test('stopListening removes listeners without crashing', () {
      final tracked = _TrackingGloveState(fakeClient);
      service.listenTo(tracked, actionLog, notifyActions: true);
      expect(tracked.listenerCount, 1);

      service.stopListening();

      expect(tracked.listenerCount, 0);
      tracked.dispose();
    });

    test('connection changes are handled without throwing', () async {
      service.listenTo(gloveState, actionLog);

      fakeClient.emit({'type': 'connected'});
      await Future<void>.delayed(Duration.zero);
      fakeClient.emit({'type': 'disconnected'});
      await Future<void>.delayed(Duration.zero);

      expect(gloveState.connectionStatus, ConnectionStatus.disconnected);
    });

    test('gestures and actions notify through the plugin safely', () async {
      service.listenTo(gloveState, actionLog, notifyActions: true);

      fakeClient.emit({'type': 'gesture_detected', 'gesture': 'pinch', 'action': 'mute'});
      fakeClient.emit({'action': 'action_triggered', 'action_key': 'next', 'action_value': 1});
      await Future<void>.delayed(Duration.zero);

      expect(gloveState.gestureDetected?.gesture, 'pinch');
      expect(actionLog.recentActions, isNotEmpty);
    });
  });

  group('showNotificationSafe', () {
    test('is safe to call with an unknown channel id', () {
      expect(
        () => service.showNotificationSafe(999, 'missing_channel', 't', 'b'),
        returnsNormally,
      );
    });
  });
}