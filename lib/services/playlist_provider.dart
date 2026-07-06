import 'package:flutter/foundation.dart';
import '../repositories/playlist_repository.dart';
import '../models/song.dart';
import '../models/playlist.dart';

class PlaylistProvider extends ChangeNotifier {
  final PlaylistRepository _repository = PlaylistRepository();

  bool _isLoading = false;
  String? _error;

  Playlist? _playlist;
  List<Song> _songs = [];
  String? _currentPlaylistId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  Playlist? get playlist => _playlist;
  List<Song> get songs => _songs;

  Future<void> loadPlaylist(String id) async {
    if (_currentPlaylistId == id) return;
    
    _currentPlaylistId = id;
    _isLoading = true;
    _error = null;
    _playlist = null;
    _songs = [];
    notifyListeners();

    try {
      final data = await _repository.getPlaylist(id);
      _playlist = data['playlist'] as Playlist;
      _songs = data['songs'] as List<Song>;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _currentPlaylistId = null;
    _playlist = null;
    _songs = [];
    _error = null;
    notifyListeners();
  }
}
