// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'एसेन्ड';

  @override
  String get tagline => 'आपका जीवन ही खेल है।';

  @override
  String get commonRetry => 'फिर से';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonContinue => 'आगे बढ़ें';

  @override
  String get commonLoading => 'लोड हो रहा है';

  @override
  String get splashTagline => 'आपका जीवन ही खेल है';

  @override
  String get splashStarting => 'आपकी यात्रा तैयार हो रही है';

  @override
  String get bootErrorSummary => 'Ascend शुरू नहीं हो सका';

  @override
  String get bootErrorBody =>
      'शुरुआत में एक अप्रत्याशित त्रुटि हुई। आप दोबारा कोशिश कर सकते हैं।';

  @override
  String get designSystemTitle => 'Design System';

  @override
  String get designSystemSubtitle =>
      'Phase 1 verification surface for tokens, type and surfaces.';

  @override
  String get designColors => 'रंग';

  @override
  String get designTypography => 'टाइपोग्राफ़ी';

  @override
  String get designSpacing => 'स्पेसिंग';

  @override
  String get designRadius => 'Radius';

  @override
  String get designCardDemoTitle => 'Quest Card';

  @override
  String get designCardDemoBody =>
      'This card shows the default surface, radius and outline used across quest and stat cards.';
}
