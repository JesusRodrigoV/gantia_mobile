import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class TargetService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  String? _target;

  TargetService(this._api);

  String? get target => _target;

  Future<String?> getTarget() async {
    return execute(() async {
      final data = await _api.get('/active-target');
      _target = (data as Map<String, dynamic>)['target'] as String?;
      return _target;
    });
  }

  Future<bool> setTarget(String target) async {
    return (await execute(() async {
      final data =
          await _api.post('/active-target', body: {'target': target});
      _target = (data as Map<String, dynamic>)['target'] as String? ?? target;
      return true;
    })) ?? false;
  }
}
