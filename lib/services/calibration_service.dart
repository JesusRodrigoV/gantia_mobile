import 'package:flutter/foundation.dart';
import '../models/calibration_model.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class CalibrationService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  List<CalibrationEntry> _entries = [];

  CalibrationService(this._api);

  List<CalibrationEntry> get entries => _entries;

  Future<List<CalibrationEntry>> getAll() async {
    return (await execute(() async {
      final data = await _api.get('/config/calibration');
      final list = (data as List)
          .map((e) => CalibrationEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _entries = list;
      return list;
    })) ?? [];
  }

  Future<CalibrationEntry?> update(
    String sensorName, {
    double? minValue,
    double? maxValue,
  }) async {
    return execute(() async {
      final body = <String, dynamic>{};
      if (minValue != null) body['min_value'] = minValue;
      if (maxValue != null) body['max_value'] = maxValue;

      final response =
          await _api.put('/config/calibration/$sensorName', body: body);
      final entry =
          CalibrationEntry.fromJson(response as Map<String, dynamic>);

      final index = _entries.indexWhere((e) => e.sensorName == sensorName);
      if (index != -1) {
        _entries[index] = entry;
      } else {
        _entries.add(entry);
      }
      return entry;
    });
  }
}
