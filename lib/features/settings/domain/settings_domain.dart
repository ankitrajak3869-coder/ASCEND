/// Settings domain: preference kinds, defaults, validation.
library;

/// Which visual theme the app presents.
enum ThemePreference { system, light, dark }

/// Defaults for every preference; used when nothing is stored.
abstract final class SettingsDefaults {
  static const ThemePreference theme = ThemePreference.system;
  static const bool reduceMotion = false;
  static const bool notificationsEnabled = true;
  static const bool analyticsEnabled = true;
}

/// Parses a stored theme name; unknown values fall back to system.
ThemePreference themeFromName(Object? name) {
  for (final preference in ThemePreference.values) {
    if (preference.name == name) {
      return preference;
    }
  }
  return SettingsDefaults.theme;
}