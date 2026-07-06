import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/draft.dart';

/// Local-only draft persistence service.
///
/// Stores drafts as a JSON array in SharedPreferences.
/// No cloud sync. No account. No upload.
///
/// All drafts remain exclusively on the device.
class DraftStorage {
  static const _storageKey = 'kleinpilot_saved_drafts';

  /// Load all saved drafts, sorted by most recently updated first.
  /// Returns an empty list on first run or if storage is corrupted.
  Future<List<Draft>> loadDrafts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((e) => Draft.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) {
          final aTime = a.updatedAt ?? a.createdAt ?? '';
          final bTime = b.updatedAt ?? b.createdAt ?? '';
          return bTime.compareTo(aTime); // newest first
        });
    } catch (_) {
      // Corrupted JSON: return empty list — never crash.
      return [];
    }
  }

  /// Save a [draft] to local storage.
  ///
  /// If a draft with the same [id] already exists, it is replaced.
  /// If [draft.id] is null, a new local UUID is generated.
  /// [updatedAt] is always set to the current timestamp.
  /// [createdAt] is preserved for existing drafts; set on first save.
  Future<void> saveDraft(Draft draft) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await loadDrafts();
    final now = DateTime.now().toUtc().toIso8601String();

    final id = draft.id ?? _generateId();
    final createdAt = draft.createdAt ?? now;

    final savedDraft = draft.copyWith(
      id: id,
      createdAt: createdAt,
      updatedAt: now,
    );

    // Remove existing draft with same id if present
    drafts.removeWhere((d) => d.id == id);
    drafts.add(savedDraft);

    await _persistList(prefs, drafts);
  }

  /// Delete the draft with the given [id].
  /// No error if the id does not exist.
  Future<void> deleteDraft(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await loadDrafts();
    drafts.removeWhere((d) => d.id == id);
    await _persistList(prefs, drafts);
  }

  /// Remove all saved drafts. Used only for tests and explicit user action.
  Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  Future<void> _persistList(SharedPreferences prefs, List<Draft> drafts) async {
    final jsonList = drafts.map((d) => d.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  String _generateId() {
    final now = DateTime.now().toUtc();
    final ms = now.microsecondsSinceEpoch;
    final rand = (ms % 1000000).toString().padLeft(6, '0');
    return 'draft_${now.millisecondsSinceEpoch}_$rand';
  }
}
