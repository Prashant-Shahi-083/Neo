import 'package:flutter/material.dart';
import '../../models/homepage_section.dart';
import 'hero_banner_widget.dart';
import 'carousel_widget.dart';
import 'grid_widget.dart';
import 'horizontal_list_widget.dart';

class HomepageWidgetFactory {
  static Widget build(HomepageSection section) {
    switch (section.type) {
      case SectionType.heroBanner:
        return HeroBannerWidget(section: section);
      case SectionType.carousel:
        return CarouselWidget(section: section);
      case SectionType.grid:
        return GridWidget(section: section);
      case SectionType.horizontalList:
      case SectionType.featuredArtists:
      case SectionType.trending:
      case SectionType.newReleases:
      case SectionType.recommended:
      case SectionType.continueListening:
        return HorizontalListWidget(section: section);
      case SectionType.unknown:
      default:
        // Graceful degradation for unknown types
        return const SizedBox.shrink();
    }
  }
}
