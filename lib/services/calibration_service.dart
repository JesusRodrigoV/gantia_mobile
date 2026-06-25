import 'package:flutter/foundation.dart';
import '../models/calibration_model.dart';
import 'api_service.dart';

class CalibrationService extends ChangeNotifier {
  final ApiService _api;

  List<CalibrationEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  CalibrationService(this._api);

  List<CalibrationEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<List<CalibrationEntry>> getAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _api.get('/calibration');
      final list = (data as List)
          .map((e) => CalibrationEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _entries = list;
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

  Future<CalibrationEntry?> update(
    String sensorName, {
    double? minValue,
    double? maxValue,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final body = <String, dynamic>{};
      if (minValue != null) body['min_value'] = minValue;
      if (maxValue != null) body['max_value'] = maxValue;

      final response =
          await _api.put('/calibration/$sensorName', body: body);
      final entry =
          CalibrationEntry.fromJson(response as Map<String, dynamic>);

      final index = _entries.indexWhere((e) => e.sensorName == sensorName);
      if (index != -1) {
        _entries[index] = entry;
      } else {
        _entries.add(entry);
      }

      _isLoading = false;
      notifyListeners();
      return entry;
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
}
