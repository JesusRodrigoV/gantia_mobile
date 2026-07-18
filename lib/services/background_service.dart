import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

@pragma('vm:entry-point')
void backgroundServiceEntrypoint() {
  final service = FlutterBackgroundService();

  service.on('stop').listen((_) {
    service.stopSelf();
  });

  service.setNotificationInfo(
    title: 'Gantia',
    content: 'Controlando parlante Bluetooth',
  );

  service.setForegroundHandler((onForeground) {
    if (onForeground) {
      service.setNotificationInfo(
        title: 'Gantia',
        content: 'Controlando parlante Bluetooth',
      );
    } else {
      service.setNotificationInfo(
        title: 'Gantia',
        content: 'Funcionando en segundo plano',
      );
    }
    service.updateNotification();
  });
}

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: backgroundServiceEntrypoint,
      autoStart: false,
      autoStartOnBoot: false,
      isForegroundMode: true,
      notificationChannelId: 'gantia_background',
      initialNotificationTitle: 'Gantia',
      initialNotificationContent: 'Controlando parlante Bluetooth',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: true,
      onBackground: true,
    ),
  );

  service.startService();
}
