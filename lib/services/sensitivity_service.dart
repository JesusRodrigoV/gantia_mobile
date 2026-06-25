import 'package:flutter/foundation.dart';
import '../models/sensitivity_model.dart';
import 'api_service.dart';

class SensitivityService extends ChangeNotifier {
  final ApiService _api;

  SensitivitySettings? _settings;
  bool _isLoading = false;
  String? _error;

  SensitivityService(this._api);

  SensitivitySettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<SensitivitySettings?> getSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/sensitivity');
      _settings = SensitivitySettings.fromJson(data as Map<String, dynamic>);
      _isLoading = false;
      notifyListeners();
      return _settings;
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

  Future<bool> updateSettings(Map<String, dynamic> partial) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.put('/sensitivity', body: partial);
      _settings = SensitivitySettings.fromJson(data as Map<String, dynamic>);
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
