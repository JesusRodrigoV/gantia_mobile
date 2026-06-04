import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BtService extends ChangeNotifier {
  static const _channel = MethodChannel('gantia_bt');

  bool _isConnected = false;
  String? _connectedDevice;
  List<String> _availableDevices = [];

  bool get isConnected => _isConnected;
  String? get connectedDevice => _connectedDevice;
  List<String> get availableDevices => List.unmodifiable(_availableDevices);

  Future<void> scanDevices() async {
    try {
      final result = await _channel.invokeMethod('scanDevices');
      if (result is List) {
        _availableDevices = result.cast<String>();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[BtService] scan error: $e');
    }
  }

  Future<bool> connect(String deviceId) async {
    try {
      final result = await _channel.invokeMethod('connect', {'deviceId': deviceId});
      if (result == true) {
        _isConnected = true;
        _connectedDevice = deviceId;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('[BtService] connect error: $e');
    }
    return false;
  }

  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
    } catch (e) {
      debugPrint('[BtService] disconnect error: $e');
    }
  }

  Future<void> playPause() async {
    try {
      await _channel.invokeMethod('playPause');
    } catch (e) {
      debugPrint('[BtService] playPause error: $e');
    }
  }

  Future<void> next() async {
    try {
      await _channel.invokeMethod('next');
    } catch (e) {
      debugPrint('[BtService] next error: $e');
    }
  }

  Future<void> prev() async {
    try {
      await _channel.invokeMethod('prev');
    } catch (e) {
      debugPrint('[BtService] prev error: $e');
    }
  }

  Future<void> volumeUp() async {
    try {
      await _channel.invokeMethod('volumeUp');
    } catch (e) {
      debugPrint('[BtService] volumeUp error: $e');
    }
  }

  Future<void> volumeDown() async {
    try {
      await _channel.invokeMethod('volumeDown');
    } catch (e) {
      debugPrint('[BtService] volumeDown error: $e');
    }
  }

  Future<void> mute() async {
    try {
      await _channel.invokeMethod('mute');
    } catch (e) {
      debugPrint('[BtService] mute error: $e');
    }
  }
}
