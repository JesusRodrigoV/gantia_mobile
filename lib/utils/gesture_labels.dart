const Map<String, String> contextLabels = {
  'GLOBAL': 'Global',
  'AUDIO': 'Audio',
  'PRESENTATION': 'Presentación',
  'WORK': 'Trabajo',
  'WORKSHOP': 'Workshop',
};

String getContextLabel(String c) => contextLabels[c] ?? c;

const Map<String, String> movementLabels = {
  'NONE': 'Ninguno',
  'SWIPE_UP': 'Arriba ↑',
  'SWIPE_DOWN': 'Abajo ↓',
  'SWIPE_LEFT': 'Izquierda ←',
  'SWIPE_RIGHT': 'Derecha →',
  'TWIST': 'Giro',
  'COMPOSITE': 'Compuesto',
};

String getMovementLabel(String m) => movementLabels[m] ?? m;

const Map<String, String> orientationLabels = {
  'ANY': 'Cualquiera',
  'PALM_UP': 'Palma Arriba',
  'PALM_DOWN': 'Palma Abajo',
  'UP': 'Hacia Arriba',
  'DOWN': 'Hacia Abajo',
  'NEUTRAL': 'Neutral',
};

String getOrientationLabel(String o) => orientationLabels[o] ?? o;

const Map<int, String> flexStateLabels = {
  0: 'Abierto',
  1: 'Parcial',
  2: 'Flexionado',
};

String getFlexStateLabel(int s) => flexStateLabels[s] ?? s.toString();
