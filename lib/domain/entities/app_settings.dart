/// Domain Layer - App Settings Entity
/// 
/// User preferences and application settings.

enum MeasurementUnit {
  metric('Metric (g, ml)'),
  imperial('Imperial (oz, cups)');

  final String displayName;
  const MeasurementUnit(this.displayName);
}

enum CookModeFontSize {
  small('Small', 16.0),
  medium('Medium', 20.0),
  large('Large', 24.0),
  extraLarge('Extra Large', 28.0);

  final String displayName;
  final double size;
  const CookModeFontSize(this.displayName, this.size);
}

class AppSettings {
  final MeasurementUnit measurementUnit;
  final CookModeFontSize cookModeFontSize;
  final bool timerSoundEnabled;
  final bool keepScreenOnInCookMode;
  final bool hasCompletedOnboarding;
  final int defaultServings;

  const AppSettings({
    this.measurementUnit = MeasurementUnit.metric,
    this.cookModeFontSize = CookModeFontSize.medium,
    this.timerSoundEnabled = true,
    this.keepScreenOnInCookMode = true,
    this.hasCompletedOnboarding = false,
    this.defaultServings = 4,
  });

  AppSettings copyWith({
    MeasurementUnit? measurementUnit,
    CookModeFontSize? cookModeFontSize,
    bool? timerSoundEnabled,
    bool? keepScreenOnInCookMode,
    bool? hasCompletedOnboarding,
    int? defaultServings,
  }) {
    return AppSettings(
      measurementUnit: measurementUnit ?? this.measurementUnit,
      cookModeFontSize: cookModeFontSize ?? this.cookModeFontSize,
      timerSoundEnabled: timerSoundEnabled ?? this.timerSoundEnabled,
      keepScreenOnInCookMode: keepScreenOnInCookMode ?? this.keepScreenOnInCookMode,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      defaultServings: defaultServings ?? this.defaultServings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'measurementUnit': measurementUnit.name,
      'cookModeFontSize': cookModeFontSize.name,
      'timerSoundEnabled': timerSoundEnabled,
      'keepScreenOnInCookMode': keepScreenOnInCookMode,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'defaultServings': defaultServings,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      measurementUnit: MeasurementUnit.values.firstWhere(
        (e) => e.name == json['measurementUnit'],
        orElse: () => MeasurementUnit.metric,
      ),
      cookModeFontSize: CookModeFontSize.values.firstWhere(
        (e) => e.name == json['cookModeFontSize'],
        orElse: () => CookModeFontSize.medium,
      ),
      timerSoundEnabled: json['timerSoundEnabled'] as bool? ?? true,
      keepScreenOnInCookMode: json['keepScreenOnInCookMode'] as bool? ?? true,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      defaultServings: json['defaultServings'] as int? ?? 4,
    );
  }
}
