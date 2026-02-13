import 'dart:convert';

/// Represents a locally stored user profile.
class LocalProfile {
  final String displayName;
  final String? photoPath;
  final bool privacyAccepted;
  final DateTime createdAt;

  const LocalProfile({
    required this.displayName,
    this.photoPath,
    this.privacyAccepted = false,
    required this.createdAt,
  });

  /// Whether the profile has been fully completed (name + privacy accepted).
  bool get isComplete => displayName.trim().isNotEmpty && privacyAccepted;

  LocalProfile copyWith({
    String? displayName,
    String? photoPath,
    bool? privacyAccepted,
    DateTime? createdAt,
    bool clearPhoto = false,
  }) {
    return LocalProfile(
      displayName: displayName ?? this.displayName,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'photoPath': photoPath,
        'privacyAccepted': privacyAccepted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LocalProfile.fromJson(Map<String, dynamic> json) {
    return LocalProfile(
      displayName: json['displayName'] as String? ?? '',
      photoPath: json['photoPath'] as String?,
      privacyAccepted: json['privacyAccepted'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String encode() => jsonEncode(toJson());

  static LocalProfile? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return LocalProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }
}
