/// User profile model: regional preferences + display info.
library;

class UserProfile {
  const UserProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    this.regionCountry,
    this.regionCity,
    this.preferredLanguage = 'en',
  });

  final String id;
  final String? displayName;
  final String? avatarUrl;
  /// ISO 3166-1 alpha-2 code, e.g. "TR", "US", "DE".
  final String? regionCountry;
  final String? regionCity;
  final String preferredLanguage;

  bool get hasRegion => regionCountry != null && regionCountry!.isNotEmpty;

  UserProfile copyWith({
    String? displayName,
    String? avatarUrl,
    String? regionCountry,
    String? regionCity,
    String? preferredLanguage,
  }) =>
      UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        regionCountry: regionCountry ?? this.regionCountry,
        regionCity: regionCity ?? this.regionCity,
        preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      );

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        regionCountry: json['region_country'] as String?,
        regionCity: json['region_city'] as String?,
        preferredLanguage:
            (json['preferred_language'] as String?) ?? 'en',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'display_name': displayName,
        'avatar_url': avatarUrl,
        'region_country': regionCountry,
        'region_city': regionCity,
        'preferred_language': preferredLanguage,
        'updated_at': DateTime.now().toIso8601String(),
      };
}
