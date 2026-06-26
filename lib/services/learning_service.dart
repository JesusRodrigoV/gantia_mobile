import 'package:flutter/foundation.dart';
import '../models/learning_model.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class LearningService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  LearnSession? _session;
  LearnAnalysis? _analysis;
  bool _isSessionActive = false;

  LearningService(this._api);

  LearnSession? get session => _session;
  LearnAnalysis? get analysis => _analysis;
  bool get isSessionActive => _isSessionActive;

  Future<LearnSession?> start() async {
    return execute(() async {
      final data = await _api.post('/learning/start');
      _session = LearnSession.fromJson(data as Map<String, dynamic>);
      _isSessionActive = true;
      _analysis = null;
      return _session;
    });
  }

  Future<LearnAnalysis?> sample() async {
    return execute(() async {
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
      return analysis;
    });
  }

  Future<LearnSession?> save(String actionKey) async {
    return execute(() async {
      final data =
          await _api.post('/learning/save', body: {'action_key': actionKey});
      _session = LearnSession.fromJson(data as Map<String, dynamic>);
      _isSessionActive = false;
      return _session;
    });
  }

  Future<bool> cancel() async {
    return (await execute(() async {
      await _api.post('/learning/cancel');
      _session = null;
      _analysis = null;
      _isSessionActive = false;
      return true;
    })) ?? false;
  }
}
