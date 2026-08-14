import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/action_log.dart';
import 'package:gantia_mobile/services/glove_state.dart';
import 'package:gantia_mobile/services/widget_service.dart';

import 'helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('home_widget'),
      (call) async => null,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('home_widget'), null);
  });

  group('statusLabelFor', () {
    test('connected with data flowing is Activo', () {
      expect(
        WidgetService.statusLabelFor(
          ConnectionStatus.connected,
          dataFlowing: true,
          waitingForDevice: false,
        ),
        'Activo',
      );
    });

    test('connected while waiting for the device', () {
      expect(
        WidgetService.statusLabelFor(
          ConnectionStatus.connected,
          dataFlowing: false,
          waitingForDevice: true,
        ),
        'Esperando guante',
      );
    });

    test('connected without data or device', () {
      expect(
        WidgetService.statusLabelFor(
          ConnectionStatus.connected,
          dataFlowing: false,
          waitingForDevice: false,
        ),
        'Conectado',
      );
    });

    test('connecting, reconnecting, disconnected and error labels', () {
      expect(
        WidgetService.statusLabelFor(
          ConnectionStatus.connecting,
          dataFlowing: false,
          waitingForDevice: false,
        ),
        'Conectando...',
      );
      expect(
        WidgetService.statusLabelFor(
          ConnectionStatus.reconnecting,
          dataFlowing: false,
          waitingForDevice: false,
        ),
        'Reconectando...',
      );
      expect(
        WidgetService.statusLabelFor(
          ConnectionStatus.disconnected,
          dataFlowing: false,
          waitingForDevice: false,
        ),
        'Sin conexión',
      );
      expect(
        WidgetService.statusLabelFor(
          ConnectionStatus.error,
          dataFlowing: false,
          waitingForDevice: false,
        ),
        'Error',
      );
    });
  });

  group('listenTo', () {
    test('wires to glove state and action log without throwing', () async {
      final fakeClient = FakeWsClient();
      final gloveState = GloveState(fakeClient);
      final actionLog = ActionLog(fakeClient);
      final service = WidgetService();

      service.listenTo(gloveState, actionLog);
      fakeClient.emit({'type': 'connected'});
      await Future<void>.delayed(Duration.zero);
      fakeClient.emit({'action': 'next'});
      await Future<void>.delayed(Duration.zero);

      service.stopListening();
      gloveState.dispose();
      actionLog.dispose();
      fakeClient.dispose();
    });
  });
}