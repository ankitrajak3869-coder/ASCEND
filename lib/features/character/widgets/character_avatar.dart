import 'package:ascend/features/character/models/character_profile.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// Drawn avatar: gradient disc with the name's initial.
class CharacterAvatar extends StatelessWidget {
  const CharacterAvatar({
    super.key,
    required this.profile,
    this.radius = 28,
  });

  final CharacterProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = profile.name.isEmpty ? '?' : profile.name.characters.first;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[AppColors.primary, AppColors.primaryBright],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}