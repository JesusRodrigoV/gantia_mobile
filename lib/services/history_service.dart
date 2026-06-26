import 'package:flutter/foundation.dart';
import '../models/history_model.dart';
import 'api_service.dart';
import 'api_mixin.dart';

class HistoryService extends ChangeNotifier with ApiServiceMixin {
  final ApiService _api;

  List<HistoryReading> _readings = [];
  List<HistoryActionEntry> _actions = [];
  int _totalReadings = 0;
  int _totalActions = 0;

  HistoryService(this._api);

  List<HistoryReading> get readings => _readings;
  List<HistoryActionEntry> get actions => _actions;
  int get totalReadings => _totalReadings;
  int get totalActions => _totalActions;

  Future<List<HistoryReading>> getReadingsHistory({
    DateTime? since,
    DateTime? until,
    int? limit,
  }) async {
    return (await execute(() async {
      final params = <String, String>{};
      if (since != null) params['since'] = since.toIso8601String();
      if (until != null) params['until'] = until.toIso8601String();
      if (limit != null) params['limit'] = limit.toString();

      final queryString =
          params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final path = '/readings/history${queryString.isNotEmpty ? '?$queryString' : ''}';

      final data = await _api.get(path) as Map<String, dynamic>;
      final rawList = (data['data'] as List?) ?? [];
      _readings = rawList
          .map((e) => HistoryReading.fromJson(e as Map<String, dynamic>))
          .toList();
      _totalReadings = (data['total'] as num?)?.toInt() ?? _readings.length;
      return _readings;
    })) ?? [];
  }

  Future<List<HistoryActionEntry>> getActionsHistory({int? limit}) async {
    return (await execute(() async {
      final path =
          limit != null ? '/actions/history?limit=$limit' : '/actions/history';

      final data = await _api.get(path);
      final list = (data as List)
          .map((e) => HistoryActionEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      _actions = list;
      _totalActions = list.length;
      return list;
    })) ?? [];
  }
}
