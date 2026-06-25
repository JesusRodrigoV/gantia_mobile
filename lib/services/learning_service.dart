import 'package:flutter/foundation.dart';
import '../models/learning_model.dart';
import 'api_service.dart';

class LearningService extends ChangeNotifier {
  final ApiService _api;

  LearnSession? _session;
  LearnAnalysis? _analysis;
  bool _isLoading = false;
  bool _isSessionActive = false;
  String? _error;

  LearningService(this._api);

  LearnSession? get session => _session;
  LearnAnalysis? get analysis => _analysis;
  bool get isLoading => _isLoading;
  bool get isSessionActive => _isSessionActive;
  String? get error => _error;

  Future<LearnSession?> start() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.post('/learning/start');
      _session = LearnSession.fromJson(data as Map<String, dynamic>);
      _isSessionActive = true;
      _analysis = null;
      _isLoading = false;
      notifyListeners();
      return _session;
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

  Future<LearnAnalysis?> sample() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.post('/learning/sample');
      final analysis =
          LearnAnalysis.fromJson(data as Map<String, dynamic>);
      _analysis = analysis;
      if (_session != null) {
        _session = LearnSession(
          id: _session!.id,
          samplesCollected: _session!.samplesCollected + 1,
        );
      }
      _isLoading = false;
      notifyListeners();
      return analysis;
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

  Future<LearnSession?> save(String actionKey) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data =
          await _api.post('/learning/save', body: {'action_key': actionKey});
      _session = LearnSession.fromJson(data as Map<String, dynamic>);
      _isSessionActive = false;
      _isLoading = false;
      notifyListeners();
      return _session;
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

  Future<bool> cancel() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post('/learning/cancel');
      _session = null;
      _analysis = null;
      _isSessionActive = false;
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
