import 'package:flutter/material.dart';

class GantiaShadows {
  GantiaShadows._();

  static List<BoxShadow> elevated(Color surface900, Color surface0) => [
        BoxShadow(
          offset: const Offset(8, 8),
          blurRadius: 16,
          color: surface900.withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-8, -8),
          blurRadius: 16,
          color: surface0.withAlpha(204),
        ),
      ];

  static List<BoxShadow> inset(Color surface900, Color surface0) => [
        BoxShadow(
          offset: const Offset(4, 4),
          blurRadius: 8,
          color: surface900.withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-4, -4),
          blurRadius: 8,
          color: surface0.withAlpha(204),
        ),
      ];

  static List<BoxShadow> elevatedSm(Color surface900, Color surface0) => [
        BoxShadow(
          offset: const Offset(4, 4),
          blurRadius: 8,
          color: surface900.withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-4, -4),
          blurRadius: 8,
          color: surface0.withAlpha(204),
        ),
      ];

  static List<BoxShadow> insetSm(Color surface900, Color surface0) => [
        BoxShadow(
          offset: const Offset(2, 2),
          blurRadius: 4,
          color: surface900.withAlpha(15),
        ),
        BoxShadow(
          offset: const Offset(-2, -2),
          blurRadius: 4,
          color: surface0.withAlpha(204),
        ),
      ];
}
