import 'package:flutter/foundation.dart';
import 'api_service.dart';

class MouseConfigService extends ChangeNotifier {
  final ApiService _api;

  Map<String, dynamic>? _config;
  bool _isLoading = false;
  String? _error;

  MouseConfigService(this._api);

  Map<String, dynamic>? get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<Map<String, dynamic>?> getConfig() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/mouse-config');
      _config = data as Map<String, dynamic>? ?? {};
      _isLoading = false;
      notifyListeners();
      return _config;
    } on UnauthorizedException {
      _error = 'No autorizado';
      _isLoading = false;
      notifyListeners();
      return null;
    } on NetworkException {
      _error = 'No se pudo conectar al servidor';
      _isLoading = false;
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateConfig({
    bool? invertRoll,
    bool? invertPitch,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (invertRoll != null) body['invert_roll'] = invertRoll;
      if (invertPitch != null) body['invert_pitch'] = invertPitch;

      final data = await _api.put('/mouse-config', body: body);
      _config = data as Map<String, dynamic>? ?? _config;
      _isLoading = false;
      notifyListeners();
      return true;
    } on UnauthorizedException {
      _error = 'No autorizado';
      _isLoading = false;
      notifyListeners();
      return false;
    } on NetworkException {
      _error = 'No se pudo conectar al servidor';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
