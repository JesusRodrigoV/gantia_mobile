import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/action_message.dart';
import 'ws_client.dart';

class ActionLog extends ChangeNotifier {
  final WsClient _client;
  StreamSubscription<Map<String, dynamic>>? _sub;

  ActionEvent? _actionEvent;
  ActionEvent? get actionEvent => _actionEvent;
  final StreamController<ActionEvent?> _actionCtrl =
      StreamController<ActionEvent?>.broadcast();
  Stream<ActionEvent?> get actionEventStream => _actionCtrl.stream;

  List<ActionEvent> _recentActions = [];
  List<ActionEvent> get recentActions => List.unmodifiable(_recentActions);

  static const int _maxRecentActions = 30;

  ActionLog(this._client) {
    _sub = _client.messages.listen(_handleRawMessage);
  }

  void _handleRawMessage(Map<String, dynamic> data) {
    if (data.containsKey('\$type')) return;

    if (isActionMessage(data)) {
      final evt = ActionEvent.fromJson(data);
      _actionEvent = evt;
      _actionCtrl.add(evt);
      _recentActions = [evt, ..._recentActions].take(_maxRecentActions).toList();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _actionCtrl.close();
    super.dispose();
  }
}
