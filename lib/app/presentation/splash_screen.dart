import 'package:ascend/app/router.dart';
import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/services/app_boot.dart';
import 'package:ascend/l10n/generated/app_localizations.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Splash: brand mark + boot gate.
///
/// Watches [appBootProvider]; routes into the app once boot resolves.
/// Failure surfaces a retry instead of a hung spinner.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(appBootProvider);
    final value = init.valueOrNull;

    final Widget body;
    if (value is AppInitFailure) {
      body = _BootError(
        error: value.error,
        onRetry: () => ref.invalidate(appBootProvider),
      );
    } else if (init.hasError) {
      body = _BootError(
        error: init.error!,
        onRetry: () => ref.invalidate(appBootProvider),
      );
    } else if (value is AppInitSuccess) {
      body = _BootSuccess(appInit: value);
    } else {
      body = const _BrandLoading();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: body,
    );
  }
}

class _BootSuccess extends ConsumerWidget {
  const _BootSuccess({required this.appInit});

  final AppInit appInit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted && appInit is AppInitSuccess) {
        context.go(context.namedLocation(Routes.design));
      }
    });

    return const _BrandLoading();
  }
}

/// Brand intro: mark + tagline. No fake progress.
class _BrandLoading extends StatelessWidget {
  const _BrandLoading();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.primary,
                  AppColors.primaryBright,
                ],
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.arrow_upward_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            strings.splashTagline,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            strings.splashStarting,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _BootError extends StatelessWidget {
  const _BootError({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    debugPrint('boot failure: $error');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_outlined,
              color: AppColors.danger,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              strings.bootErrorSummary,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              strings.bootErrorBody,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: Text(strings.commonRetry)),
          ],
        ),
      ),
    );
  }
}