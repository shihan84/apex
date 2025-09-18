import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../models/content_model.dart';
import '../services/api_service.dart';
import '../constants/app_constants.dart';

class ContentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService(Dio());
  
  // State variables
  List<ContentModel> _trendingContent = [];
  List<ContentModel> _featuredContent = [];
  List<ContentModel> _newContent = [];
  List<ContentModel> _searchResults = [];
  List<ContentModel> _favorites = [];
  List<ContentModel> _watchlist = [];
  List<ContentModel> _history = [];
  List<LiveChannel> _liveChannels = [];
  List<Playlist> _playlists = [];
  List<Artist> _artists = [];
  List<ContentModel> _shorts = [];
  
  Map<String, List<ContentModel>> _contentByCategory = {};
  Map<String, List<ContentModel>> _contentByGenre = {};
  Map<String, List<ContentModel>> _contentByLanguage = {};
  
  ContentModel? _currentContent;
  List<ContentVideo> _currentVideos = [];
  List<ContentAudio> _currentAudios = [];
  List<ContentSubtitle> _currentSubtitles = [];
  List<ContentCast> _currentCast = [];
  List<ContentCrew> _currentCrew = [];
  List<ContentModel> _relatedContent = [];
  
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  String _currentSearchQuery = '';
  String _currentFilter = 'all';
  String _currentLanguage = 'en';
  String _currentGenre = 'all';

  // Getters
  List<ContentModel> get trendingContent => _trendingContent;
  List<ContentModel> get featuredContent => _featuredContent;
  List<ContentModel> get newContent => _newContent;
  List<ContentModel> get searchResults => _searchResults;
  List<ContentModel> get favorites => _favorites;
  List<ContentModel> get watchlist => _watchlist;
  List<ContentModel> get history => _history;
  List<LiveChannel> get liveChannels => _liveChannels;
  List<Playlist> get playlists => _playlists;
  List<Artist> get artists => _artists;
  List<ContentModel> get shorts => _shorts;
  
  Map<String, List<ContentModel>> get contentByCategory => _contentByCategory;
  Map<String, List<ContentModel>> get contentByGenre => _contentByGenre;
  Map<String, List<ContentModel>> get contentByLanguage => _contentByLanguage;
  
  ContentModel? get currentContent => _currentContent;
  List<ContentVideo> get currentVideos => _currentVideos;
  List<ContentAudio> get currentAudios => _currentAudios;
  List<ContentSubtitle> get currentSubtitles => _currentSubtitles;
  List<ContentCast> get currentCast => _currentCast;
  List<ContentCrew> get currentCrew => _currentCrew;
  List<ContentModel> get relatedContent => _relatedContent;
  
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String get currentSearchQuery => _currentSearchQuery;
  String get currentFilter => _currentFilter;
  String get currentLanguage => _currentLanguage;
  String get currentGenre => _currentGenre;

  // Load trending content
  Future<void> loadTrendingContent({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _trendingContent.clear();
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getTrendingContent(
        page: _currentPage,
        limit: 20,
        type: _currentFilter != 'all' ? _currentFilter : null,
        language: _currentLanguage != 'all' ? _currentLanguage : null,
        genre: _currentGenre != 'all' ? _currentGenre : null,
      );
      
      if (refresh) {
        _trendingContent = response.data;
      } else {
        _trendingContent.addAll(response.data);
      }
      
      _hasMore = response.hasNext;
      _currentPage++;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load trending content: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load featured content
  Future<void> loadFeaturedContent({bool refresh = false}) async {
    if (refresh) {
      _featuredContent.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getFeaturedContent(
        page: 1,
        limit: 20,
        type: _currentFilter != 'all' ? _currentFilter : null,
      );
      
      _featuredContent = response.data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load featured content: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load new content
  Future<void> loadNewContent({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _newContent.clear();
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getNewContent(
        page: _currentPage,
        limit: 20,
        type: _currentFilter != 'all' ? _currentFilter : null,
      );
      
      if (refresh) {
        _newContent = response.data;
      } else {
        _newContent.addAll(response.data);
      }
      
      _hasMore = response.hasNext;
      _currentPage++;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load new content: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search content
  Future<void> searchContent(String query, {bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _searchResults.clear();
      _hasMore = true;
      _currentSearchQuery = query;
    }
    
    if (!_hasMore || query.isEmpty) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.searchContent(
        query: query,
        page: _currentPage,
        limit: 20,
        type: _currentFilter != 'all' ? _currentFilter : null,
        language: _currentLanguage != 'all' ? _currentLanguage : null,
        genre: _currentGenre != 'all' ? _currentGenre : null,
      );
      
      if (refresh) {
        _searchResults = response.data;
      } else {
        _searchResults.addAll(response.data);
      }
      
      _hasMore = response.hasNext;
      _currentPage++;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to search content: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load content details
  Future<void> loadContentDetails(int contentId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _currentContent = await _apiService.getContent(contentId);
      _currentVideos = await _apiService.getContentVideos(contentId);
      _currentAudios = await _apiService.getContentAudios(contentId);
      _currentSubtitles = await _apiService.getContentSubtitles(contentId);
      _currentCast = await _apiService.getContentCast(contentId);
      _currentCrew = await _apiService.getContentCrew(contentId);
      _relatedContent = (await _apiService.getRelatedContent(contentId)).data;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load content details: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load live channels
  Future<void> loadLiveChannels({bool refresh = false}) async {
    if (refresh) {
      _liveChannels.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getLiveChannels(
        page: 1,
        limit: 50,
        category: _currentFilter != 'all' ? _currentFilter : null,
        language: _currentLanguage != 'all' ? _currentLanguage : null,
      );
      
      _liveChannels = response.data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load live channels: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load playlists
  Future<void> loadPlaylists({bool refresh = false}) async {
    if (refresh) {
      _playlists.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getPlaylists(
        page: 1,
        limit: 20,
        category: _currentFilter != 'all' ? _currentFilter : null,
        language: _currentLanguage != 'all' ? _currentLanguage : null,
      );
      
      _playlists = response.data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load playlists: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load artists
  Future<void> loadArtists({bool refresh = false}) async {
    if (refresh) {
      _artists.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getArtists(
        page: 1,
        limit: 20,
        language: _currentLanguage != 'all' ? _currentLanguage : null,
      );
      
      _artists = response.data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load artists: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load shorts
  Future<void> loadShorts({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _shorts.clear();
      _hasMore = true;
    }
    
    if (!_hasMore) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getShortsFeed(
        page: _currentPage,
        limit: 20,
        category: _currentFilter != 'all' ? _currentFilter : null,
        language: _currentLanguage != 'all' ? _currentLanguage : null,
      );
      
      if (refresh) {
        _shorts = response.data;
      } else {
        _shorts.addAll(response.data);
      }
      
      _hasMore = response.hasNext;
      _currentPage++;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to load shorts: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load favorites
  Future<void> loadFavorites({bool refresh = false}) async {
    if (refresh) {
      _favorites.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getFavorites(
        page: 1,
        limit: 50,
        type: _currentFilter != 'all' ? _currentFilter : null,
      );
      
      _favorites = response.data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load favorites: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load watchlist
  Future<void> loadWatchlist({bool refresh = false}) async {
    if (refresh) {
      _watchlist.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getWatchlist(
        page: 1,
        limit: 50,
        type: _currentFilter != 'all' ? _currentFilter : null,
      );
      
      _watchlist = response.data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load watchlist: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load history
  Future<void> loadHistory({bool refresh = false}) async {
    if (refresh) {
      _history.clear();
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final response = await _apiService.getHistory(
        page: 1,
        limit: 50,
        type: _currentFilter != 'all' ? _currentFilter : null,
      );
      
      _history = response.data;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load history: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add to favorites
  Future<bool> addToFavorites(int contentId, String type) async {
    try {
      final request = FavoriteRequest(contentId: contentId, type: type);
      await _apiService.addToFavorites(request);
      
      // Reload favorites
      await loadFavorites(refresh: true);
      
      return true;
    } catch (e) {
      _setError('Failed to add to favorites: $e');
      return false;
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(int contentId) async {
    try {
      await _apiService.removeFromFavorites(contentId);
      
      // Reload favorites
      await loadFavorites(refresh: true);
      
      return true;
    } catch (e) {
      _setError('Failed to remove from favorites: $e');
      return false;
    }
  }

  // Add to watchlist
  Future<bool> addToWatchlist(int contentId, String type) async {
    try {
      final request = WatchlistRequest(contentId: contentId, type: type);
      await _apiService.addToWatchlist(request);
      
      // Reload watchlist
      await loadWatchlist(refresh: true);
      
      return true;
    } catch (e) {
      _setError('Failed to add to watchlist: $e');
      return false;
    }
  }

  // Remove from watchlist
  Future<bool> removeFromWatchlist(int contentId) async {
    try {
      await _apiService.removeFromWatchlist(contentId);
      
      // Reload watchlist
      await loadWatchlist(refresh: true);
      
      return true;
    } catch (e) {
      _setError('Failed to remove from watchlist: $e');
      return false;
    }
  }

  // Add to history
  Future<bool> addToHistory(int contentId, String type, {int? duration, int? position}) async {
    try {
      final request = HistoryRequest(
        contentId: contentId,
        type: type,
        duration: duration,
        position: position,
      );
      await _apiService.addToHistory(request);
      
      // Reload history
      await loadHistory(refresh: true);
      
      return true;
    } catch (e) {
      _setError('Failed to add to history: $e');
      return false;
    }
  }

  // Rate content
  Future<bool> rateContent(int contentId, int rating, {String? review}) async {
    try {
      final request = RatingRequest(
        contentId: contentId,
        rating: rating,
        review: review,
      );
      await _apiService.rateContent(request);
      
      return true;
    } catch (e) {
      _setError('Failed to rate content: $e');
      return false;
    }
  }

  // Comment content
  Future<bool> commentContent(int contentId, String comment, {int? parentId}) async {
    try {
      final request = CommentRequest(
        contentId: contentId,
        comment: comment,
        parentId: parentId,
      );
      await _apiService.commentContent(request);
      
      return true;
    } catch (e) {
      _setError('Failed to comment: $e');
      return false;
    }
  }

  // Set filters
  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  void setGenre(String genre) {
    _currentGenre = genre;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchResults.clear();
    _currentSearchQuery = '';
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
