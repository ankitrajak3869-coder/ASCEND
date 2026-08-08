// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Ascend';

  @override
  String get tagline => 'Your Life is the Game.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonLoading => 'Loading';

  @override
  String get splashTagline => 'Your Life is the Game';

  @override
  String get splashStarting => 'Preparing your journey';

  @override
  String get bootErrorSummary => 'Could not start Ascend';

  @override
  String get bootErrorBody =>
      'We hit an unexpected error while booting. You can retry.';

  @override
  String get designSystemTitle => 'Design System';

  @override
  String get designSystemSubtitle =>
      'Phase 1 verification surface for tokens, type and surfaces.';

  @override
  String get designColors => 'Colors';

  @override
  String get designTypography => 'Typography';

  @override
  String get designSpacing => 'Spacing';

  @override
  String get designRadius => 'Radius';

  @override
  String get designCardDemoTitle => 'Quest Card';

  @override
  String get designCardDemoBody =>
      'This card shows the default surface, radius and outline used across quest and stat cards.';
}
