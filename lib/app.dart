import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/context_extensions.dart';
import 'providers.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/smart_home_screen.dart';
import 'screens/config_screen.dart';
import 'screens/history_screen.dart';

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
  @override
  void initState() {
    super.initState();
    final auth = ref.read(authServiceProvider);
    if (auth.isAuthenticated) {
      ref.read(wsClientProvider).connect();
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
          onRegisterSuccess: () {
            ref.read(showRegisterProvider.notifier).state = false;
          },
          onBackToLogin: () {
            ref.read(showRegisterProvider.notifier).state = false;
          },
        );
      }

      return LoginScreen(
        authService: auth,
        onLoginSuccess: () {
          ref.read(wsClientProvider).connect();
        },
        onRegisterTap: () {
          ref.read(showRegisterProvider.notifier).state = true;
        },
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
  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final pages = <Widget>[
      const HomeScreen(),
      const ConfigScreen(),
      const HistoryScreen(),
      const SettingsScreen(),
      const SmartHomeScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: _buildBottomNav(currentIndex),
    );
  }

  Widget _buildBottomNav(int currentIndex) {
    final bg = context.surface0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: context.surface900.withAlpha(15),
            blurRadius: 16,
            offset: const Offset(8, 8),
          ),
          BoxShadow(
            color: context.surface0.withAlpha(204),
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
          unselectedItemColor: context.surface500,
          currentIndex: currentIndex,
          onTap: (i) => ref.read(bottomNavIndexProvider.notifier).state = i,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'INICIO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_outlined),
              activeIcon: Icon(Icons.tune),
              label: 'GESTOS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'HISTORIAL',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'AJUSTES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb_outline),
              activeIcon: Icon(Icons.lightbulb),
              label: 'SMART HOME',
            ),
          ],
        ),
      ),
    );
  }
}
