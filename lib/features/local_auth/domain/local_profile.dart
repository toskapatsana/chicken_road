import 'dart:convert';

class LocalProfile {
  final String displayName;
  final String? photoPath;
  final DateTime? birthDate;
  final bool privacyAccepted;
  final DateTime createdAt;

  const LocalProfile({
    required this.displayName,
    this.photoPath,
    this.birthDate,
    this.privacyAccepted = false,
    required this.createdAt,
  });

  
  bool get isComplete => displayName.trim().isNotEmpty && privacyAccepted;

  LocalProfile copyWith({
    String? displayName,
    String? photoPath,
    DateTime? birthDate,
    bool? privacyAccepted,
    DateTime? createdAt,
    bool clearPhoto = false,
    bool clearBirthDate = false,
  }) {
    return LocalProfile(
      displayName: displayName ?? this.displayName,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
      privacyAccepted: privacyAccepted ?? this.privacyAccepted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'displayName': displayName,
        'photoPath': photoPath,
        'birthDate': birthDate?.toIso8601String(),
        'privacyAccepted': privacyAccepted,
        'createdAt': createdAt.toIso8601String(),
      };

  factory LocalProfile.fromJson(Map<String, dynamic> json) {
    return LocalProfile(
      displayName: json['displayName'] as String? ?? '',
      photoPath: json['photoPath'] as String?,
      birthDate: json['birthDate'] != null
          ? DateTime.tryParse(json['birthDate'] as String)
          : null,
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
