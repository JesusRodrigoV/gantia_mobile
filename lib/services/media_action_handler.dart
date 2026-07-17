import 'dart:async';
import 'package:flutter/foundation.dart';
import 'bt_service.dart';
import 'ws_client.dart';

class MediaActionHandler {
  final WsClient _client;
  final BtService _btService;
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _disposed = false;

  MediaActionHandler(this._client, this._btService) {
    _sub = _client.messages.listen(
      _handleMessage,
      onError: (Object e) => debugPrint('[MediaActionHandler] stream error: $e'),
    );
  }

  void _handleMessage(Map<String, dynamic> data) {
    if (_disposed) return;
    if (data.containsKey('\$type')) return;

    if (data['action'] == 'action_triggered') {
      final action = data['action_key'] as String? ?? '';
      _routeAction(action);
    }
  }

  void _routeAction(String action) {
    switch (action) {
      case 'play_pause':
        _btService.playPause();
        break;
      case 'next':
      case 'next_track':
        _btService.next();
        break;
      case 'prev':
      case 'prev_track':
        _btService.prev();
        break;
      case 'volume_up':
        _btService.volumeUp();
        break;
      case 'volume_down':
        _btService.volumeDown();
        break;
      case 'mute':
      case 'hard_mute':
        _btService.mute();
        break;
    }
  }

  void dispose() {
    _disposed = true;
    _sub?.cancel();
  }
}
