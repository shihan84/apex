# Apex OTT Flutter App

A comprehensive OTT streaming application built with Flutter, supporting Android, iOS, and Android TV platforms.

## 🚀 Features

### 📱 Multi-Platform Support
- **Android** - Full feature support with Material Design
- **iOS** - Native iOS experience with Cupertino design  
- **Android TV** - Optimized for TV with remote control support

### 🎬 Content Types
- **Movies & Series** - Full VOD support with MP4, HLS, DASH, MPD formats
- **Live TV** - Real-time streaming with HLS/DASH support
- **Music** - Audio streaming with playlists and artist support
- **Shorts/Reels** - Vertical video content with portrait view
- **Documentaries** - Educational and informational content

### 🎥 Video Player Features
- **Multiple Formats** - MP4, HLS, DASH, MPD, WebM, MKV support
- **Quality Selection** - Auto, 480p, 720p, 1080p, 4K
- **Audio Tracks** - Multiple language audio support
- **Subtitles** - SRT, VTT subtitle support
- **Controls** - Gesture-based controls, skip forward/backward
- **Offline** - Download for offline viewing

### 🌍 Indian Language Support
- **Languages** - Hindi, English, Tamil, Telugu, Bengali, Gujarati, Kannada, Malayalam, Marathi, Punjabi, Odia, Assamese, Nepali, Urdu
- **Genres** - Action, Comedy, Drama, Romance, Thriller, Horror, Sci-Fi, Fantasy, Documentary, Crime, Mystery, Adventure, Family, Animation, Biography, History, Music, Sports, War, Western

## 🛠️ Technology Stack

- **Framework** - Flutter 3.0+
- **State Management** - Provider + Bloc
- **Video Player** - Better Player, Chewie, FijkPlayer
- **Audio Player** - Just Audio
- **HTTP Client** - Dio with Retrofit
- **Storage** - Hive, SharedPreferences, SQLite
- **UI Components** - Material Design 3

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Xcode (for iOS development)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/apex-ott.git
   cd apex-ott/flutter_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Configure API endpoints**
   - Update `lib/core/constants/app_constants.dart`
   - Set your API base URL

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### API Configuration

Update `lib/core/constants/app_constants.dart`:

```dart
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://your-api-domain.com/api';
  static const String mediaBaseUrl = 'https://your-media-domain.com';
  static const int apiTimeout = 30000; // 30 seconds
}
```

### Video Player Configuration

```dart
// Video Player Configuration
static const Duration videoBufferDuration = Duration(seconds: 10);
static const Duration videoSeekDuration = Duration(seconds: 10);
static const int maxRetryAttempts = 3;
```

### Storage Configuration

```dart
// Cache Configuration
static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
static const Duration cacheExpiry = Duration(days: 7);
```

## 📱 Platform-Specific Setup

### Android Setup

1. **Add permissions** in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.WAKE_LOCK" />
   <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
   ```

2. **Configure ProGuard** in `android/app/proguard-rules.pro`:
   ```pro
   -keep class com.apex.ott.** { *; }
   -keep class com.google.android.exoplayer2.** { *; }
   ```

3. **Add network security config** in `android/app/src/main/res/xml/network_security_config.xml`:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <network-security-config>
       <domain-config cleartextTrafficPermitted="true">
           <domain includeSubdomains="true">your-api-domain.com</domain>
       </domain-config>
   </network-security-config>
   ```

### iOS Setup

1. **Add permissions** in `ios/Runner/Info.plist`:
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   <key>NSMicrophoneUsageDescription</key>
   <string>This app needs access to microphone for audio features</string>
   <key>NSCameraUsageDescription</key>
   <string>This app needs access to camera for profile pictures</string>
   ```

2. **Configure background modes**:
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>audio</string>
       <string>background-processing</string>
   </array>
   ```

3. **Add capabilities** in `ios/Runner.xcodeproj`:
   - Background Modes
   - Push Notifications
   - In-App Purchase

### Android TV Setup

