import 'dart:async';
import 'package:flutter/foundation.dart';
import '../repositories/search_repository.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../models/album.dart';
import '../models/artist.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository _repository = SearchRepository();
  
  bool _isSearching = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _error;
  
  List<Song> _songs = [];
  List<Playlist> _playlists = [];
  List<Album> _albums = [];
  List<Artist> _artists = [];
  List<String> _searchHistory = [];
  
  String _currentQuery = '';
  int _currentPage = 1;
  Timer? _debounceTimer;

  bool get isSearching => _isSearching;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  
  List<Song> get songs => _songs;
  List<Playlist> get playlists => _playlists;
  List<Album> get albums => _albums;
  List<Artist> get artists => _artists;
  String get currentQuery => _currentQuery;
  List<String> get searchHistory => _searchHistory;

  void search(String query) {
    if (_currentQuery == query && query.isNotEmpty) return;
    _currentQuery = query;
    
    if (query.isEmpty) {
      clearSearch();
      return;
    }
    
    _isSearching = true;
    _error = null;
    notifyListeners();

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      await _executeSearch(query, isLoadMore: false);
    });
  }

  Future<void> loadNextPage() async {
    if (_isLoadingMore || !_hasMore || _currentQuery.isEmpty) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    await _executeSearch(_currentQuery, isLoadMore: true);
  }
  
  Future<void> retrySearch() async {
    if (_currentQuery.isEmpty) return;
    
    _error = null;
    if (_songs.isEmpty && _playlists.isEmpty && _albums.isEmpty && _artists.isEmpty) {
      _isSearching = true;
    } else {
      _isLoadingMore = true;
    }
    notifyListeners();
    
    await _executeSearch(_currentQuery, isLoadMore: _currentPage > 1);
  }
  
  Future<void> _executeSearch(String query, {required bool isLoadMore}) async {
    try {
      final page = isLoadMore ? _currentPage + 1 : 1;
      final response = await _repository.search(query, page: page, limit: 20);
      
      if (_currentQuery != query) return; // ignore stale results
      
      final newSongs = response['songs'] as List<Song>;
      final newPlaylists = response['playlists'] as List<Playlist>;
      final newAlbums = response['albums'] as List<Album>;
      final newArtists = response['artists'] as List<Artist>;
      final pagination = response['pagination'];
      
      if (isLoadMore) {
        _songs.addAll(newSongs);
        _playlists.addAll(newPlaylists);
        _albums.addAll(newAlbums);
        _artists.addAll(newArtists);
      } else {
        _songs = newSongs;
        _playlists = newPlaylists;
        _albums = newAlbums;
        _artists = newArtists;
        addToHistory(query);
      }
      
      _currentPage = page;
      _hasMore = pagination?.hasMore ?? false;
      _error = null;
    } catch (e) {
      if (_currentQuery != query) return;
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isSearching = false;
      _isLoadingMore = false;
      notifyListeners();
    }
  }
  
  void clearSearch() {
    _currentQuery = '';
    _songs = [];
    _playlists = [];
    _albums = [];
    _artists = [];
    _error = null;
    _isSearching = false;
    _isLoadingMore = false;
    _hasMore = false;
    _currentPage = 1;
    notifyListeners();
  }

  void addToHistory(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    
    _searchHistory.remove(trimmed);
    _searchHistory.insert(0, trimmed);
    
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    notifyListeners();
  }

  void removeHistoryItem(int index) {
    if (index >= 0 && index < _searchHistory.length) {
      _searchHistory.removeAt(index);
      notifyListeners();
    }
  }

  void clearHistory() {
    _searchHistory.clear();
    notifyListeners();
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
