class AppConfig {
  AppConfig._();

  // CAMBIÁ SOLO ESTO cuando cambies de red
  static const String backendHost = '192.168.1.100';
  static const int backendPort = 8000;

  static String get apiUrl => 'http://$backendHost:$backendPort';
  static String get wsUrl => 'ws://$backendHost:$backendPort';
}
