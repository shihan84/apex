import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models/user_model.dart';
import '../models/content_model.dart';
import '../constants/app_constants.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: AppConstants.baseUrl)
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication Endpoints
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<AuthResponse> register(@Body() RegisterRequest request);

  @POST('/auth/refresh')
  Future<AuthResponse> refreshToken(@Body() RefreshTokenRequest request);

  @POST('/auth/logout')
  Future<void> logout();

  @POST('/auth/forgot-password')
  Future<void> forgotPassword(@Body() ForgotPasswordRequest request);

  @POST('/auth/reset-password')
  Future<void> resetPassword(@Body() ResetPasswordRequest request);

  @POST('/auth/verify-email')
  Future<void> verifyEmail(@Body() VerifyEmailRequest request);

  @POST('/auth/verify-phone')
  Future<void> verifyPhone(@Body() VerifyPhoneRequest request);

  // User Profile Endpoints
  @GET('/user/profile')
  Future<UserModel> getProfile();

  @PUT('/user/profile')
  Future<UserModel> updateProfile(@Body() UpdateProfileRequest request);

  @POST('/user/upload-avatar')
  Future<String> uploadAvatar(@Part() File avatar);

  @GET('/user/preferences')
  Future<UserPreferences> getPreferences();

  @PUT('/user/preferences')
  Future<UserPreferences> updatePreferences(@Body() UserPreferences preferences);

  // Content Endpoints
  @GET('/content/trending')
  Future<ContentListResponse> getTrendingContent({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
    @Query('category') String? category,
    @Query('language') String? language,
    @Query('genre') String? genre,
  });

  @GET('/content/featured')
  Future<ContentListResponse> getFeaturedContent({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
    @Query('category') String? category,
  });

  @GET('/content/new')
  Future<ContentListResponse> getNewContent({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
    @Query('category') String? category,
  });

  @GET('/content/search')
  Future<ContentListResponse> searchContent({
    @Query('q') required String query,
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
    @Query('category') String? category,
    @Query('language') String? language,
    @Query('genre') String? genre,
  });

  @GET('/content/{id}')
  Future<ContentModel> getContent(@Path('id') int id);

  @GET('/content/{id}/related')
  Future<ContentListResponse> getRelatedContent(
    @Path('id') int id, {
    @Query('limit') int limit = 10,
  });

  @GET('/content/{id}/cast')
  Future<List<ContentCast>> getContentCast(@Path('id') int id);

  @GET('/content/{id}/crew')
  Future<List<ContentCrew>> getContentCrew(@Path('id') int id);

  @GET('/content/{id}/videos')
  Future<List<ContentVideo>> getContentVideos(@Path('id') int id);

  @GET('/content/{id}/audios')
  Future<List<ContentAudio>> getContentAudios(@Path('id') int id);

  @GET('/content/{id}/subtitles')
  Future<List<ContentSubtitle>> getContentSubtitles(@Path('id') int id);

  // Live TV Endpoints
  @GET('/live/channels')
  Future<LiveChannelListResponse> getLiveChannels({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('category') String? category,
    @Query('language') String? language,
  });

  @GET('/live/channels/{id}')
  Future<LiveChannel> getLiveChannel(@Path('id') int id);

  @GET('/live/channels/{id}/epg')
  Future<List<EPGProgram>> getChannelEPG(
    @Path('id') int id, {
    @Query('date') String? date,
  });

  // Music Endpoints
  @GET('/music/playlists')
  Future<PlaylistListResponse> getPlaylists({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('category') String? category,
    @Query('language') String? language,
  });

  @GET('/music/playlists/{id}')
  Future<Playlist> getPlaylist(@Path('id') int id);

  @GET('/music/artists')
  Future<ArtistListResponse> getArtists({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('language') String? language,
  });

  @GET('/music/artists/{id}')
  Future<Artist> getArtist(@Path('id') int id);

  // Shorts/Reels Endpoints
  @GET('/shorts/feed')
  Future<ShortsListResponse> getShortsFeed({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('category') String? category,
    @Query('language') String? language,
  });

  @GET('/shorts/{id}')
  Future<ContentModel> getShort(@Path('id') int id);

  // User Interactions
  @POST('/user/favorites')
  Future<void> addToFavorites(@Body() FavoriteRequest request);

  @DELETE('/user/favorites/{id}')
  Future<void> removeFromFavorites(@Path('id') int id);

  @GET('/user/favorites')
  Future<ContentListResponse> getFavorites({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
  });

  @POST('/user/watchlist')
  Future<void> addToWatchlist(@Body() WatchlistRequest request);

  @DELETE('/user/watchlist/{id}')
  Future<void> removeFromWatchlist(@Path('id') int id);

  @GET('/user/watchlist')
  Future<ContentListResponse> getWatchlist({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
  });

  @POST('/user/history')
  Future<void> addToHistory(@Body() HistoryRequest request);

  @GET('/user/history')
  Future<ContentListResponse> getHistory({
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
    @Query('type') String? type,
  });

  @DELETE('/user/history')
  Future<void> clearHistory();

  @POST('/user/rating')
  Future<void> rateContent(@Body() RatingRequest request);

  @POST('/user/comment')
  Future<void> commentContent(@Body() CommentRequest request);

  @GET('/content/{id}/comments')
  Future<CommentListResponse> getContentComments(
    @Path('id') int id, {
    @Query('page') int page = 1,
    @Query('limit') int limit = 20,
  });

  // Subscription Endpoints
  @GET('/subscription/plans')
  Future<List<SubscriptionPlan>> getSubscriptionPlans();

  @POST('/subscription/subscribe')
  Future<SubscriptionResponse> subscribe(@Body() SubscribeRequest request);

  @GET('/subscription/current')
  Future<UserSubscription> getCurrentSubscription();

  @POST('/subscription/cancel')
  Future<void> cancelSubscription();

  @POST('/subscription/renew')
  Future<SubscriptionResponse> renewSubscription(@Body() RenewRequest request);

  // Payment Endpoints
  @POST('/payment/create-order')
  Future<PaymentOrder> createPaymentOrder(@Body() CreateOrderRequest request);

  @POST('/payment/verify')
  Future<PaymentVerification> verifyPayment(@Body() VerifyPaymentRequest request);

  @GET('/payment/methods')
  Future<List<PaymentMethod>> getPaymentMethods();

  // Categories and Genres
  @GET('/categories')
  Future<List<Category>> getCategories();

  @GET('/genres')
  Future<List<Genre>> getGenres();

  @GET('/languages')
  Future<List<Language>> getLanguages();

  // Analytics
  @POST('/analytics/view')
  Future<void> trackView(@Body() ViewTrackingRequest request);

  @POST('/analytics/search')
  Future<void> trackSearch(@Body() SearchTrackingRequest request);

  @POST('/analytics/engagement')
  Future<void> trackEngagement(@Body() EngagementTrackingRequest request);
}

