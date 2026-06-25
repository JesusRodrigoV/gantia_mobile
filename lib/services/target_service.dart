import 'package:flutter/foundation.dart';
import 'api_service.dart';

class TargetService extends ChangeNotifier {
  final ApiService _api;

  String? _target;
  bool _isLoading = false;
  String? _error;

  TargetService(this._api);

  String? get target => _target;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<String?> getTarget() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/active-target');
      _target = (data as Map<String, dynamic>)['target'] as String?;
      _isLoading = false;
      notifyListeners();
      return _target;
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

  Future<bool> setTarget(String target) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await _api.post('/active-target', body: {'target': target});
      _target = (data as Map<String, dynamic>)['target'] as String? ?? target;
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
