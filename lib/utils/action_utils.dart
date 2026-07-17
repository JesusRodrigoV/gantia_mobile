bool isGestureDetected(dynamic data) {
  return data is Map<String, dynamic> && data['type'] == 'gesture_detected';
}

bool isActionMessage(dynamic data) {
  return data is Map<String, dynamic> && data.containsKey('action');
}

bool isTelemetryData(dynamic data) {
  return data is Map<String, dynamic> && data.containsKey('accel_x');
}

const Map<String, String> actionLabels = {
  'mouse_mode': 'Mouse Mode',
  'volume_up': 'Subir Volumen',
  'volume_down': 'Bajar Volumen',
  'mute': 'Silenciar',
  'play_pause': 'Reproducir/Pausar',
  'next': 'Siguiente',
  'prev': 'Anterior',
  'scroll_up': 'Scroll Arriba',
  'scroll_down': 'Scroll Abajo',
  'back': 'Atrás',
  'forward': 'Adelante',
  'brightness_up': 'Brillo +',
  'brightness_down': 'Brillo -',
  'show_desktop': 'Mostrar Escritorio',
  'open_browser': 'Abrir Navegador',
  'open_url': 'Abrir URL',
  'open_app': 'Abrir App',
  'change_mode': 'Cambiar Modo',
  'hotkey': 'Hotkey',
  'next_slide': 'Siguiente Slide',
  'prev_slide': 'Slide Anterior',
  'start_present': 'Iniciar Presentación',
  'left_click': 'Click Izquierdo',
  'right_click': 'Click Derecho',
  'scroll': 'Scroll',
  'mouse_move': 'Mover Mouse',
  'execute_cmd': 'Ejecutar Comando',
  'sequence': 'Secuencia',
  'delay': 'Esperar',
  'light_on': 'Encender Luz',
  'light_off': 'Apagar Luz',
  'light_brightness': 'Brillo Luz',
};

String getActionLabel(String action) {
  return actionLabels[action] ?? action;
}
