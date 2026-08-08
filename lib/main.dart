import 'package:ascend/app/ascend_app.dart';
import 'package:ascend/app/di/feature_bindings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: featureBindings,
      child: const AscendApp(),
    ),
  );
}