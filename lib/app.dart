import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'providers.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/smart_home_screen.dart';
import 'screens/config_screen.dart';
import 'screens/history_screen.dart';
import 'widgets/gantia_bottom_nav.dart';
import 'services/media_action_handler.dart';

class GantiaApp extends ConsumerWidget {
  const GantiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeServiceProvider.select((s) => s.isDarkMode));

    return MaterialApp(
      title: 'Gantia Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends ConsumerStatefulWidget {
  const _AuthGate();

  @override
  ConsumerState<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<_AuthGate> {
  @override
  void initState() {
    super.initState();
    final auth = ref.read(authServiceProvider);
    auth.addListener(_onAuthChanged);
    if (auth.isAuthenticated) {
      ref.read(wsClientProvider).connect();
    }
  }

  @override
  void dispose() {
    ref.read(authServiceProvider).removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    final auth = ref.read(authServiceProvider);
    if (auth.isAuthenticated) {
      ref.read(wsClientProvider).connect();
    } else {
      ref.read(wsClientProvider).disconnect();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authServiceProvider);
    final showRegister = ref.watch(showRegisterProvider);

    if (!auth.isAuthenticated) {
      if (showRegister) {
        return RegisterScreen(
          authService: auth,
          onRegisterSuccess: () => ref.read(showRegisterProvider.notifier).state = false,
          onBackToLogin: () => ref.read(showRegisterProvider.notifier).state = false,
        );
      }
      return LoginScreen(
        authService: auth,
        onLoginSuccess: () {},
        onRegisterTap: () => ref.read(showRegisterProvider.notifier).state = true,
      );
    }

    return const _MainShell();
  }
}

class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell> {
  bool _shellDisposed = false;
  MediaActionHandler? _mediaActionHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_shellDisposed) return;
      _initServices();
    });
  }

  void _initServices() {
    final gloveState = ref.read(gloveStateProvider);
    final actionLog = ref.read(actionLogProvider);

    final notificationService = ref.read(notificationServiceProvider);
    notificationService.listenTo(gloveState, actionLog);

    final widgetService = ref.read(widgetServiceProvider);
    widgetService.listenTo(gloveState, actionLog);

    final btService = ref.read(btServiceProvider);
    btService.refresh();

    final client = ref.read(wsClientProvider);
    _mediaActionHandler = MediaActionHandler(client, btService);
  }

  @override
  void dispose() {
    _shellDisposed = true;
    _mediaActionHandler?.dispose();
    try { ref.read(notificationServiceProvider).dispose(); } catch (_) {}
    try { ref.read(widgetServiceProvider).dispose(); } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final pages = <Widget>[
      const RepaintBoundary(child: HomeScreen()),
      const RepaintBoundary(child: ConfigScreen()),
      const RepaintBoundary(child: HistoryScreen()),
      const RepaintBoundary(child: SmartHomeScreen()),
      const RepaintBoundary(child: SettingsScreen()),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: const RepaintBoundary(child: GantiaBottomNav()),
    );
  }
}
