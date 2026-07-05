import 'package:flutter_test/flutter_test.dart';
import 'package:kleinpilot/models/draft.dart';
import 'package:kleinpilot/services/draft_formatter.dart';

void main() {
  group('DraftFormatter', () {
    test('formatiert vollständigen Entwurf mit allen Feldern korrekt', () {
      final draft = Draft(
        title: 'Fahrrad',
        categoryNote: 'Fahrräder & Zubehör',
        condition: 'Gebraucht',
        description: 'Ein schönes Fahrrad mit Zubehör.',
        defects: 'Leichte Kratzer am Rahmen',
        includedItems: 'Fahrrad, Schloss, Pumpe',
        priceNote: 'VB 150€',
        handoverNote: 'Abholung in Berlin',
        locationNote: 'Berlin Mitte',
        photoPaths: ['/tmp/photo1.jpg', '/tmp/photo2.png'],
      );

      final result = DraftFormatter().format(draft);

      // Title as heading (NO "Titel:" prefix)
      expect(result, contains('Fahrrad'));
      expect(result, isNot(contains('Titel:')));

      // Description as natural intro (NO "Beschreibung:" prefix)
      expect(result, contains('Ein schönes Fahrrad mit Zubehör.'));
      expect(result, isNot(contains('Beschreibung:')));

      // Section headers for present fields
      expect(result, contains('Zustand:'));
      expect(result, contains('Gebraucht'));
      expect(result, contains('Mängel / Hinweise:'));
      expect(result, contains('Leichte Kratzer am Rahmen'));
      expect(result, contains('Lieferumfang:'));
      expect(result, contains('Fahrrad, Schloss, Pumpe'));
      expect(result, contains('Preisvorstellung:'));
      expect(result, contains('VB 150€'));
      expect(result, contains('Übergabe:'));
      expect(result, contains('Abholung in Berlin'));
      expect(result, contains('Standort:'));
      expect(result, contains('Berlin Mitte'));

      // Photo section with proper plural
      expect(result, contains('Fotos:'));
      expect(result, contains('2 Fotos lokal angehängt'));
      expect(result, contains('Bitte vor dem Einstellen manuell prüfen'));

      // Manual review always present
      expect(result, contains('Kein automatisches Posting'));
      expect(result, contains('manuell zu prüfender Entwurf'));
    });

    test('Titel als Überschrift — ohne "Titel:"-Präfix', () {
      final draft = Draft(title: 'Sony TV Mainboard Ersatzteil');
      final result = DraftFormatter().format(draft);

      expect(result.startsWith('Sony TV Mainboard Ersatzteil'), isTrue);
      expect(result, isNot(contains('Titel:')));
    });

    test('Beschreibung als natürlicher Satz — ohne "Beschreibung:"-Präfix', () {
      final draft = Draft(
        title: 'Lampe',
        description: 'Schöne Stehlampe, kaum genutzt.',
      );
      final result = DraftFormatter().format(draft);

      expect(result, contains('Schöne Stehlampe, kaum genutzt.'));
      expect(result, isNot(contains('Beschreibung:')));
    });

    test('lässt leere optionale Felder vollständig aus', () {
      final draft = Draft(title: 'Nur Titel');

      final result = DraftFormatter().format(draft);

      expect(result, contains('Nur Titel'));
      expect(result, isNot(contains('Zustand:')));
      expect(result, isNot(contains('Mängel / Hinweise:')));
      expect(result, isNot(contains('Lieferumfang:')));
      expect(result, isNot(contains('Fotos:')));
      expect(result, isNot(contains('Preisvorstellung:')));
      expect(result, isNot(contains('Übergabe:')));
      expect(result, isNot(contains('Standort:')));
      // Manual review still present
      expect(result, contains('Kein automatisches Posting'));
    });

    test(
      'enthält immer Hinweis auf manuelle Prüfung — auch bei leerem Entwurf',
      () {
        final draft = Draft();
        final result = DraftFormatter().format(draft);

        expect(result, contains('Kein automatisches Posting'));
        expect(result, contains('manuell zu prüfender Entwurf'));
        expect(result, isNot(contains('Titel:')));
      },
    );

    test('trimmt Whitespace in Feldern', () {
      final draft = Draft(title: '   Trim Test   ');
      final result = DraftFormatter().format(draft);

      expect(result.startsWith('Trim Test'), isTrue);
    });

    test('leerer/Whitespace-only-Titel erzeugt keinen Überschriftenblock', () {
      final draft = Draft(title: '   ');
      final result = DraftFormatter().format(draft);

      // Should start directly with the review notice
      expect(result.startsWith('Hinweis:'), isTrue);
    });

    group('Photo Attachments', () {
      test('zeigt Foto-Anzahl und Prüfhinweis an, wenn Fotos vorhanden', () {
        final draft = Draft(
          title: 'Test',
          photoPaths: ['/tmp/photo1.jpg', '/tmp/photo2.png'],
        );
        final result = DraftFormatter().format(draft);

        expect(result, contains('Fotos:'));
        expect(result, contains('2 Fotos lokal angehängt'));
        expect(result, contains('Bitte vor dem Einstellen manuell prüfen'));
      });

      test('zeigt keine Foto-Info, wenn keine Fotos vorhanden', () {
        final draft = Draft(title: 'Test');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('Fotos:')));
        expect(result, isNot(contains('lokal angehängt')));
      });

      test('formatiert Einzelfoto mit korrektem Singular', () {
        final draft = Draft(title: 'Test', photoPaths: ['/tmp/photo.jpg']);
        final result = DraftFormatter().format(draft);

        expect(result, contains('1 Foto lokal angehängt'));
        expect(result, isNot(contains('Foto(s)')));
        expect(result, isNot(contains('Fotos lokal')));
      });

      test('formatiert mehrere Fotos mit korrektem Plural', () {
        final draft = Draft(
          title: 'Test',
          photoPaths: ['/a.jpg', '/b.jpg', '/c.jpg'],
        );
        final result = DraftFormatter().format(draft);

        expect(result, contains('3 Fotos lokal angehängt'));
        expect(result, isNot(contains('Foto(s)')));
      });
    });

    group('Preisnotiz', () {
      test('Preisnotiz wird unverändert übernommen', () {
        final draft = Draft(title: 'Test', priceNote: '25 € VB');
        final result = DraftFormatter().format(draft);

        expect(result, contains('Preisvorstellung:'));
        expect(result, contains('25 € VB'));
      });

      test('leere Preisnotiz wird ausgelassen', () {
        final draft = Draft(title: 'Test', priceNote: '');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('Preisvorstellung:')));
      });

      test('Preisnotiz mit nur Whitespace wird ausgelassen', () {
        final draft = Draft(title: 'Test', priceNote: '   ');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('Preisvorstellung:')));
      });
    });

    group('Mängel / Bastlerware', () {
      test('Mängeltext wird klar, aber nicht übertrieben formuliert', () {
        final draft = Draft(
          title: 'Defektes Gerät',
          defects: 'Ungetestet, daher Verkauf ausdrücklich als Bastlerware.',
        );
        final result = DraftFormatter().format(draft);

        expect(result, contains('Mängel / Hinweise:'));
        expect(result, contains('Ungetestet'));
        expect(result, contains('Bastlerware'));
      });

      test('fehlende Mängel werden ausgelassen', () {
        final draft = Draft(title: 'Test');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('Mängel / Hinweise:')));
      });
    });

    group('Übergabe / Handover', () {
      test('Übergabeinfo wird korrekt dargestellt', () {
        final draft = Draft(
          title: 'Test',
          handoverNote: 'Abholung oder Versand nach Absprache.',
        );
        final result = DraftFormatter().format(draft);

        expect(result, contains('Übergabe:'));
        expect(result, contains('Abholung oder Versand nach Absprache.'));
      });

      test('fehlende Übergabeinfo wird ausgelassen', () {
        final draft = Draft(title: 'Test');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('Übergabe:')));
      });
    });

    group('Standort', () {
      test('Standort wird nur angezeigt, wenn vorhanden', () {
        final draft = Draft(title: 'Test', locationNote: 'Berlin Mitte');
        final result = DraftFormatter().format(draft);

        expect(result, contains('Standort:'));
        expect(result, contains('Berlin Mitte'));
      });

      test('fehlender Standort wird ausgelassen', () {
        final draft = Draft(title: 'Test');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('Standort:')));
      });
    });

    group('Safety: Keine Automation/Upload/LLM im Output', () {
      test('Kein Upload-Text im Entwurf', () {
        final draft = Draft(title: 'Test', priceNote: '50€');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('hochladen')));
        expect(result, isNot(contains('upload')));
        expect(result, isNot(contains('automatisch posten')));
        expect(result, isNot(contains('Login')));
        expect(result, isNot(contains('Scraping')));
      });

      test('Kein KI-/LLM-Text im Entwurf', () {
        final draft = Draft(title: 'Test');
        final result = DraftFormatter().format(draft);

        expect(result, isNot(contains('KI')));
        expect(result, isNot(contains('generiert')));
        expect(result, isNot(contains('LLM')));
        expect(result, isNot(contains('OpenAI')));
        expect(result, isNot(contains('Cloud')));
      });
    });

    group('Golden-Style Scenarios', () {
      test('Ersatzteil/Bastler-Beispiel', () {
        final draft = Draft(
          title: 'Sony TV Mainboard Ersatzteil',
          condition: 'Gebraucht, ausgebaut. Funktion nicht garantiert.',
          description:
              'Ich biete ein gebrauchtes Sony TV Mainboard als Ersatzteil für Bastler an.',
          defects: 'Ungetestet, daher Verkauf ausdrücklich als Bastlerware.',
          includedItems: 'Mainboard wie abgebildet.',
          priceNote: '25 € VB',
          handoverNote: 'Abholung oder Versand nach Absprache.',
          photoPaths: ['/tmp/mainboard.jpg'],
        );

        final result = DraftFormatter().format(draft);

        // Title as heading
        expect(result.startsWith('Sony TV Mainboard Ersatzteil'), isTrue);

        // Natural intro
        expect(result, contains('Ich biete ein gebrauchtes Sony TV Mainboard'));

        // Sections
        expect(result, contains('Zustand:'));
        expect(result, contains('Mängel / Hinweise:'));
        expect(result, contains('Lieferumfang:'));
        expect(result, contains('Mainboard wie abgebildet.'));

        // Photo singular
        expect(result, contains('1 Foto lokal angehängt'));

        // Price
        expect(result, contains('25 € VB'));

        // Handover
        expect(result, contains('Übergabe:'));
        expect(result, contains('Abholung oder Versand nach Absprache.'));

        // Review notice
        expect(result, contains('Kein automatisches Posting'));
      });

      test('Elektronik-Beispiel', () {
        final draft = Draft(
          title: 'Samsung Galaxy S23 — 128 GB Schwarz',
          condition: 'Sehr guter Zustand, kaum Gebrauchsspuren.',
          description: 'Biete ein sehr gut erhaltenes Samsung Galaxy S23.',
          defects: 'Keine — voll funktionsfähig.',
          includedItems: 'Smartphone, Original-Netzteil, OVP.',
          priceNote: '350 € Festpreis',
          handoverNote: 'Abholung in München bevorzugt.',
          locationNote: 'München Schwabing',
          photoPaths: [
            '/tmp/galaxy1.jpg',
            '/tmp/galaxy2.jpg',
            '/tmp/galaxy3.jpg',
          ],
        );

        final result = DraftFormatter().format(draft);

        expect(result, contains('Samsung Galaxy S23'));
        expect(result, contains('Zustand:'));
        expect(result, contains('Sehr guter Zustand'));
        expect(result, contains('Mängel / Hinweise:'));
        expect(result, contains('voll funktionsfähig'));
        expect(result, contains('350 € Festpreis'));
        expect(result, contains('3 Fotos lokal angehängt'));
        expect(result, contains('München Schwabing'));
        expect(result, contains('Kein automatisches Posting'));
      });

      test('Möbel/Haushalt-Beispiel', () {
        final draft = Draft(
          title: 'IKEA Malm Kommode — Weiß',
          condition: 'Gut erhalten, leichte Gebrauchsspuren.',
          description: 'Gut erhaltene IKEA Malm Kommode in Weiß abzugeben.',
          defects: 'Eine kleine Druckstelle an der rechten Seite.',
          includedItems: 'Kommode wie abgebildet. Ohne Deko.',
          priceNote: '40 € VB',
          handoverNote: 'Nur Abholung. Kommode ist bereits demontiert.',
          locationNote: 'Hamburg Eimsbüttel',
        );

        final result = DraftFormatter().format(draft);

        expect(result, contains('IKEA Malm Kommode'));
        expect(result, contains('Gut erhalten'));
        expect(result, contains('Druckstelle'));
        expect(result, contains('demontiert'));
        expect(result, contains('40 € VB'));
        expect(result, isNot(contains('Fotos:'))); // no photos
        expect(result, contains('Hamburg Eimsbüttel'));
      });

      test('Fahrrad/E-Bike-Beispiel', () {
        final draft = Draft(
          title: 'Cube Reaction Hybrid Pro 500 — 29 Zoll',
          condition: 'Gut, regelmäßig gewartet.',
          description: 'Verkaufe mein Cube E-MTB, zuverlässig und gepflegt.',
          defects: 'Akku bei ca. 80 % Kapazität.',
          includedItems: 'E-Bike, Ladegerät, Schlüssel, Bedienungsanleitung.',
          priceNote: '1.200 € VB',
          handoverNote: 'Abholung in Köln. Probefahrt möglich.',
          locationNote: 'Köln Ehrenfeld',
          photoPaths: ['/tmp/bike1.jpg'],
        );

        final result = DraftFormatter().format(draft);

        expect(result, contains('Cube Reaction Hybrid Pro 500'));
        expect(result, contains('regelmäßig gewartet'));
        expect(result, contains('1.200 € VB'));
        expect(result, contains('Probefahrt'));
        expect(result, contains('1 Foto lokal angehängt'));
        expect(result, contains('Köln Ehrenfeld'));
      });
    });
  });
}
