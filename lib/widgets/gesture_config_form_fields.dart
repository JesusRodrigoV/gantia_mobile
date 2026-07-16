import 'package:flutter/material.dart';
import '../theme/context_extensions.dart';

class GestureConfigFormFields {
  GestureConfigFormFields._();

  static Widget buildDropdown({
    required BuildContext context,
    required String label,
    required ValueNotifier<String> value,
    required List<String> items,
    required String Function(String) labelFn,
  }) {
    return ValueListenableBuilder<String>(
      valueListenable: value,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.surface500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: context.surface50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.surface200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: val,
                  isExpanded: true,
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              labelFn(item),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.surface700,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) value.value = v;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget buildIntDropdown({
    required BuildContext context,
    required String label,
    required ValueNotifier<int> value,
    required List<int> items,
    required String Function(int) labelFn,
  }) {
    return ValueListenableBuilder<int>(
      valueListenable: value,
      builder: (context, val, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: context.surface500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: context.surface50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.surface200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: val,
                  isExpanded: true,
                  items: items
                      .map((item) => DropdownMenuItem(
                            value: item,
                            child: Text(
                              labelFn(item),
                              style: TextStyle(
                                fontSize: 13,
                                color: context.surface700,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) value.value = v;
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
