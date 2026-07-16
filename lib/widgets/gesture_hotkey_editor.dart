import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';

class GestureHotkeyEditor extends StatelessWidget {
  final TextEditingController controller;

  const GestureHotkeyEditor({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, val, _) {
        final keys = val.text.isNotEmpty ? val.text.split(',') : <String>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (keys.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: keys.map((k) => Chip(
                    label: Text(
                      k.trim(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary600,
                      ),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.primary500.withAlpha(20),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  )).toList(),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Teclas separadas por coma',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.surface400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Combinación (separada por coma)',
                labelStyle: TextStyle(color: context.surface500),
                hintText: 'ctrl,shift,esc',
                hintStyle: TextStyle(color: context.surface400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.surface200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: context.surface200),
                ),
                filled: true,
                fillColor: context.surface0,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
              style: TextStyle(fontSize: 14, color: context.surface700),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              'Predefinidos:',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: context.surface500,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _presetChip('Ctrl+C', 'ctrl,c'),
                _presetChip('Ctrl+V', 'ctrl,v'),
                _presetChip('Ctrl+X', 'ctrl,x'),
                _presetChip('Ctrl+Z', 'ctrl,z'),
                _presetChip('Win+D', 'win,d'),
                _presetChip('Alt+Tab', 'alt,tab'),
                _presetChip('Win+E', 'win,e'),
                _presetChip('Ctrl+Shift+Esc', 'ctrl,shift,esc'),
                _presetChip('F5', 'f5'),
                _presetChip('F11', 'f11'),
                _presetChip('Win+R', 'win,r'),
                _presetChip('Ctrl+Alt+Del', 'ctrl,alt,delete'),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _presetChip(String label, String value) {
    return ActionChip(
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary600,
        ),
      ),
      onPressed: () => controller.text = value,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.primary500.withAlpha(12),
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
