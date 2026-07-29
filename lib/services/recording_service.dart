import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/gesture_config_model.dart';
import 'ws_client.dart';

/// Service that listens for `action_triggered` messages from the WebSocket
/// and captures them as [MacroStep] items while recording is active.
class RecordingService extends ChangeNotifier {
  final WsClient _client;
  StreamSubscription<Map<String, dynamic>>? _sub;
  bool _disposed = false;

  bool _recording = false;
  bool get recording => _recording;

  final List<MacroStep> _capturedSteps = [];
  List<MacroStep> get capturedSteps => List.unmodifiable(_capturedSteps);

  RecordingService(this._client) {
    _sub = _client.messages.listen(
      _handleRawMessage,
      onError: (Object e) => debugPrint('[RecordingService] stream error: $e'),
    );
  }

  void _handleRawMessage(Map<String, dynamic> data) {
    if (_disposed) return;
    if (data.containsKey('\$type')) return;
    if (!_recording) return;

    final String actionKey;
    final String? actionValue;

    if (data['action'] == 'action_triggered') {
      actionKey = data['action_key'] as String? ?? '';
      actionValue = data['action_value'] as String?;
    } else if (data['action'] != null) {
      actionKey = data['action'] as String? ?? '';
      actionValue = data['action_value'] as String?;
    } else {
      return;
    }

    _capturedSteps.add(MacroStep(
      action: actionKey,
      value: actionValue?.isNotEmpty == true ? actionValue : null,
    ));
    notifyListeners();
  }

  /// Starts recording: clears any previously captured steps and sets
  /// recording flag to `true`.
  void start() {
    _capturedSteps.clear();
    _recording = true;
    notifyListeners();
  }

  /// Stops recording and returns the list of captured steps so far.
  List<MacroStep> stop() {
    _recording = false;
    notifyListeners();
    return List.unmodifiable(_capturedSteps);
  }

  /// Clears captured steps without changing recording state.
  void clear() {
    _capturedSteps.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    super.dispose();
  }
}
