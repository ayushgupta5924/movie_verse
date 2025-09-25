import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../core/enums.dart';
import '../models/show.dart';
import '../services/api_service.dart';

class ShowProvider extends ChangeNotifier {
  UIState _uiState = UIState.loading;
  UIState _searchState = UIState.success;
  List<Show> _shows = [];
  List<Show> _searchResults = [];
  List<Show> _favorites = [];
  FilterCategory _currentFilter = FilterCategory.trending;
  String? _errorMessage;
  String? _searchErrorMessage;
  
  int _currentPage = 0;
  bool _hasMoreData = true;
  bool _isLoadingMore = false;

  UIState get uiState => _uiState;
  UIState get searchState => _searchState;
  List<Show> get shows => _shows;
  List<Show> get searchResults => _searchResults;
  List<Show> get favorites => _favorites;
  FilterCategory get currentFilter => _currentFilter;
  String? get errorMessage => _errorMessage;
  String? get searchErrorMessage => _searchErrorMessage;
  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;

  ShowProvider() {
    loadFavorites();
  }

  Future<void> loadTrendingShows() async {
    _currentPage = 0;
    _hasMoreData = true;
    _setLoading();
    try {
      _shows = await ApiService.getTrendingShows(_currentPage);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<void> loadMoreShows() async {
    if (_isLoadingMore || !_hasMoreData) return;
    
    _isLoadingMore = true;
    notifyListeners();
    
    try {
      final newShows = await _getShowsByFilter(_currentPage + 1);
      if (newShows.isNotEmpty) {
        _shows.addAll(newShows);
        _currentPage++;
      } else {
        _hasMoreData = false;
      }
    } catch (e) {
      // Handle error silently for pagination
    }
    
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> searchShows(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _searchState = UIState.success;
      notifyListeners();
      return;
    }
    
    _setSearchLoading();
    try {
      _searchResults = await ApiService.searchShows(query);
      _setSearchSuccess();
    } catch (e) {
      _setSearchError(e.toString());
    }
  }

  void setFilter(FilterCategory filter) {
    _currentFilter = filter;
    notifyListeners();
    _loadShowsByFilter();
  }

  Future<void> _loadShowsByFilter() async {
    _currentPage = 0;
    _hasMoreData = true;
    _setLoading();
    try {
      _shows = await _getShowsByFilter(0);
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }
  
  Future<List<Show>> _getShowsByFilter(int page) async {
    switch (_currentFilter) {
      case FilterCategory.trending:
        return await ApiService.getTrendingShows(page);
      case FilterCategory.popular:
        return await ApiService.getPopularShows(page);
      case FilterCategory.upcoming:
        return await ApiService.getUpcomingShows(page);
    }
  }

  Future<void> loadFavorites() async {
    final box = await Hive.openBox<Show>('favorites');
    _favorites = box.values.toList();
    notifyListeners();
  }

  Future<void> toggleFavorite(Show show) async {
    final box = await Hive.openBox<Show>('favorites');
    if (isFavorite(show)) {
      await box.delete(show.id);
      _favorites.removeWhere((s) => s.id == show.id);
    } else {
      await box.put(show.id, show);
      _favorites.add(show);
    }
    notifyListeners();
  }

  bool isFavorite(Show show) {
    return _favorites.any((s) => s.id == show.id);
  }

  void _setLoading() {
    _uiState = UIState.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _uiState = UIState.success;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _uiState = UIState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setSearchLoading() {
    _searchState = UIState.loading;
    _searchErrorMessage = null;
    notifyListeners();
  }

  void _setSearchSuccess() {
    _searchState = UIState.success;
    _searchErrorMessage = null;
    notifyListeners();
  }

  void _setSearchError(String message) {
    _searchState = UIState.error;
    _searchErrorMessage = message;
    notifyListeners();
  }
}