import 'base_repository.dart';
import '../models/homepage_section.dart';
import '../models/pagination_meta.dart';

class HomeRepository extends BaseRepository {
  /// Fetches paginated homepage data from the backend.
  /// Returns a map with `sections` (list of HomepageSection) and `pagination` (PaginationMeta).
  Future<Map<String, dynamic>> fetchHomepageData({int page = 1, int limit = 10}) async {
    return safeApiCall(() async {
      logger.i('Fetching Homepage Data (page: $page, limit: $limit)...');
      final response = await dio.get('/api/v1/homepage', queryParameters: {
        'page': page,
        'limit': limit,
      });
      
      final data = response.data;
      
      return {
        'sections': (data['sections'] as List?)
            ?.map((e) => HomepageSection.fromJson(e))
            .toList() ?? <HomepageSection>[],
        'pagination': data['pagination'] != null
            ? PaginationMeta.fromJson(data['pagination'])
            : PaginationMeta.empty(),
      };
    });
  }
}
