import 'package:flutter/material.dart';
import '../../models/homepage_section.dart';

class GridWidget extends StatelessWidget {
  final HomepageSection section;

  const GridWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    if (section.items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        // Just rendering a placeholder for GRID
        Container(
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Grid Layout (To be implemented)', style: TextStyle(color: Colors.white54)),
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}
