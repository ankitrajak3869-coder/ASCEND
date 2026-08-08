import 'package:ascend/app/di/feature_pipeline.dart';
import 'package:ascend/app/router.dart';
import 'package:ascend/l10n/generated/app_localizations.dart';
import 'package:ascend/shared/design/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ascend root: theme, localization and navigation wiring.
class AscendApp extends ConsumerWidget {
  const AscendApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    FeaturePipeline.start(ref);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Ascend',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}