import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/gesture_config_model.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class GestureConfigService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  List<GestureConfig> _configs = [];

  GestureConfigService(this._api);

  List<GestureConfig> get configs => _configs;

  Future<List<GestureConfig>> getAll() async {
    return (await execute(() async {
      final data = await _api.get('/config/gesture-configs');
      final list = (data as List)
          .map((e) => GestureConfig.fromJson(e as Map<String, dynamic>))
          .toList();
      _configs = list;
      return list;
    })) ?? [];
  }

  Future<GestureConfig?> create(Map<String, dynamic> data) async {
    return execute(() async {
      final response = await _api.post('/config/gesture-configs', body: data);
      final config = GestureConfig.fromJson(response as Map<String, dynamic>);
      _configs.add(config);
      return config;
    });
  }

  Future<GestureConfig?> update(String id, Map<String, dynamic> data) async {
    return execute(() async {
      final response =
          await _api.put('/config/gesture-configs/$id', body: data);
      final config = GestureConfig.fromJson(response as Map<String, dynamic>);
      final index = _configs.indexWhere((c) => c.id == id);
      if (index != -1) {
        _configs[index] = config;
      }
      return config;
    });
  }

  Future<bool> delete(String id) async {
    return (await execute(() async {
      await _api.delete('/config/gesture-configs/$id');
      _configs.removeWhere((c) => c.id == id);
      return true;
    })) ?? false;
  }

  Future<String?> exportConfigs() async {
    return execute(() async {
      final data = await _api.get('/config/gesture-configs/export');
      return jsonEncode(data);
    });
  }

  Future<bool> importConfigs(List<Map<String, dynamic>> configs) async {
    return (await execute(() async {
      await _api.post('/config/gesture-configs/import', body: {
        'configs': configs,
      });
      await getAll();
      return true;
    })) ?? false;
  }

  Future<bool> refreshFromSupabase() async {
    return (await execute(() async {
      await _api.post('/refresh-configs');
      await getAll();
      return true;
    })) ?? false;
  }

  Future<bool> resetToDefaults() async {
    return (await execute(() async {
      await _api.post('/config/reset');
      await getAll();
      return true;
    })) ?? false;
  }
}
