import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BtService extends ChangeNotifier {
  static const _channel = MethodChannel('gantia_bt');

  bool _isConnected = false;
  String? _connectedDevice;
  List<String> _availableDevices = [];
  String? _error;
  bool _isScanning = false;

  bool get isConnected => _isConnected;
  String? get connectedDevice => _connectedDevice;
  List<String> get availableDevices => List.unmodifiable(_availableDevices);
  String? get error => _error;
  bool get isScanning => _isScanning;

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<void> scanDevices() async {
    _isScanning = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _channel.invokeMethod('scanDevices');
      if (result is List) {
        _availableDevices = result.cast<String>();
      }
    } catch (e) {
      _error = 'Error al escanear dispositivos BT';
      debugPrint('[BtService] scan error: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> connect(String deviceId) async {
    _error = null;
    notifyListeners();

    try {
      final result = await _channel.invokeMethod('connect', {'deviceId': deviceId});
      if (result == true) {
        _isConnected = true;
        _connectedDevice = deviceId;
        notifyListeners();
        return true;
      }
      _error = 'No se pudo conectar a $deviceId';
      notifyListeners();
    } catch (e) {
      _error = 'Error al conectar: ${e.toString()}';
      debugPrint('[BtService] connect error: $e');
      notifyListeners();
    }
    return false;
  }

  Future<void> disconnect() async {
    _error = null;
    notifyListeners();

    try {
      await _channel.invokeMethod('disconnect');
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error al desconectar';
      debugPrint('[BtService] disconnect error: $e');
      notifyListeners();
    }
  }

  Future<void> _sendCommand(String method, String label) async {
    try {
      await _channel.invokeMethod(method);
    } catch (e) {
      _error = 'Error al ejecutar $label';
      debugPrint('[BtService] $method error: $e');
      notifyListeners();
    }
  }

  Future<void> playPause() => _sendCommand('playPause', 'play/pausa');
  Future<void> next() => _sendCommand('next', 'siguiente');
  Future<void> prev() => _sendCommand('prev', 'anterior');
  Future<void> volumeUp() => _sendCommand('volumeUp', 'subir volumen');
  Future<void> volumeDown() => _sendCommand('volumeDown', 'bajar volumen');
  Future<void> mute() => _sendCommand('mute', 'silenciar');
}
