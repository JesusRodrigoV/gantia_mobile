import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'providers.dart';
import 'services/auth_service.dart';
import 'services/ws_service.dart';
import 'services/bt_service.dart';
import 'services/theme_service.dart';
import 'services/smart_home_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/smart_home_screen.dart';

class GantiaApp extends ConsumerWidget {
  const GantiaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeService = ref.watch(themeServiceProvider);

    return MaterialApp(
      title: 'Gantia Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  void _checkAuth() {
    final auth = ref.read(authServiceProvider);
    if (auth.isAuthenticated) {
      ref.read(wsServiceProvider).connect();
    }
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) return const SizedBox.shrink();

    final auth = ref.watch(authServiceProvider);

    if (!auth.isAuthenticated) {
      return LoginScreen(
        authService: auth,
        onLoginSuccess: () {
          ref.read(wsServiceProvider).connect();
          setState(() {});
        },
      );
    }

    final themeService = ref.watch(themeServiceProvider);
    final ws = ref.watch(wsServiceProvider);
    final bt = ref.watch(btServiceProvider);
    final smartHome = ref.watch(smartHomeServiceProvider);

    return _MainShell(
      wsService: ws,
      btService: bt,
      themeService: themeService,
      smartHomeService: smartHome,
      authService: auth,
    );
  }
}

class _MainShell extends StatefulWidget {
  final WsService wsService;
  final BtService btService;
  final ThemeService themeService;
  final SmartHomeService smartHomeService;
  final AuthService authService;

  const _MainShell({
    required this.wsService,
    required this.btService,
    required this.themeService,
    required this.smartHomeService,
    required this.authService,
  });

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  void _logout() {
    widget.authService.logout();
    widget.wsService.disconnect();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        wsService: widget.wsService,
        btService: widget.btService,
        isDarkMode: widget.themeService.isDarkMode,
        onThemeToggle: () => widget.themeService.toggleTheme(),
        onLogout: _logout,
      ),
      SettingsScreen(
        authService: widget.authService,
        themeService: widget.themeService,
        btService: widget.btService,
        wsService: widget.wsService,
      ),
      SmartHomeScreen(smartHomeService: widget.smartHomeService),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.surfaceDark900 : AppColors.surfaceLight900,
            blurRadius: 16,
            offset: const Offset(8, 8),
          ),
          BoxShadow(
            color: isDark ? AppColors.surfaceDark0 : AppColors.surfaceLight0,
            blurRadius: 16,
            offset: const Offset(-8, -8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary500,
          unselectedItemColor: isDark ? AppColors.surfaceDark500 : AppColors.surfaceLight500,
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), activeIcon: Icon(Icons.dashboard), label: 'INICIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'AJUSTES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline), activeIcon: Icon(Icons.lightbulb), label: 'SMART HOME',
            ),
          ],
        ),
      ),
    );
  }
}
