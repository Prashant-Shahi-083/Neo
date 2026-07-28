import 'package:flutter/foundation.dart';
import '../repositories/library_repository.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryRepository _repository = LibraryRepository();

  bool _isLoading = false;
  String? _error;

  List<Song> _likedSongs = [];
  List<Playlist> _playlists = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Song> get likedSongs => _likedSongs;
  List<Playlist> get playlists => _playlists;

  LibraryProvider() {
    print('📚 [LIBRARY PROVIDER] [${DateTime.now().toIso8601String()}] LibraryProvider instantiated. Calling fetchLibrary()...');
    fetchLibrary();
  }

  Future<void> fetchLibrary() async {
    print('📚 [LIBRARY PROVIDER] [${DateTime.now().toIso8601String()}] fetchLibrary() started');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📚 [LIBRARY PROVIDER] [${DateTime.now().toIso8601String()}] Calling _repository.fetchLibrary()...');
      final results = await _repository.fetchLibrary();
      _likedSongs = results['songs'] as List<Song>;
      _playlists = results['playlists'] as List<Playlist>;
      _error = null;
      print('📚 [LIBRARY PROVIDER] [${DateTime.now().toIso8601String()}] fetchLibrary() succeeded. Loaded ${_likedSongs.length} liked songs, ${_playlists.length} playlists.');
    } catch (e) {
      print('❌ [LIBRARY PROVIDER] [${DateTime.now().toIso8601String()}] fetchLibrary() failed: $e');
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      print('📚 [LIBRARY PROVIDER] [${DateTime.now().toIso8601String()}] fetchLibrary() finally: setting _isLoading=false, calling notifyListeners()');
      notifyListeners();
    }
  }
}
