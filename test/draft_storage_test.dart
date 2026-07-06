import 'package:flutter_test/flutter_test.dart';
import 'package:kleinpilot/models/draft.dart';
import 'package:kleinpilot/services/draft_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Draft', () {
    test('serialisiert und deserialisiert alle Felder', () {
      final original = Draft(
        id: 'test-id',
        createdAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-02T00:00:00.000Z',
        title: 'Test Titel',
        categoryNote: 'Kategorie',
        condition: 'Neu',
        description: 'Beschreibung',
        defects: 'Keine',
        includedItems: 'Alles',
        priceNote: '50 €',
        handoverNote: 'Abholung',
        locationNote: 'Berlin',
        photoPaths: ['/tmp/a.jpg', '/tmp/b.png'],
      );

      final json = original.toJson();
      final restored = Draft.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
      expect(restored.title, original.title);
      expect(restored.categoryNote, original.categoryNote);
      expect(restored.condition, original.condition);
      expect(restored.description, original.description);
      expect(restored.defects, original.defects);
      expect(restored.includedItems, original.includedItems);
      expect(restored.priceNote, original.priceNote);
      expect(restored.handoverNote, original.handoverNote);
      expect(restored.locationNote, original.locationNote);
      expect(restored.photoPaths, original.photoPaths);
    });

    test('photoPaths bleiben beim Serialisieren erhalten', () {
      final draft = Draft(
        title: 'Test',
        photoPaths: ['/tmp/p1.jpg', '/tmp/p2.jpg', '/tmp/p3.png'],
      );
      final json = draft.toJson();
      expect(json['photoPaths'], isA<List>());
      expect((json['photoPaths'] as List).length, 3);

      final restored = Draft.fromJson(json);
      expect(restored.photoPaths.length, 3);
      expect(restored.photoPaths, [
        '/tmp/p1.jpg',
        '/tmp/p2.jpg',
        '/tmp/p3.png',
      ]);
    });

    test('neuer Draft ohne id hat keine Persistenz-Felder im JSON', () {
      final draft = Draft(title: 'Test');
      final json = draft.toJson();
      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('createdAt'), isFalse);
      expect(json.containsKey('updatedAt'), isFalse);
    });

    test('Draft ohne id kann aus JSON ohne id wiederhergestellt werden', () {
      final json = {
        'title': 'Test',
        'condition': 'Gebraucht',
        'photoPaths': <String>[],
      };
      final draft = Draft.fromJson(json);
      expect(draft.id, isNull);
      expect(draft.title, 'Test');
      expect(draft.condition, 'Gebraucht');
    });

    test('copyWith erzeugt korrekte Kopie', () {
      final original = Draft(
        id: 'test-id',
        title: 'Original',
        photoPaths: ['/tmp/a.jpg'],
      );
      final copy = original.copyWith(title: 'Copy');
      expect(copy.id, 'test-id');
      expect(copy.title, 'Copy');
      expect(copy.photoPaths, ['/tmp/a.jpg']);
      // Original unchanged
      expect(original.title, 'Original');
    });
  });

  group('DraftStorage', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('loadDrafts gibt leere Liste zurück bei Erstnutzung', () async {
      final storage = DraftStorage();
      final drafts = await storage.loadDrafts();
      expect(drafts, isEmpty);
    });

    test('saveDraft speichert einen Draft und loadDrafts lädt ihn', () async {
      final storage = DraftStorage();
      final draft = Draft(title: 'Mein Draft', condition: 'Neu');

      await storage.saveDraft(draft);

      final loaded = await storage.loadDrafts();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'Mein Draft');
      expect(loaded.first.condition, 'Neu');
      expect(loaded.first.id, isNotNull);
      expect(loaded.first.createdAt, isNotNull);
      expect(loaded.first.updatedAt, isNotNull);
    });

    test('saveDraft ersetzt Draft mit gleicher id', () async {
      final storage = DraftStorage();

      // Save initial
      final draft = Draft(title: 'V1');
      await storage.saveDraft(draft);
      var loaded = await storage.loadDrafts();
      expect(loaded.length, 1);
      final id = loaded.first.id!;

      // Save update with same id
      final updated = loaded.first.copyWith(title: 'V2');
      await storage.saveDraft(updated);
      loaded = await storage.loadDrafts();
      expect(loaded.length, 1);
      expect(loaded.first.title, 'V2');
      expect(loaded.first.id, id);
    });

    test('deleteDraft entfernt Draft', () async {
      final storage = DraftStorage();

      final draft = Draft(title: 'Zum Löschen');
      await storage.saveDraft(draft);
      var loaded = await storage.loadDrafts();
      expect(loaded.length, 1);
      final id = loaded.first.id!;

      await storage.deleteDraft(id);
      loaded = await storage.loadDrafts();
      expect(loaded.isEmpty, isTrue);
    });

    test('deleteDraft wirft keinen Fehler bei unbekannter id', () async {
      final storage = DraftStorage();
      // Should not throw
      await storage.deleteDraft('non-existent-id');
      final loaded = await storage.loadDrafts();
      expect(loaded.isEmpty, isTrue);
    });

    test('clearAllDrafts entfernt alle Entwürfe', () async {
      final storage = DraftStorage();

      await storage.saveDraft(Draft(title: 'D1'));
      await storage.saveDraft(Draft(title: 'D2'));
      var loaded = await storage.loadDrafts();
      expect(loaded.length, 2);

      await storage.clearAllDrafts();
      loaded = await storage.loadDrafts();
      expect(loaded.isEmpty, isTrue);
    });

    test('kaputtes JSON crasht nicht', () async {
      SharedPreferences.setMockInitialValues({
        'kleinpilot_saved_drafts': 'NOT VALID JSON {{{',
      });
      final storage = DraftStorage();
      final drafts = await storage.loadDrafts();
      expect(drafts, isEmpty);
    });

    test('loadDrafts sortiert nach updatedAt (neueste zuerst)', () async {
      final storage = DraftStorage();

      final older = Draft(
        id: 'older',
        title: 'Älter',
        createdAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-01T00:00:00.000Z',
      );
      final newer = Draft(
        id: 'newer',
        title: 'Neuer',
        createdAt: '2026-01-01T00:00:00.000Z',
        updatedAt: '2026-01-02T00:00:00.000Z',
      );

      // We bypass saveDraft's timestamp update by directly persisting
      final prefs = await SharedPreferences.getInstance();
      final jsonString = '[${_toJsonString(older)},${_toJsonString(newer)}]';
      await prefs.setString('kleinpilot_saved_drafts', jsonString);

      final loaded = await storage.loadDrafts();
      expect(loaded.length, 2);
      expect(loaded.first.title, 'Neuer');
      expect(loaded.last.title, 'Älter');
    });

    test('saveDraft bewahrt createdAt beim erneuten Speichern', () async {
      final storage = DraftStorage();

      final draft = Draft(title: 'Original');
      await storage.saveDraft(draft);
      var loaded = await storage.loadDrafts();
      final originalCreatedAt = loaded.first.createdAt!;

      // Update and resave
      final updated = loaded.first.copyWith(title: 'Updated');
      await storage.saveDraft(updated);
      loaded = await storage.loadDrafts();

      expect(loaded.first.createdAt, originalCreatedAt);
      expect(loaded.first.title, 'Updated');
      expect(loaded.first.updatedAt, isNot(originalCreatedAt));
    });

    test('mehrere Drafts können gespeichert und geladen werden', () async {
      final storage = DraftStorage();

      await storage.saveDraft(Draft(title: 'D1'));
      await storage.saveDraft(Draft(title: 'D2'));
      await storage.saveDraft(Draft(title: 'D3'));

      final loaded = await storage.loadDrafts();
      expect(loaded.length, 3);
    });

    test('saveDraft mit photoPaths speichert und lädt sie korrekt', () async {
      final storage = DraftStorage();

      final draft = Draft(
        title: 'Mit Fotos',
        photoPaths: ['/tmp/p1.jpg', '/tmp/p2.png'],
      );
      await storage.saveDraft(draft);

      final loaded = await storage.loadDrafts();
      expect(loaded.first.photoPaths.length, 2);
      expect(loaded.first.photoPaths, ['/tmp/p1.jpg', '/tmp/p2.png']);
    });
  });
}

String _toJsonString(Draft draft) {
  // Small helper to escape for inline JSON without importing dart:convert again
  final buffer = StringBuffer();
  buffer.write('{');
  buffer.write(
    '"id":"${draft.id}","title":"${draft.title}","createdAt":"${draft.createdAt}","updatedAt":"${draft.updatedAt}"',
  );
  // Include minimal serialization with default values for missing fields
  buffer.write(
    ',"categoryNote":"${draft.categoryNote}","condition":"${draft.condition}",'
    '"description":"${draft.description}","defects":"${draft.defects}",'
    '"includedItems":"${draft.includedItems}","priceNote":"${draft.priceNote}",'
    '"handoverNote":"${draft.handoverNote}","locationNote":"${draft.locationNote}",'
    '"photoPaths":[]',
  );
  buffer.write('}');
  return buffer.toString();
}
