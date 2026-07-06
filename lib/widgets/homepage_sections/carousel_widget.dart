import 'package:flutter/material.dart';
import '../../models/homepage_section.dart';

class CarouselWidget extends StatelessWidget {
  final HomepageSection section;

  const CarouselWidget({super.key, required this.section});

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
        // Just rendering a placeholder for CAROUSEL
        Container(
          height: 250,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text('Carousel Layout (To be implemented)', style: TextStyle(color: Colors.white54)),
        ),
        const SizedBox(height: 36),
      ],
    );
  }
}
