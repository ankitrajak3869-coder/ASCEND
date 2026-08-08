import 'dart:async';

import 'package:ascend/app/presentation/splash_screen.dart';
import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/services/app_boot.dart';
import 'package:ascend/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(ProviderScope scope) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: scope,
  );
}

void main() {
  testWidgets('boot failure surfaces retry UI', (tester) async {
    final scope = ProviderScope(
      overrides: [
        appBootProvider.overrideWith(
          (ref) => Future.value(
            AppInitFailure(StateError('no emulator')),
          ),
        ),
      ],
      child: const SplashScreen(),
    );

    await tester.pumpWidget(_wrap(scope));
    await tester.pumpAndSettle();

    expect(find.text('Could not start Ascend'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('loading state shows the brand mark', (tester) async {
    final pending = Completer<AppInit>();

    final scope = ProviderScope(
      overrides: [
        appBootProvider.overrideWith((ref) => pending.future),
      ],
      child: const SplashScreen(),
    );

    await tester.pumpWidget(_wrap(scope));
    await tester.pump();

    expect(find.text('Preparing your journey'), findsOneWidget);
  });
}