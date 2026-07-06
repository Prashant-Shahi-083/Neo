import 'base_repository.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class PlaylistRepository extends BaseRepository {
  Future<Map<String, dynamic>> getPlaylist(String id) async {
    return safeApiCall(() async {
      final response = await dio.get('/api/v1/playlists/$id');
      final data = response.data;
      
      final playlist = Playlist.fromJson(data);
      final songs = (data['playlistSongs'] as List?)
          ?.map((ps) => Song.fromJson(ps['song']))
          .toList() ?? [];
          
      return {
        'playlist': playlist,
        'songs': songs,
      };
    });
  }
}
