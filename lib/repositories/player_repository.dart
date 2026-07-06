import 'base_repository.dart';

class PlayerRepository extends BaseRepository {
  Future<Map<String, dynamic>> fetchMetadata(String songId) async {
    return safeApiCall(() async {
      final response = await dio.get('/api/v1/player/metadata/$songId');
      return response.data;
    });
  }
}
