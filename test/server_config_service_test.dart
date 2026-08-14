import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gantia_mobile/services/server_config_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.testLoad();
  });

  group('urls', () {
    test('builds api and ws urls from host and port', () {
      final config = ServerConfigService('10.0.0.7', 9000);

      expect(config.apiUrl, 'http://10.0.0.7:9000');
      expect(config.wsUrl, 'ws://10.0.0.7:9000');
    });
  });

  group('persistence', () {
    test('setHostPort updates values and persists them', () async {
      final config = ServerConfigService('192.168.1.100', 8000);

      await config.setHostPort('10.0.0.7', 9000);

      expect(config.host, '10.0.0.7');
      expect(config.port, 9000);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('backend_host'), '10.0.0.7');
      expect(prefs.getInt('backend_port'), 9000);
    });

    test('load restores a saved configuration', () async {
      SharedPreferences.setMockInitialValues({
        'backend_host': '10.0.0.7',
        'backend_port': 9000,
      });

      final config = await ServerConfigService.load();

      expect(config.host, '10.0.0.7');
      expect(config.port, 9000);
    });

    test('load falls back to defaults when nothing is saved', () async {
      final config = await ServerConfigService.load();

      expect(config.host, '192.168.1.100');
      expect(config.port, 8000);
    });
  });
}