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
    fetchLibrary();
  }

  Future<void> fetchLibrary() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _repository.fetchLibrary();
      _likedSongs = results['songs'] as List<Song>;
      _playlists = results['playlists'] as List<Playlist>;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