// Request/Response Models
@JsonSerializable()
class AuthResponse {
  final String token;
  final String refreshToken;
  final UserModel user;
  final DateTime expiresAt;

  const AuthResponse({
    required this.token,
    required this.refreshToken,
    required this.user,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}

@JsonSerializable()
class LoginRequest {
  final String email;
  final String password;
  final String? deviceId;
  final String? deviceType;

  const LoginRequest({
    required this.email,
    required this.password,
    this.deviceId,
    this.deviceType,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final List<String> preferredLanguages;
  final List<String> favoriteGenres;
  final String? deviceId;
  final String? deviceType;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.dateOfBirth,
    this.gender,
    required this.preferredLanguages,
    required this.favoriteGenres,
    this.deviceId,
    this.deviceType,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

@JsonSerializable()
class ForgotPasswordRequest {
  final String email;

  const ForgotPasswordRequest({required this.email});

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) => _$ForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
}

@JsonSerializable()
class ResetPasswordRequest {
  final String token;
  final String password;

  const ResetPasswordRequest({
    required this.token,
    required this.password,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable()
class VerifyEmailRequest {
  final String token;

  const VerifyEmailRequest({required this.token});

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable()
class VerifyPhoneRequest {
  final String phone;
  final String code;

  const VerifyPhoneRequest({
    required this.phone,
    required this.code,
  });

  factory VerifyPhoneRequest.fromJson(Map<String, dynamic> json) => _$VerifyPhoneRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyPhoneRequestToJson(this);
}

@JsonSerializable()
class UpdateProfileRequest {
  final String? name;
  final String? phone;
  final String? dateOfBirth;
  final String? gender;
  final List<String>? preferredLanguages;
  final List<String>? favoriteGenres;

  const UpdateProfileRequest({
    this.name,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.preferredLanguages,
    this.favoriteGenres,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

@JsonSerializable()
class ContentListResponse {
  final List<ContentModel> data;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  const ContentListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ContentListResponse.fromJson(Map<String, dynamic> json) => _$ContentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ContentListResponseToJson(this);
}

@JsonSerializable()
class FavoriteRequest {
  final int contentId;
  final String type;

  const FavoriteRequest({
    required this.contentId,
    required this.type,
  });

  factory FavoriteRequest.fromJson(Map<String, dynamic> json) => _$FavoriteRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FavoriteRequestToJson(this);
}

@JsonSerializable()
class WatchlistRequest {
  final int contentId;
  final String type;

  const WatchlistRequest({
    required this.contentId,
    required this.type,
  });

  factory WatchlistRequest.fromJson(Map<String, dynamic> json) => _$WatchlistRequestFromJson(json);
  Map<String, dynamic> toJson() => _$WatchlistRequestToJson(this);
}

@JsonSerializable()
class HistoryRequest {
  final int contentId;
  final String type;
  final int? duration; // in seconds
  final int? position; // in seconds

  const HistoryRequest({
    required this.contentId,
    required this.type,
    this.duration,
    this.position,
  });

  factory HistoryRequest.fromJson(Map<String, dynamic> json) => _$HistoryRequestFromJson(json);
  Map<String, dynamic> toJson() => _$HistoryRequestToJson(this);
}

@JsonSerializable()
class RatingRequest {
  final int contentId;
  final int rating; // 1-5 stars
  final String? review;

  const RatingRequest({
    required this.contentId,
    required this.rating,
    this.review,
  });

  factory RatingRequest.fromJson(Map<String, dynamic> json) => _$RatingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RatingRequestToJson(this);
}

@JsonSerializable()
class CommentRequest {
  final int contentId;
  final String comment;
  final int? parentId;

  const CommentRequest({
    required this.contentId,
    required this.comment,
    this.parentId,
  });

  factory CommentRequest.fromJson(Map<String, dynamic> json) => _$CommentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CommentRequestToJson(this);
}

@JsonSerializable()
class CommentListResponse {
  final List<Comment> data;
  final int total;
  final int page;
  final int limit;

  const CommentListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory CommentListResponse.fromJson(Map<String, dynamic> json) => _$CommentListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CommentListResponseToJson(this);
}

@JsonSerializable()
class Comment {
  final int id;
  final String comment;
  final UserModel user;
  final int? parentId;
  final List<Comment> replies;
  final int likes;
  final bool isLiked;
  final DateTime createdAt;

  const Comment({
    required this.id,
    required this.comment,
    required this.user,
    this.parentId,
    required this.replies,
    required this.likes,
    required this.isLiked,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
  Map<String, dynamic> toJson() => _$CommentToJson(this);
}

@JsonSerializable()
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final int durationDays;
  final List<String> features;
  final bool isPopular;
  final Map<String, dynamic> metadata;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.features,
    required this.isPopular,
    required this.metadata,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => _$SubscriptionPlanFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionPlanToJson(this);
}

@JsonSerializable()
class SubscriptionResponse {
  final UserSubscription subscription;
  final String? paymentUrl;
  final String? paymentId;

  const SubscriptionResponse({
    required this.subscription,
    this.paymentUrl,
    this.paymentId,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) => _$SubscriptionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SubscriptionResponseToJson(this);
}

@JsonSerializable()
class SubscribeRequest {
  final String planId;
  final String paymentMethod;
  final Map<String, dynamic> paymentData;

  const SubscribeRequest({
    required this.planId,
    required this.paymentMethod,
    required this.paymentData,
  });

  factory SubscribeRequest.fromJson(Map<String, dynamic> json) => _$SubscribeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubscribeRequestToJson(this);
}

@JsonSerializable()
class RenewRequest {
  final String paymentMethod;
  final Map<String, dynamic> paymentData;

  const RenewRequest({
    required this.paymentMethod,
    required this.paymentData,
  });

  factory RenewRequest.fromJson(Map<String, dynamic> json) => _$RenewRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RenewRequestToJson(this);
}

@JsonSerializable()
class PaymentOrder {
  final String id;
  final String status;
  final double amount;
  final String currency;
  final String? paymentUrl;
  final Map<String, dynamic> metadata;

  const PaymentOrder({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
    this.paymentUrl,
    required this.metadata,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) => _$PaymentOrderFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentOrderToJson(this);
}

@JsonSerializable()
class CreateOrderRequest {
  final String planId;
  final String paymentMethod;
  final Map<String, dynamic> paymentData;

  const CreateOrderRequest({
    required this.planId,
    required this.paymentMethod,
    required this.paymentData,
  });

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateOrderRequestToJson(this);
}

@JsonSerializable()
class PaymentVerification {
  final bool success;
  final String? message;
  final UserSubscription? subscription;

  const PaymentVerification({
    required this.success,
    this.message,
    this.subscription,
  });

  factory PaymentVerification.fromJson(Map<String, dynamic> json) => _$PaymentVerificationFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentVerificationToJson(this);
}

@JsonSerializable()
class VerifyPaymentRequest {
  final String orderId;
  final String paymentId;
  final Map<String, dynamic> paymentData;

  const VerifyPaymentRequest({
    required this.orderId,
    required this.paymentId,
    required this.paymentData,
  });

  factory VerifyPaymentRequest.fromJson(Map<String, dynamic> json) => _$VerifyPaymentRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyPaymentRequestToJson(this);
}

@JsonSerializable()
class PaymentMethod {
  final String id;
  final String name;
  final String type;
  final String? icon;
  final bool isEnabled;
  final Map<String, dynamic> metadata;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
    required this.isEnabled,
    required this.metadata,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

@JsonSerializable()
class Category {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final int order;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    required this.order,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Genre {
  final int id;
  final String name;
  final String? description;
  final String? color;
  final int order;
  final bool isActive;

  const Genre({
    required this.id,
    required this.name,
    this.description,
    this.color,
    required this.order,
    required this.isActive,
  });

  factory Genre.fromJson(Map<String, dynamic> json) => _$GenreFromJson(json);
  Map<String, dynamic> toJson() => _$GenreToJson(this);
}

@JsonSerializable()
class Language {
  final String code;
  final String name;
  final String? nativeName;
  final String? flag;
  final bool isActive;

  const Language({
    required this.code,
    required this.name,
    this.nativeName,
    this.flag,
    required this.isActive,
  });

  factory Language.fromJson(Map<String, dynamic> json) => _$LanguageFromJson(json);
  Map<String, dynamic> toJson() => _$LanguageToJson(this);
}

@JsonSerializable()
class LiveChannel {
  final int id;
  final String name;
  final String? description;
  final String? logo;
  final String? banner;
  final String streamUrl;
  final String? backupUrl;
  final String category;
  final String language;
  final String? country;
  final bool isLive;
  final bool isHd;
  final int? viewers;
  final Map<String, dynamic> metadata;

  const LiveChannel({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    this.banner,
    required this.streamUrl,
    this.backupUrl,
    required this.category,
    required this.language,
    this.country,
    required this.isLive,
    required this.isHd,
    this.viewers,
    required this.metadata,
  });

  factory LiveChannel.fromJson(Map<String, dynamic> json) => _$LiveChannelFromJson(json);
  Map<String, dynamic> toJson() => _$LiveChannelToJson(this);
}

@JsonSerializable()
class LiveChannelListResponse {
  final List<LiveChannel> data;
  final int total;
  final int page;
  final int limit;

  const LiveChannelListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory LiveChannelListResponse.fromJson(Map<String, dynamic> json) => _$LiveChannelListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LiveChannelListResponseToJson(this);
}

@JsonSerializable()
class EPGProgram {
  final int id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final String? genre;
  final String? rating;
  final Map<String, dynamic> metadata;

  const EPGProgram({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.genre,
    this.rating,
    required this.metadata,
  });

  factory EPGProgram.fromJson(Map<String, dynamic> json) => _$EPGProgramFromJson(json);
  Map<String, dynamic> toJson() => _$EPGProgramToJson(this);
}

@JsonSerializable()
class Playlist {
  final int id;
  final String name;
  final String? description;
  final String? cover;
  final String? owner;
  final int trackCount;
  final int duration; // in seconds
  final List<ContentModel> tracks;
  final Map<String, dynamic> metadata;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.cover,
    this.owner,
    required this.trackCount,
    required this.duration,
    required this.tracks,
    required this.metadata,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => _$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistToJson(this);
}

@JsonSerializable()
class PlaylistListResponse {
  final List<Playlist> data;
  final int total;
  final int page;
  final int limit;

  const PlaylistListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PlaylistListResponse.fromJson(Map<String, dynamic> json) => _$PlaylistListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PlaylistListResponseToJson(this);
}

@JsonSerializable()
class Artist {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final String? banner;
  final int trackCount;
  final int albumCount;
  final List<ContentModel> tracks;
  final List<Album> albums;
  final Map<String, dynamic> metadata;

  const Artist({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.banner,
    required this.trackCount,
    required this.albumCount,
    required this.tracks,
    required this.albums,
    required this.metadata,
  });

  factory Artist.fromJson(Map<String, dynamic> json) => _$ArtistFromJson(json);
  Map<String, dynamic> toJson() => _$ArtistToJson(this);
}

@JsonSerializable()
class Album {
  final int id;
  final String name;
  final String? description;
  final String? cover;
  final String? artist;
  final int trackCount;
  final int duration; // in seconds
  final DateTime releaseDate;
  final List<ContentModel> tracks;
  final Map<String, dynamic> metadata;

  const Album({
    required this.id,
    required this.name,
    this.description,
    this.cover,
    this.artist,
    required this.trackCount,
    required this.duration,
    required this.releaseDate,
    required this.tracks,
    required this.metadata,
  });

  factory Album.fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
  Map<String, dynamic> toJson() => _$AlbumToJson(this);
}

@JsonSerializable()
class ArtistListResponse {
  final List<Artist> data;
  final int total;
  final int page;
  final int limit;

  const ArtistListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ArtistListResponse.fromJson(Map<String, dynamic> json) => _$ArtistListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ArtistListResponseToJson(this);
}

@JsonSerializable()
class ShortsListResponse {
  final List<ContentModel> data;
  final int total;
  final int page;
  final int limit;

  const ShortsListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory ShortsListResponse.fromJson(Map<String, dynamic> json) => _$ShortsListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ShortsListResponseToJson(this);
}

@JsonSerializable()
class ViewTrackingRequest {
  final int contentId;
  final String type;
  final int duration; // in seconds
  final int position; // in seconds
  final String? quality;
  final String? language;

  const ViewTrackingRequest({
    required this.contentId,
    required this.type,
    required this.duration,
    required this.position,
    this.quality,
    this.language,
  });

  factory ViewTrackingRequest.fromJson(Map<String, dynamic> json) => _$ViewTrackingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ViewTrackingRequestToJson(this);
}

@JsonSerializable()
class SearchTrackingRequest {
  final String query;
  final String? type;
  final String? category;
  final String? language;
  final String? genre;
  final int resultCount;

  const SearchTrackingRequest({
    required this.query,
    this.type,
    this.category,
    this.language,
    this.genre,
    required this.resultCount,
  });

  factory SearchTrackingRequest.fromJson(Map<String, dynamic> json) => _$SearchTrackingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SearchTrackingRequestToJson(this);
}

@JsonSerializable()
class EngagementTrackingRequest {
  final int contentId;
  final String type;
  final String action; // like, share, comment, download, etc.
  final Map<String, dynamic> metadata;

  const EngagementTrackingRequest({
    required this.contentId,
    required this.type,
    required this.action,
    required this.metadata,
  });

  factory EngagementTrackingRequest.fromJson(Map<String, dynamic> json) => _$EngagementTrackingRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EngagementTrackingRequestToJson(this);
}
