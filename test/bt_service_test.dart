import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/bt_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.example.gantia_mobile/media_control');
  const eventChannel = EventChannel('com.example.gantia_mobile/bt_events');

  final eventSinks = <MockStreamHandlerEventSink>[];

  setUp(() {
    eventSinks.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(
        onListen: (args, events) {
          eventSinks.add(events);
        },
      ),
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  group('initial state', () {
    test('starts without a device and disconnected', () {
      final bt = BtService();
      expect(bt.deviceName, isNull);
      expect(bt.deviceAddress, isNull);
      expect(bt.isConnected, isFalse);
      expect(bt.canSendCommands, isFalse);
      expect(bt.connectedDevice, isNull);
      bt.dispose();
    });
  });

  group('events', () {
    test('updates device info from an event', () async {
      final bt = BtService();
      await Future<void>.delayed(Duration.zero);

      eventSinks.single.success({
        'name': 'Glove BT',
        'address': 'AA:BB:CC:DD:EE:FF',
        'connected': true,
      });
      await Future<void>.delayed(Duration.zero);

      expect(bt.deviceName, 'Glove BT');
      expect(bt.deviceAddress, 'AA:BB:CC:DD:EE:FF');
      expect(bt.isConnected, isTrue);
      expect(bt.canSendCommands, isTrue);
      expect(bt.connectedDevice, 'Glove BT');
      bt.dispose();
    });

    test('connectedDevice falls back to address when name is missing', () async {
      final bt = BtService();
      await Future<void>.delayed(Duration.zero);

      eventSinks.single.success({
        'address': 'AA:BB:CC:DD:EE:FF',
        'connected': true,
      });
      await Future<void>.delayed(Duration.zero);

      expect(bt.connectedDevice, 'AA:BB:CC:DD:EE:FF');
      bt.dispose();
    });

    test('ignores non-map events', () async {
      final bt = BtService();
      await Future<void>.delayed(Duration.zero);

      eventSinks.single.success('garbage');
      await Future<void>.delayed(Duration.zero);

      expect(bt.deviceName, isNull);
      bt.dispose();
    });
  });

  group('commands', () {
    test('sends each media command to the channel', () async {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return null;
      });

      final bt = BtService();
      await bt.playPause();
      await bt.next();
      await bt.prev();
      await bt.volumeUp();
      await bt.volumeDown();
      await bt.mute();

      expect(calls, ['playPause', 'next', 'prev', 'volumeUp', 'volumeDown', 'mute']);
      bt.dispose();
    });

    test('swallows channel errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'unavailable');
      });

      final bt = BtService();
      await bt.playPause();

      expect(bt.isConnected, isFalse);
      bt.dispose();
    });
  });

  group('refresh', () {
    test('updates state from getConnectedDevice', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'getConnectedDevice');
        return {
          'name': 'Glove BT',
          'address': 'AA:BB:CC:DD:EE:FF',
          'connected': true,
        };
      });

      final bt = BtService();
      await bt.refresh();

      expect(bt.deviceName, 'Glove BT');
      expect(bt.isConnected, isTrue);
      bt.dispose();
    });

    test('ignores a null result', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      final bt = BtService();
      await bt.refresh();

      expect(bt.deviceName, isNull);
      bt.dispose();
    });

    test('swallows errors', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(code: 'boom');
      });

      final bt = BtService();
      await bt.refresh();

      expect(bt.isConnected, isFalse);
      bt.dispose();
    });
  });
}
