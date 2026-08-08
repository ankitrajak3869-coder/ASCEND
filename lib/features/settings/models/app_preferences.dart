import 'package:ascend/features/settings/domain/settings_domain.dart';
import 'package:flutter/foundation.dart';

/// Immutable application preferences.
@immutable
final class AppPreferences {
  const AppPreferences({
    required this.theme,
    required this.reduceMotion,
    required this.notificationsEnabled,
    required this.analyticsEnabled,
  });

  /// Defaults before the player touches anything.
  factory AppPreferences.defaults() => const AppPreferences(
    theme: SettingsDefaults.theme,
    reduceMotion: SettingsDefaults.reduceMotion,
    notificationsEnabled: SettingsDefaults.notificationsEnabled,
    analyticsEnabled: SettingsDefaults.analyticsEnabled,
  );

  factory AppPreferences.fromJson(Map<String, Object?> json) => AppPreferences(
    theme: themeFromName(json['theme']),
    reduceMotion: json['reduceMotion'] as bool? ??
        SettingsDefaults.reduceMotion,
    notificationsEnabled: json['notificationsEnabled'] as bool? ??
        SettingsDefaults.notificationsEnabled,
    analyticsEnabled: json['analyticsEnabled'] as bool? ??
        SettingsDefaults.analyticsEnabled,
  );

  final ThemePreference theme;
  final bool reduceMotion;
  final bool notificationsEnabled;
  final bool analyticsEnabled;

  AppPreferences copyWith({
    ThemePreference? theme,
    bool? reduceMotion,
    bool? notificationsEnabled,
    bool? analyticsEnabled,
  }) {
    return AppPreferences(
      theme: theme ?? this.theme,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'theme': theme.name,
    'reduceMotion': reduceMotion,
    'notificationsEnabled': notificationsEnabled,
    'analyticsEnabled': analyticsEnabled,
  };

  @override
  String toString() => 'AppPreferences(theme: ${theme.name})';
}