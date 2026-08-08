import 'package:ascend/app/presentation/design_system_screen.dart';
import 'package:ascend/app/presentation/error_screen.dart';
import 'package:ascend/app/presentation/splash_screen.dart';
import 'package:ascend/features/achievements/presentation/achievements_screen.dart';
import 'package:ascend/features/analytics/presentation/analytics_screen.dart';
import 'package:ascend/features/boss/presentation/boss_screen.dart';
import 'package:ascend/features/character/presentation/character_screen.dart';
import 'package:ascend/features/goals/presentation/goals_screen.dart';
import 'package:ascend/features/mentor/presentation/mentor_screen.dart';
import 'package:ascend/features/mentor/providers/mentor_providers.dart';
import 'package:ascend/features/missions/presentation/missions_screen.dart';
import 'package:ascend/features/settings/presentation/settings_screen.dart';
import 'package:ascend/features/shop/presentation/shop_screen.dart';
import 'package:ascend/features/skill_tree/presentation/skill_tree_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Route names referenced via go_router's named navigation.
abstract final class Routes {
  static const String design = 'design';
  static const String character = 'character';
  static const String missions = 'missions';
  static const String goals = 'goals';
  static const String mentor = 'mentor';
  static const String boss = 'boss';
  static const String shop = 'shop';
  static const String settings = 'settings';
  static const String analytics = 'analytics';
  static const String achievements = 'achievements';
  static const String skillTree = 'skill-tree';
}

/// Application navigation graph.
final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/design',
        name: Routes.design,
        builder: (context, state) => const DesignSystemScreen(),
      ),
      GoRoute(
        path: '/character',
        name: Routes.character,
        builder: (context, state) => const CharacterScreen(),
      ),
      GoRoute(
        path: '/missions',
        name: Routes.missions,
        builder: (context, state) => const MissionsScreen(),
      ),
      GoRoute(
        path: '/goals',
        name: Routes.goals,
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '/mentor',
        name: Routes.mentor,
        builder: (context, state) => MentorScreen(
          playerName: ref.read(mentorPlayerNameProvider),
        ),
      ),
      GoRoute(
        path: '/boss',
        name: Routes.boss,
        builder: (context, state) => const BossScreen(),
      ),
      GoRoute(
        path: '/shop',
        name: Routes.shop,
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: Routes.analytics,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: '/achievements',
        name: Routes.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: '/skill-tree',
        name: Routes.skillTree,
        builder: (context, state) => const SkillTreeScreen(),
      ),
    ],
    errorBuilder: (context, state) => AppErrorScreen(
      message: state.error.toString(),
    ),
  ),
);