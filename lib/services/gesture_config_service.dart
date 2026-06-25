import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/gesture_config_model.dart';
import 'api_service.dart';

class GestureConfigService extends ChangeNotifier {
  final ApiService _api;

  List<GestureConfig> _configs = [];
  bool _isLoading = false;
  String? _error;

  GestureConfigService(this._api);

  List<GestureConfig> get configs => _configs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<GestureConfig>> getAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/config/gesture-configs');
      final list = (data as List)
          .map((e) => GestureConfig.fromJson(e as Map<String, dynamic>))
          .toList();
      _configs = list;
      _isLoading = false;
      notifyListeners();
      return list;
    } on UnauthorizedException {
      _error = 'No autorizado';
      _isLoading = false;
      notifyListeners();
      return [];
    } on NetworkException {
      _error = 'No se pudo conectar al servidor';
      _isLoading = false;
      notifyListeners();
      return [];
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }

  Future<GestureConfig?> create(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post('/config/gesture-configs', body: data);
      final config = GestureConfig.fromJson(response as Map<String, dynamic>);
      _configs.add(config);
      _isLoading = false;
      notifyListeners();
      return config;
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

  Future<GestureConfig?> update(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await _api.put('/config/gesture-configs/$id', body: data);
      final config = GestureConfig.fromJson(response as Map<String, dynamic>);
      final index = _configs.indexWhere((c) => c.id == id);
      if (index != -1) {
        _configs[index] = config;
      }
      _isLoading = false;
      notifyListeners();
      return config;
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

  Future<bool> delete(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.delete('/config/gesture-configs/$id');
      _configs.removeWhere((c) => c.id == id);
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

  Future<String?> exportConfigs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/config/gesture-configs/export');
      _isLoading = false;
      notifyListeners();
      return jsonEncode(data);
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

  Future<bool> importConfigs(List<Map<String, dynamic>> configs) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post('/config/gesture-configs/import', body: {
        'configs': configs,
      });
      await getAll();
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

  Future<bool> refreshFromSupabase() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post('/refresh-configs');
      await getAll();
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

  Future<bool> resetToDefaults() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _api.post('/config/reset');
      await getAll();
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
