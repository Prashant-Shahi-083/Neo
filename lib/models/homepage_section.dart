import 'song.dart';
import 'playlist.dart';
import 'album.dart';
import 'artist.dart';

enum SectionType {
  heroBanner,
  carousel,
  grid,
  horizontalList,
  featuredArtists,
  trending,
  newReleases,
  recommended,
  continueListening,
  unknown
}

SectionType parseSectionType(String typeStr) {
  switch (typeStr) {
    case 'HERO_BANNER': return SectionType.heroBanner;
    case 'CAROUSEL': return SectionType.carousel;
    case 'GRID': return SectionType.grid;
    case 'HORIZONTAL_LIST': return SectionType.horizontalList;
    case 'FEATURED_ARTISTS': return SectionType.featuredArtists;
    case 'TRENDING': return SectionType.trending;
    case 'NEW_RELEASES': return SectionType.newReleases;
    case 'RECOMMENDED': return SectionType.recommended;
    case 'CONTINUE_LISTENING': return SectionType.continueListening;
    default: return SectionType.unknown;
  }
}

class HomepageItem {
  final String id;
  final String referenceType;
  final String referenceId;
  final int order;
  final dynamic data;

  HomepageItem({
    required this.id,
    required this.referenceType,
    required this.referenceId,
    required this.order,
    this.data,
  });

  factory HomepageItem.fromJson(Map<String, dynamic> json) {
    dynamic parsedData;
    if (json['data'] != null) {
      final dataJson = json['data'];
      switch (json['referenceType']) {
        case 'SONG':
          parsedData = Song.fromJson(dataJson);
          break;
        case 'PLAYLIST':
          parsedData = Playlist.fromJson(dataJson);
          break;
        case 'ALBUM':
          parsedData = Album.fromJson(dataJson);
          break;
        case 'ARTIST':
          parsedData = Artist.fromJson(dataJson);
          break;
      }
    }

    return HomepageItem(
      id: json['id'] ?? '',
      referenceType: json['referenceType'] ?? '',
      referenceId: json['referenceId'] ?? '',
      order: json['order'] ?? 0,
      data: parsedData,
    );
  }
}

class HomepageSection {
  final String id;
  final String title;
  final SectionType type;
  final int order;
  final List<HomepageItem> items;

  HomepageSection({
    required this.id,
    required this.title,
    required this.type,
    required this.order,
    required this.items,
  });

  factory HomepageSection.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<HomepageItem> parsedItems = itemsList.map((i) => HomepageItem.fromJson(i)).toList();

    // Ensure items are ordered correctly
    parsedItems.sort((a, b) => a.order.compareTo(b.order));

    return HomepageSection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      type: parseSectionType(json['type'] ?? ''),
      order: json['order'] ?? 0,
      items: parsedItems,
    );
  }
}
