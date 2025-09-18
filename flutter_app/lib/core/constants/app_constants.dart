class AppConstants {
  // App Information
  static const String appName = 'Apex OTT';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.apex.ott';
  
  // API Configuration
  static const String baseUrl = 'https://your-api-domain.com/api';
  static const String mediaBaseUrl = 'https://your-media-domain.com';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String subscriptionKey = 'subscription_data';
  static const String settingsKey = 'app_settings';
  static const String watchHistoryKey = 'watch_history';
  static const String favoritesKey = 'favorites';
  
  // Video Player Configuration
  static const Duration videoBufferDuration = Duration(seconds: 10);
  static const Duration videoSeekDuration = Duration(seconds: 10);
  static const int maxRetryAttempts = 3;
  
  // Supported Video Formats
  static const List<String> supportedVideoFormats = [
    'mp4', 'm3u8', 'mpd', 'webm', 'mkv', 'avi'
  ];
  
  // Supported Audio Formats
  static const List<String> supportedAudioFormats = [
    'mp3', 'aac', 'wav', 'flac', 'm4a'
  ];
  
  // Indian Languages
  static const Map<String, String> indianLanguages = {
    'hi': 'Hindi',
    'en': 'English',
    'ta': 'Tamil',
    'te': 'Telugu',
    'bn': 'Bengali',
    'gu': 'Gujarati',
    'kn': 'Kannada',
    'ml': 'Malayalam',
    'mr': 'Marathi',
    'pa': 'Punjabi',
    'or': 'Odia',
    'as': 'Assamese',
    'ne': 'Nepali',
    'ur': 'Urdu',
  };
  
  // Content Genres
  static const List<String> contentGenres = [
    'Action',
    'Comedy',
    'Drama',
    'Romance',
    'Thriller',
    'Horror',
    'Sci-Fi',
    'Fantasy',
    'Documentary',
    'Crime',
    'Mystery',
    'Adventure',
    'Family',
    'Animation',
    'Biography',
    'History',
    'Music',
    'Sports',
    'War',
    'Western',
  ];
  
  // Subscription Plans
  static const Map<String, Map<String, dynamic>> subscriptionPlans = {
    'basic': {
      'name': 'Basic',
      'price': 199,
      'currency': 'INR',
      'duration': 30, // days
      'features': ['HD Quality', '1 Device', 'Basic Support'],
    },
    'premium': {
      'name': 'Premium',
      'price': 399,
      'currency': 'INR',
      'duration': 30,
      'features': ['4K Quality', '3 Devices', 'Priority Support', 'Download'],
    },
    'family': {
      'name': 'Family',
      'price': 599,
      'currency': 'INR',
      'duration': 30,
      'features': ['4K Quality', '6 Devices', 'Priority Support', 'Download', 'Kids Mode'],
    },
  };
  
  // Player Controls
  static const Duration skipForwardDuration = Duration(seconds: 10);
  static const Duration skipBackwardDuration = Duration(seconds: 10);
  static const Duration doubleTapSeekDuration = Duration(seconds: 10);
  
  // Cache Configuration
  static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
  static const Duration cacheExpiry = Duration(days: 7);
  
  // Network Configuration
  static const int maxConcurrentDownloads = 3;
  static const int downloadChunkSize = 1024 * 1024; // 1 MB
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 4.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
