import 'package:flutter/foundation.dart';
import '../models/sensitivity_model.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class SensitivityService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  SensitivitySettings? _settings;

  SensitivityService(this._api);

  SensitivitySettings? get settings => _settings;

  Future<SensitivitySettings?> getSettings() async {
    return execute(() async {
      final data = await _api.get('/sensitivity');
      _settings = SensitivitySettings.fromJson(data as Map<String, dynamic>);
      return _settings;
    });
  }

  Future<bool> updateSettings(Map<String, dynamic> partial) async {
    return (await execute(() async {
      final data = await _api.put('/sensitivity', body: partial);
      _settings = SensitivitySettings.fromJson(data as Map<String, dynamic>);
      return true;
    })) ?? false;
  }
}
