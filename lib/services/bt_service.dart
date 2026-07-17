import 'package:flutter/foundation.dart';
import 'package:flutter_classic_bluetooth/flutter_classic_bluetooth.dart';

class BtService extends ChangeNotifier {
  final FlutterClassicBluetooth _bluetooth = FlutterClassicBluetooth();
  BtcConnection? _connection;

  bool _isConnected = false;
  String? _connectedDevice;
  List<BtcDevice> _availableDevices = [];
  String? _error;
  bool _isScanning = false;

  bool get isConnected => _isConnected;
  String? get connectedDevice => _connectedDevice;
  List<BtcDevice> get availableDevices => List.unmodifiable(_availableDevices);
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
      final devices = await _bluetooth.scan(timeout: const Duration(seconds: 8));
      _availableDevices = devices;
    } catch (e) {
      _error = 'Error al escanear dispositivos BT';
      debugPrint('[BtService] scan error: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> connect(String deviceAddress) async {
    _error = null;
    notifyListeners();

    try {
      final connection = await _bluetooth.connect(address: deviceAddress);
      _connection = connection;
      _isConnected = true;
      _connectedDevice = deviceAddress;
      notifyListeners();

      connection.stateStream.listen((state) {
        if (state == BtcConnectionState.disconnected) {
          _isConnected = false;
          _connectedDevice = null;
          _connection = null;
          notifyListeners();
        }
      });

      return true;
    } catch (e) {
      _error = 'No se pudo conectar al dispositivo';
      debugPrint('[BtService] connect error: $e');
      notifyListeners();
    }
    return false;
  }

  Future<void> disconnect() async {
    try {
      await _connection?.finish();
      _connection?.dispose();
    } catch (e) {
      debugPrint('[BtService] disconnect error: $e');
    } finally {
      _connection = null;
      _isConnected = false;
      _connectedDevice = null;
      notifyListeners();
    }
  }

  Future<void> playPause() => _sendCommand('playPause');
  Future<void> next() => _sendCommand('next');
  Future<void> prev() => _sendCommand('prev');
  Future<void> volumeUp() => _sendCommand('volumeUp');
  Future<void> volumeDown() => _sendCommand('volumeDown');
  Future<void> mute() => _sendCommand('mute');

  Future<void> _sendCommand(String command) async {
    if (!_isConnected || _connection == null) {
      _error = 'No hay dispositivo conectado';
      notifyListeners();
      return;
    }
    try {
      await _connection!.output.writeLine(command);
    } catch (e) {
      _error = 'Error al ejecutar comando';
      debugPrint('[BtService] $command error: $e');
      notifyListeners();
    }
  }
}
