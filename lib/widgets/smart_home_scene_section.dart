import 'package:flutter/material.dart';
import '../models/smart_home_device.dart';
import '../theme/context_extensions.dart';
import '../theme/spacing.dart';
import 'gantia_button.dart';
import 'settings_card.dart';
import 'smart_scene_card.dart';

class SmartHomeSceneSection extends StatefulWidget {
  final List<Scene> scenes;
  final int maxScenes;
  final Future<void> Function(Scene scene) onApplyScene;
  final void Function(int index) onDeleteScene;
  final void Function(String name) onAddScene;

  const SmartHomeSceneSection({
    super.key,
    required this.scenes,
    required this.maxScenes,
    required this.onApplyScene,
    required this.onDeleteScene,
    required this.onAddScene,
  });

  @override
  State<SmartHomeSceneSection> createState() => _SmartHomeSceneSectionState();
}

class _SmartHomeSceneSectionState extends State<SmartHomeSceneSection> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.scenes.isNotEmpty)
          SettingsCard(
            icon: Icons.view_quilt,
            title: 'ESCENAS',
            child: Column(
              children: widget.scenes.asMap().entries.map((e) => SmartSceneCard(
                scene: e.value,
                onApply: () => widget.onApplyScene(e.value),
                onDelete: () => widget.onDeleteScene(e.key),
              )).toList(),
            ),
          ),
        SettingsCard(
          icon: Icons.add_circle_outline,
          title: 'Agregar Escena',
          description: 'Guarda el estado actual de todas las luces como una escena',
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la escena',
                  hintText: 'Ej: Apagar todo',
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            GantiaButton(
              label: 'Guardar',
              icon: Icons.save,
              variant: GantiaButtonVariant.primary,
              onPressed: widget.scenes.length < widget.maxScenes
                  ? () { widget.onAddScene(_nameCtrl.text.trim()); _nameCtrl.clear(); }
                  : null,
            ),
          ]),
        ),
      ],
    );
  }
}
