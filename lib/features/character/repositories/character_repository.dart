import 'package:ascend/features/character/models/character_profile.dart';

/// Port for the persisted character profile.
abstract interface class CharacterRepository {
  Future<CharacterProfile?> load();

  Future<void> save(CharacterProfile profile);
}