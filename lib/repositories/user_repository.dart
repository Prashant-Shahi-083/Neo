import 'base_repository.dart';
import '../models/user_profile.dart';

class UserRepository extends BaseRepository {
  Future<UserProfile?> getProfile() async {
    try {
      return await safeApiCall(() async {
        final response = await dio.get('/api/v1/auth/me');
        return UserProfile.fromJson(response.data);
      });
    } catch (e) {
      logger.e('API failed, returning null profile: $e');
      return null;
    }
  }
}
