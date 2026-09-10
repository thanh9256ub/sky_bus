import 'package:flutter/material.dart';
import 'package:skysoft_bus/models/place_model.dart';

class LayerMapDialog extends StatelessWidget {
  final MapLayerType currentLayer;
  final Function(MapLayerType value) onChanged;
  const LayerMapDialog({
    super.key,
    required this.currentLayer,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text("SkyMap"),
            trailing: currentLayer == MapLayerType.skymap
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.of(context).pop();
              onChanged(MapLayerType.skymap);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Google Map"),
            trailing: currentLayer == MapLayerType.googleGM
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.of(context).pop();
              onChanged(MapLayerType.googleGM);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Google vệ tinh"),
            trailing: currentLayer == MapLayerType.googleGE
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              Navigator.of(context).pop();
              onChanged(MapLayerType.googleGE);
            },
          ),
        ],
      ),
    );
  }
}
