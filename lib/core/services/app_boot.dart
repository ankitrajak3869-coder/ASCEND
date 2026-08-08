import 'package:ascend/core/config/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Sealed result of the application boot sequence.
@immutable
sealed class AppInit {
  const AppInit();
}

final class AppInitSuccess extends AppInit {
  const AppInitSuccess({
    required this.flavor,
    required this.useEmulator,
    required this.firebase,
  });

  final AppFlavor flavor;
  final bool useEmulator;
  final FirebaseApp firebase;
}

final class AppInitFailure extends AppInit {
  const AppInitFailure(this.error);

  final Object error;
}

abstract final class AppBoot {
  static Future<AppInit> init() async {
    final flavor = AppConfig.flavor;
    try {
      final app = AppConfig.firebaseOptions == null
          ? await Firebase.initializeApp()
          : await Firebase.initializeApp(options: AppConfig.firebaseOptions);
      return AppInitSuccess(
        flavor: flavor,
        useEmulator: AppConfig.useEmulator,
        firebase: app,
      );
    } on Object catch (error) {
      return AppInitFailure(error);
    }
  }
}