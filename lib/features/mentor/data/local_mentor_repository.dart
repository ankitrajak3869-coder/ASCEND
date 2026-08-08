import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/mentor/domain/mentor_domain.dart';
import 'package:ascend/features/mentor/models/mentor_entry.dart';
import 'package:ascend/features/mentor/repositories/mentor_repository.dart';

/// Secure-storage backed mentor history, trimmed to [MentorRules.maxHistory].
final class LocalMentorRepository implements MentorRepository {
  LocalMentorRepository({required this.storage});

  static const String key = 'feature.mentor.v1';

  final SecureStorageService storage;

  List<MentorEntry>? _cache;
  bool _hydrated = false;

  Future<List<MentorEntry>> _read() async {
    if (_hydrated) {
      return _cache ?? <MentorEntry>[];
    }
    _hydrated = true;
    final raw = await storage.read(key);
    if (raw == null) {
      _cache = <MentorEntry>[];
      return _cache!;
    }
    try {
      final decoded = jsonDecode(raw) as List<Object?>;
      _cache = decoded
          .cast<Map<String, Object?>>()
          .map(MentorEntry.fromJson)
          .toList();
    } on Object {
      _cache = <MentorEntry>[];
    }
    return _cache!;
  }

  Future<void> _write(List<MentorEntry> entries) async {
    _cache = entries;
    await storage.write(
      key,
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }

  @override
  Future<List<MentorEntry>> history() async {
    final sorted = List<MentorEntry>.of(await _read())
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<void> append(MentorEntry entry) async {
    final all = await _read();
    final merged = <MentorEntry>[entry, ...all];
    if (merged.length > MentorRules.maxHistory) {
      merged.removeRange(MentorRules.maxHistory, merged.length);
    }
    await _write(merged);
  }

  @override
  Future<void> clear() async {
    await _write(<MentorEntry>[]);
  }
}