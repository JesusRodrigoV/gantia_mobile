import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/glove_state.dart';
import '../services/action_log.dart';
import 'auth.dart';

final gloveStateProvider = ChangeNotifierProvider<GloveState>((ref) {
  final client = ref.watch(wsClientProvider);
  return GloveState(client);
});

final actionLogProvider = ChangeNotifierProvider<ActionLog>((ref) {
  final client = ref.watch(wsClientProvider);
  return ActionLog(client);
});
