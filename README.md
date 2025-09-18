# Apex OTT - Comprehensive Streaming Platform

A complete OTT/IPTV/Music/LiveTV/Shorts application built with Flutter and Laravel, supporting Android, iOS, and Android TV platforms.

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

### 💳 Subscription Management
- **Plans** - Basic, Premium, Family plans
- **Payment** - Razorpay, Stripe, Paytm integration
- **Billing** - Automated subscription management

### 🔐 User Management
- **Authentication** - Email/Phone registration and login
- **Profiles** - User preferences and settings
- **Favorites** - Save favorite content
- **Watchlist** - Queue content for later
- **History** - Track viewing history

### 🎛️ Admin Panel
- **Dashboard** - Analytics and statistics
- **Content Management** - Upload and manage content
- **User Management** - Manage users and subscriptions
- **Analytics** - Detailed usage analytics
- **Live Monitoring** - Real-time system monitoring

## 🛠️ Technology Stack

### Frontend (Flutter)
- **Framework** - Flutter 3.0+
- **State Management** - Provider + Bloc
- **Video Player** - Better Player, Chewie, FijkPlayer
- **Audio Player** - Just Audio
- **HTTP Client** - Dio with Retrofit
- **Storage** - Hive, SharedPreferences, SQLite
- **UI Components** - Material Design 3

### Backend (Laravel)
- **Framework** - Laravel 10+
- **Authentication** - Laravel Sanctum
- **API** - RESTful API with JSON responses
- **Storage** - AWS S3, Google Cloud Storage
- **Search** - Laravel Scout with Meilisearch
- **Queue** - Redis with Laravel Horizon
- **Monitoring** - Laravel Telescope

### Database
- **Primary** - MySQL/PostgreSQL
- **Cache** - Redis
- **Search** - Meilisearch
- **File Storage** - AWS S3/Google Cloud Storage

## 📦 Installation

### Prerequisites
- Flutter SDK 3.0+
- PHP 8.1+
- Composer
- MySQL/PostgreSQL
- Redis
- Node.js (for admin panel)

### Flutter App Setup

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

### Laravel Backend Setup

1. **Navigate to backend**
   ```bash
   cd laravel_backend
   ```

2. **Install dependencies**
   ```bash
   composer install
   ```

3. **Environment setup**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Database setup**
   ```bash
   php artisan migrate
   php artisan db:seed
   ```

5. **Storage setup**
   ```bash
   php artisan storage:link
   ```

6. **Start the server**
   ```bash
   php artisan serve
   ```

### Admin Panel Setup

1. **Install dependencies**
   ```bash
   cd laravel_backend
   npm install
   ```

2. **Build assets**
   ```bash
   npm run dev
   ```

3. **Access admin panel**
   - URL: `http://localhost:8000/admin`
   - Default credentials: admin@apex.com / password

## 🔧 Configuration

### Flutter App Configuration

1. **API Configuration**
   ```dart
   // lib/core/constants/app_constants.dart
   static const String baseUrl = 'https://your-api-domain.com/api';
   static const String mediaBaseUrl = 'https://your-media-domain.com';
   ```

2. **Video Player Configuration**
   ```dart
   static const Duration videoBufferDuration = Duration(seconds: 10);
   static const int maxRetryAttempts = 3;
   ```

3. **Storage Configuration**
   ```dart
   static const int maxCacheSize = 100 * 1024 * 1024; // 100 MB
   static const Duration cacheExpiry = Duration(days: 7);
   ```

### Laravel Backend Configuration

1. **Database Configuration**
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=apex_ott
   DB_USERNAME=root
   DB_PASSWORD=
   ```

2. **Storage Configuration**
   ```env
   FILESYSTEM_DISK=s3
   AWS_ACCESS_KEY_ID=your-access-key
   AWS_SECRET_ACCESS_KEY=your-secret-key
   AWS_DEFAULT_REGION=us-east-1
   AWS_BUCKET=your-bucket-name
   ```

3. **Payment Configuration**
   ```env
   RAZORPAY_KEY_ID=your-razorpay-key
   RAZORPAY_KEY_SECRET=your-razorpay-secret
   STRIPE_KEY=your-stripe-key
   STRIPE_SECRET=your-stripe-secret
   ```

## 📱 Platform-Specific Setup

### Android Setup

1. **Add permissions** in `android/app/src/main/AndroidManifest.xml`
   ```xml
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
   <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
   <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
   ```

2. **Configure ProGuard** in `android/app/proguard-rules.pro`
   ```pro
   -keep class com.apex.ott.** { *; }
   ```

### iOS Setup

1. **Add permissions** in `ios/Runner/Info.plist`
   ```xml
   <key>NSAppTransportSecurity</key>
   <dict>
       <key>NSAllowsArbitraryLoads</key>
       <true/>
   </dict>
   ```

2. **Configure background modes**
   ```xml
   <key>UIBackgroundModes</key>
   <array>
       <string>audio</string>
   </array>
   ```

### Android TV Setup

1. **Add TV support** in `android/app/src/main/AndroidManifest.xml`
   ```xml
   <uses-feature
       android:name="android.software.leanback"
       android:required="false" />
   <uses-feature
       android:name="android.hardware.touchscreen"
       android:required="false" />
   ```

2. **Configure TV activity**
   ```xml
   <activity
       android:name=".MainActivity"
       android:exported="true"
       android:screenOrientation="landscape">
       <intent-filter>
           <action android:name="android.intent.action.MAIN" />
           <category android:name="android.intent.category.LAUNCHER" />
           <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
       </intent-filter>
   </activity>
   ```

## 🚀 Deployment

### Flutter App Deployment

1. **Android APK**
   ```bash
   flutter build apk --release
   ```

2. **Android App Bundle**
   ```bash
   flutter build appbundle --release
   ```

3. **iOS App**
   ```bash
   flutter build ios --release
   ```

### Laravel Backend Deployment

1. **Production setup**
   ```bash
   composer install --optimize-autoloader --no-dev
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

2. **Queue workers**
   ```bash
   php artisan horizon
   ```

3. **Web server configuration**
   - Nginx/Apache configuration for Laravel
   - SSL certificate setup
   - Domain configuration

## 📊 Monitoring & Analytics

### Built-in Analytics
- User engagement tracking
- Content performance metrics
- Revenue analytics
- Real-time monitoring

### Third-party Integration
- Google Analytics
- Firebase Analytics
- Custom analytics dashboard

## 🔒 Security Features

- JWT-based authentication
- API rate limiting
- Content encryption
- Secure payment processing
- User data protection (GDPR compliant)

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

## 🎯 Roadmap

- [ ] Web application
- [ ] Smart TV apps (Samsung, LG, etc.)
- [ ] Chromecast support
- [ ] AI-powered recommendations
- [ ] Live chat support
- [ ] Multi-tenant support
- [ ] White-label solution

---

**Apex OTT** - Redefining Entertainment Experience 🎬✨
