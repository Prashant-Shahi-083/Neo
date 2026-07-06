import 'package:flutter/foundation.dart';
import '../repositories/home_repository.dart';
import '../models/homepage_section.dart';
import '../models/pagination_meta.dart';

class HomeProvider extends ChangeNotifier {
  final HomeRepository _homeRepository = HomeRepository();
  
  // --- Initial load state ---
  bool _isLoading = true;
  String? _error;
  
  // --- Sections data ---
  List<HomepageSection> _sections = [];
  /// Track loaded section IDs to prevent duplicates across pages
  final Set<String> _loadedSectionIds = {};

  // --- Pagination state ---
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _paginationError;
  
  static const int _pageSize = 10;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<HomepageSection> get sections => _sections;
  int get currentPage => _currentPage;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get paginationError => _paginationError;

  List<dynamic> get recentlyPlayed => [];

  HomeProvider() {
    fetchHomeData();
  }

  /// Fetches the first page of homepage data.
  /// Resets all pagination state for a clean reload.
  Future<void> fetchHomeData() async {
    _isLoading = true;
    _error = null;
    _currentPage = 0;
    _hasMore = true;
    _isLoadingMore = false;
    _paginationError = null;
    _sections = [];
    _loadedSectionIds.clear();
    notifyListeners();

    try {
      final data = await _homeRepository.fetchHomepageData(page: 1, limit: _pageSize);
      final newSections = data['sections'] as List<HomepageSection>;
      final pagination = data['pagination'] as PaginationMeta;
      
      _mergeSections(newSections);
      _currentPage = pagination.currentPage;
      _hasMore = pagination.hasMore;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Loads the next page of homepage sections.
  /// Returns early if already loading or no more pages.
  Future<void> loadNextPage() async {
    // Guard: prevent concurrent requests or loading past the last page
    if (_isLoadingMore || !_hasMore || _isLoading) return;
    
    _isLoadingMore = true;
    _paginationError = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final data = await _homeRepository.fetchHomepageData(page: nextPage, limit: _pageSize);
      final newSections = data['sections'] as List<HomepageSection>;
      final pagination = data['pagination'] as PaginationMeta;

      _mergeSections(newSections);
      _currentPage = pagination.currentPage;
      _hasMore = pagination.hasMore;
      
      _isLoadingMore = false;
      notifyListeners();
    } catch (e) {
      _isLoadingMore = false;
      _paginationError = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Retry a failed pagination request (re-attempts the same next page).
  Future<void> retryLoadMore() async {
    _paginationError = null;
    notifyListeners();
    await loadNextPage();
  }

  /// Merges new sections into the existing list, deduplicating by ID.
  void _mergeSections(List<HomepageSection> newSections) {
    for (final section in newSections) {
      if (!_loadedSectionIds.contains(section.id)) {
        _loadedSectionIds.add(section.id);
        _sections.add(section);
      }
    }
  }
}
