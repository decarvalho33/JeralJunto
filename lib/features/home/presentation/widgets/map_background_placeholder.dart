import 'package:flutter/material.dart';

class MapBackgroundPlaceholder extends StatelessWidget {
  const MapBackgroundPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple.shade50,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.map, size: 72, color: Colors.black54),
          SizedBox(height: 12),
          Text(
            'Mapa (Em breve)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
