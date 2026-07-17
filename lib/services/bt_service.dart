import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BtService extends ChangeNotifier {
  static const _channel = MethodChannel('com.example.gantia_mobile/media_control');
  static const _eventChannel = EventChannel('com.example.gantia_mobile/bt_events');

  String? _deviceName;
  String? _deviceAddress;
  bool _isConnected = false;
  StreamSubscription<dynamic>? _eventSub;

  String? get deviceName => _deviceName;
  String? get deviceAddress => _deviceAddress;
  bool get isConnected => _isConnected;
  bool get canSendCommands => _isConnected;

  /// Mantiene compatibilidad con la API anterior
  String? get connectedDevice => _deviceName ?? _deviceAddress;

  BtService() {
    _eventSub = _eventChannel.receiveBroadcastStream().listen(_onEvent);
  }

  void _onEvent(dynamic event) {
    if (event is Map) {
      _deviceName = event['name'] as String?;
      _deviceAddress = event['address'] as String?;
      _isConnected = event['connected'] as bool? ?? false;
      notifyListeners();
    }
  }

  Future<void> playPause() => _invoke('playPause');
  Future<void> next() => _invoke('next');
  Future<void> prev() => _invoke('prev');
  Future<void> volumeUp() => _invoke('volumeUp');
  Future<void> volumeDown() => _invoke('volumeDown');
  Future<void> mute() => _invoke('mute');

  Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<dynamic>(method);
    } catch (e) {
      debugPrint('[BtService] $method error: $e');
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('getConnectedDevice');
      if (result != null) {
        _deviceName = result['name'] as String?;
        _deviceAddress = result['address'] as String?;
        _isConnected = result['connected'] as bool? ?? false;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[BtService] refresh error: $e');
    }
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}
