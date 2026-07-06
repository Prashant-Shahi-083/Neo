import 'base_repository.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/pagination_meta.dart';

class SearchRepository extends BaseRepository {
  Future<Map<String, dynamic>> search(String query, {int page = 1, int limit = 20, String? type}) async {
    return safeApiCall(() async {
      final queryParams = {
        'q': query,
        'page': page,
        'limit': limit,
        if (type != null) 'type': type,
      };

      final response = await dio.get('/api/v1/search', queryParameters: queryParams);
      final data = response.data;
      final results = data['results'] ?? {};

      return {
        'query': data['query'] ?? query,
        'songs': (results['songs'] as List?)?.map((e) => Song.fromJson(e)).toList() ?? <Song>[],
        'playlists': (results['playlists'] as List?)?.map((e) => Playlist.fromJson(e)).toList() ?? <Playlist>[],
        'albums': (results['albums'] as List?)?.map((e) => Album.fromJson(e)).toList() ?? <Album>[],
        'artists': (results['artists'] as List?)?.map((e) => Artist.fromJson(e)).toList() ?? <Artist>[],
        'pagination': PaginationMeta.fromJson(data['pagination'] ?? {}),
      };
    });
  }
}
