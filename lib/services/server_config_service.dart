import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ServerConfigService extends ChangeNotifier {
  static const _hostKey = 'backend_host';
  static const _portKey = 'backend_port';

  String _host;
  int _port;

  ServerConfigService(this._host, this._port);

  String get host => _host;
  int get port => _port;
  String get apiUrl => 'http://$_host:$_port';
  String get wsUrl => 'ws://$_host:$_port';

  Future<void> setHostPort(String host, int port) async {
    if (_host == host && _port == port) return;
    _host = host;
    _port = port;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_hostKey, host);
    await prefs.setInt(_portKey, port);
    notifyListeners();
  }

  static Future<ServerConfigService> load() async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString(_hostKey) ?? AppConfig.backendHost;
    final port = prefs.getInt(_portKey) ?? AppConfig.backendPort;
    return ServerConfigService(host, port);
  }
}
