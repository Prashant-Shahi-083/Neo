import 'base_repository.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class LibraryRepository extends BaseRepository {
  Future<Map<String, dynamic>> fetchLibrary() async {
    return safeApiCall(() async {
      final response = await dio.get('/api/v1/library');
      final data = response.data;
      
      return {
        'songs': (data['songs'] as List?)?.map((e) => Song.fromJson(e)).toList() ?? <Song>[],
        'playlists': (data['playlists'] as List?)?.map((e) => Playlist.fromJson(e)).toList() ?? <Playlist>[],
      };
    });
  }
}