1. **Add TV support** in `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-feature
       android:name="android.software.leanback"
       android:required="false" />
   <uses-feature
       android:name="android.hardware.touchscreen"
       android:required="false" />
   <uses-feature
       android:name="android.hardware.faketouch"
       android:required="false" />
   ```

2. **Configure TV activity**:
   ```xml
   <activity
       android:name=".MainActivity"
       android:exported="true"
       android:screenOrientation="landscape"
       android:theme="@style/Theme.AppCompat.NoActionBar">
       <intent-filter>
           <action android:name="android.intent.action.MAIN" />
           <category android:name="android.intent.category.LAUNCHER" />
           <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
       </intent-filter>
   </activity>
   ```

3. **Add TV banner** in `android/app/src/main/res/drawable/tv_banner.xml`:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <vector xmlns:android="http://schemas.android.com/apk/res/android"
       android:width="320dp"
       android:height="180dp"
       android:viewportWidth="320"
       android:viewportHeight="180">
       <path
           android:fillColor="#E50914"
           android:pathData="M0,0h320v180h-320z" />
   </vector>
   ```

## 🚀 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS App
```bash
flutter build ios --release
```

### Android TV APK
```bash
flutter build apk --release --target-platform android-arm64
```

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/          # App constants and configuration
│   ├── models/            # Data models
│   ├── providers/         # State management providers
│   ├── services/          # API and business logic services
│   ├── theme/             # App theme and styling
│   └── routes/            # Navigation routes
├── screens/               # UI screens
├── widgets/               # Reusable UI components
├── utils/                 # Utility functions
└── main.dart             # App entry point
```

## 🎨 UI Components

### Core Components
- **ContentCarousel** - Horizontal scrolling content lists
- **VideoPlayerWidget** - Custom video player with controls
- **SearchBar** - Search functionality
- **UserProfileDrawer** - User profile and settings

### Screen Components
- **HomeScreen** - Main dashboard
- **SearchScreen** - Content search
- **LiveTVScreen** - Live TV channels
- **MusicScreen** - Music streaming
- **ShortsScreen** - Short-form content

## 🔧 Development

### Code Generation
```bash
# Generate JSON serialization code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Linting
```bash
# Check code style
flutter analyze

# Fix code style issues
dart fix --apply
```

## 📊 Performance Optimization

### Video Streaming
- Adaptive bitrate streaming
- Preloading and buffering
- Quality selection based on network
- Offline download support

### Caching
- Image caching with CachedNetworkImage
- API response caching
- Video thumbnail caching
- User preference caching

### Memory Management
- Lazy loading of content
- Image compression and resizing
- Video player cleanup
- Garbage collection optimization

## 🔒 Security

### Data Protection
- Encrypted local storage
- Secure API communication
- User authentication tokens
- Content DRM support

### Privacy
- GDPR compliance
- User data anonymization
- Consent management
- Data retention policies

## 🐛 Troubleshooting

### Common Issues

1. **Video not playing**
   - Check network connectivity
   - Verify video URL format
   - Check device compatibility

2. **Build errors**
   - Clean build: `flutter clean`
   - Get dependencies: `flutter pub get`
   - Check Flutter version compatibility

3. **Performance issues**
   - Enable Flutter performance overlay
   - Check memory usage
   - Optimize image sizes

### Debug Mode
```bash
# Enable debug mode
flutter run --debug

# Enable performance overlay
flutter run --enable-software-rendering
```

## 📱 Device Testing

### Android Devices
- Test on various screen sizes
- Check different Android versions
- Test with different network conditions

### iOS Devices
- Test on iPhone and iPad
- Check different iOS versions
- Test with different orientations

### Android TV
- Test with remote control
- Check navigation flow
- Test video playback

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Email: support@apex-ott.com
- Documentation: [docs.apex-ott.com](https://docs.apex-ott.com)
- Issues: [GitHub Issues](https://github.com/your-username/apex-ott/issues)

---

**Apex OTT Flutter App** - Redefining Mobile Entertainment Experience 📱✨
