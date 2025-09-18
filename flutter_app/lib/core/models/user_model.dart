import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? dateOfBirth;
  final String? gender;
  final List<String> preferredLanguages;
  final List<String> favoriteGenres;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserSubscription? subscription;
  final UserPreferences preferences;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.dateOfBirth,
    this.gender,
    required this.preferredLanguages,
    required this.favoriteGenres,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    required this.updatedAt,
    this.subscription,
    required this.preferences,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? dateOfBirth,
    String? gender,
    List<String>? preferredLanguages,
    List<String>? favoriteGenres,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSubscription? subscription,
    UserPreferences? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subscription: subscription ?? this.subscription,
      preferences: preferences ?? this.preferences,
    );
  }
}

@JsonSerializable()
class UserSubscription {
  final int id;
  final String planName;
  final String planType;
  final double price;
  final String currency;
  final int durationDays;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> features;
  final String? paymentMethod;
  final String? transactionId;

  const UserSubscription({
    required this.id,
    required this.planName,
    required this.planType,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.features,
    this.paymentMethod,
    this.transactionId,
  });

  factory UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);
  Map<String, dynamic> toJson() => _$UserSubscriptionToJson(this);

  bool get isExpired => DateTime.now().isAfter(endDate);
  bool get isExpiringSoon => DateTime.now().add(const Duration(days: 3)).isAfter(endDate);
}

@JsonSerializable()
class UserPreferences {
  final String defaultLanguage;
  final String defaultQuality;
  final bool autoPlay;
  final bool downloadOnWifi;
  final bool notificationsEnabled;
  final bool parentalControlEnabled;
  final String? parentalControlPin;
  final List<String> blockedContent;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    required this.defaultLanguage,
    required this.defaultQuality,
    required this.autoPlay,
    required this.downloadOnWifi,
    required this.notificationsEnabled,
    required this.parentalControlEnabled,
    this.parentalControlPin,
    required this.blockedContent,
    required this.customSettings,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) => _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);

  UserPreferences copyWith({
    String? defaultLanguage,
    String? defaultQuality,
    bool? autoPlay,
    bool? downloadOnWifi,
    bool? notificationsEnabled,
    bool? parentalControlEnabled,
    String? parentalControlPin,
    List<String>? blockedContent,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      defaultQuality: defaultQuality ?? this.defaultQuality,
      autoPlay: autoPlay ?? this.autoPlay,
      downloadOnWifi: downloadOnWifi ?? this.downloadOnWifi,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      parentalControlEnabled: parentalControlEnabled ?? this.parentalControlEnabled,
      parentalControlPin: parentalControlPin ?? this.parentalControlPin,
      blockedContent: blockedContent ?? this.blockedContent,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}
