import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('init', () {
    test('defaults to light mode when nothing is stored', () async {
      final service = await ThemeService.init();

      expect(service.isDarkMode, isFalse);
    });

    test('restores dark mode from prefs', () async {
      SharedPreferences.setMockInitialValues({'theme': 'dark'});

      final service = await ThemeService.init();

      expect(service.isDarkMode, isTrue);
    });

    test('ignores unknown stored values', () async {
      SharedPreferences.setMockInitialValues({'theme': 'purple'});

      final service = await ThemeService.init();

      expect(service.isDarkMode, isFalse);
    });
  });

  group('toggleTheme', () {
    test('toggles the mode and persists it', () async {
      final service = await ThemeService.init();
      expect(service.isDarkMode, isFalse);

      await service.toggleTheme();

      expect(service.isDarkMode, isTrue);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme'), 'dark');

      await service.toggleTheme();

      expect(service.isDarkMode, isFalse);
      expect(prefs.getString('theme'), 'light');
    });
  });
}
