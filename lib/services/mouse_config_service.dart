import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class MouseConfigService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  Map<String, dynamic>? _config;

  MouseConfigService(this._api);

  Map<String, dynamic>? get config => _config;

  Future<Map<String, dynamic>?> getConfig() async {
    return execute(() async {
      final data = await _api.get('/mouse-config');
      _config = data as Map<String, dynamic>? ?? {};
      return _config;
    });
  }

  Future<bool> updateConfig({
    bool? invertRoll,
    bool? invertPitch,
  }) async {
    return (await execute(() async {
      final body = <String, dynamic>{};
      if (invertRoll != null) body['invert_roll'] = invertRoll;
      if (invertPitch != null) body['invert_pitch'] = invertPitch;

      final data = await _api.put('/mouse-config', body: body);
      _config = data as Map<String, dynamic>? ?? _config;
      return true;
    })) ?? false;
  }
}
