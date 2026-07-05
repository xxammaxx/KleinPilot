import 'package:flutter_test/flutter_test.dart';
import 'package:kleinpilot/models/draft.dart';
import 'package:kleinpilot/services/draft_formatter.dart';

void main() {
  group('DraftFormatter', () {
    test('formatiert vollständigen Entwurf korrekt', () {
      final draft = Draft(
        title: 'Fahrrad',
        categoryNote: 'Fahrräder & Zubehör',
        condition: 'Gebraucht',
        description: 'Ein schönes Fahrrad.',
        defects: 'Leichte Kratzer am Rahmen',
        includedItems: 'Fahrrad, Schloss, Pumpe',
        priceNote: 'VB 150€',
        handoverNote: 'Abholung in Berlin',
        locationNote: 'Berlin Mitte',
      );

      final result = DraftFormatter().format(draft);

      expect(result, contains('Titel:'));
      expect(result, contains('Fahrrad'));
      expect(result, contains('Kategorie:'));
      expect(result, contains('Fahrräder & Zubehör'));
      expect(result, contains('Zustand:'));
      expect(result, contains('Gebraucht'));
      expect(result, contains('Beschreibung:'));
      expect(result, contains('Ein schönes Fahrrad.'));
      expect(result, contains('Mängel / Defekte:'));
      expect(result, contains('Leichte Kratzer am Rahmen'));
      expect(result, contains('Lieferumfang:'));
      expect(result, contains('Fahrrad, Schloss, Pumpe'));
      expect(result, contains('Preisvorstellung:'));
      expect(result, contains('VB 150€'));
      expect(result, contains('Übergabe:'));
      expect(result, contains('Abholung in Berlin'));
      expect(result, contains('Standort:'));
      expect(result, contains('Berlin Mitte'));
      expect(result, contains('Kein automatisches Posting'));
    });

    test('lässt leere Felder aus', () {
      final draft = Draft(title: 'Nur Titel');

      final result = DraftFormatter().format(draft);

      expect(result, contains('Titel:'));
      expect(result, contains('Nur Titel'));
      expect(result, isNot(contains('Kategorie:')));
      expect(result, isNot(contains('Zustand:')));
      expect(result, isNot(contains('Beschreibung:')));
      expect(result, contains('Kein automatisches Posting'));
    });

    test('enthält immer Hinweis auf manuelle Prüfung', () {
      final draft = Draft();
      final result = DraftFormatter().format(draft);

      expect(result, contains('Kein automatisches Posting'));
      expect(result, contains('manuell zu prüfender Entwurf'));
    });

    test('formatiert leeren Entwurf ohne leere Label', () {
      final draft = Draft();
      final result = DraftFormatter().format(draft);

      // Should not contain empty labels
      expect(result, isNot(contains('Titel:')));
      expect(result, isNot(contains('Kategorie:')));
      expect(result, isNot(contains('Zustand:')));
      expect(result, isNot(contains('Beschreibung:')));
      // But must still contain the warning
      expect(result, contains('Kein automatisches Posting'));
    });

    test('trimmt Whitespace in Feldern', () {
      final draft = Draft(title: '   Trim Test   ');
      final result = DraftFormatter().format(draft);

      expect(result, contains('Titel:'));
      // Should contain the trimmed value
      expect(result, contains('Trim Test'));
    });
  });
}
