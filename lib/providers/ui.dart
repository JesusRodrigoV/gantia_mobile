import 'package:flutter_riverpod/flutter_riverpod.dart';

final showRegisterProvider = StateProvider.autoDispose<bool>((ref) => false);

final bottomNavIndexProvider = StateProvider.autoDispose<int>((ref) => 0);
