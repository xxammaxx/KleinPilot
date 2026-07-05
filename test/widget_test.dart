import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kleinpilot/main.dart';

void main() {
  testWidgets('App startet und zeigt KleinPilot', (WidgetTester tester) async {
    await tester.pumpWidget(const KleinPilotApp());

    // Verify app title is visible (appears in AppBar and body)
    expect(find.text('KleinPilot'), findsAtLeast(1));

    // Verify dashboard shows the subtitle
    expect(find.text('Lokale Anzeigen-Entwürfe vorbereiten'), findsOneWidget);
  });

  testWidgets('Safety-Hinweise sind sichtbar', (WidgetTester tester) async {
    await tester.pumpWidget(const KleinPilotApp());

    // Check the safety note on the home screen
    expect(
      find.text('Manueller Entwurf — Kein automatisches Posten'),
      findsOneWidget,
    );

    // Navigate to safety screen
    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();

    // Verify safety guarantees are visible
    expect(find.text('KleinPilot — Sicherheitserklärung'), findsOneWidget);
    expect(find.text('Kein Login'), findsOneWidget);
    expect(find.text('Kein automatisches Posten'), findsOneWidget);
    expect(find.text('Kein Scraping'), findsOneWidget);
    expect(find.text('Kein Messaging'), findsOneWidget);
    expect(find.text('Keine Telemetrie'), findsOneWidget);
    expect(find.text('Lokal-first'), findsOneWidget);
  });

  testWidgets('Draft form has all 9 fields', (WidgetTester tester) async {
    await tester.pumpWidget(const KleinPilotApp());

    // Navigate to form
    await tester.tap(find.text('Neue Anzeige vorbereiten'));
    await tester.pumpAndSettle();

    // Verify appbar title
    expect(find.text('Anzeigenentwurf'), findsOneWidget);

    // Check initial visible fields
    expect(find.text('Titel'), findsOneWidget);
    expect(find.text('Kategorie (Freitext)'), findsOneWidget);
    expect(find.text('Zustand'), findsOneWidget);

    // Scroll down to reveal more fields
    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Beschreibung / Notizen'), findsOneWidget);
    expect(find.text('Mängel / Defekte'), findsOneWidget);

    // Scroll further
    await tester.drag(listView, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Lieferumfang'), findsOneWidget);
    expect(find.text('Preisvorstellung'), findsOneWidget);

    // Scroll further
    await tester.drag(listView, const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.text('Übergabe (Abholung / Versand)'), findsOneWidget);
    expect(find.text('Standort (ungefähre Angabe)'), findsOneWidget);

    // Verify preview button is visible at the bottom
    expect(find.text('Vorschau anzeigen'), findsOneWidget);
  });

  testWidgets('Eingaben erzeugen Preview-Text', (WidgetTester tester) async {
    await tester.pumpWidget(const KleinPilotApp());

    // Navigate to form
    await tester.tap(find.text('Neue Anzeige vorbereiten'));
    await tester.pumpAndSettle();

    // Fill in the title field (first TextFormField)
    final titleField = find.byType(TextFormField).first;
    await tester.enterText(titleField, 'Test Fahrrad');
    await tester.pumpAndSettle();

    // Scroll to the preview button
    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -900));
    await tester.pumpAndSettle();

    // Navigate to preview
    await tester.tap(find.text('Vorschau anzeigen'));
    await tester.pumpAndSettle();

    // Verify preview contains the entered text
    expect(find.textContaining('Test Fahrrad'), findsOneWidget);
    expect(
      find.text('Bitte manuell prüfen — kein automatisches Posten!'),
      findsOneWidget,
    );
  });

  testWidgets('Copy/Export bleibt manueller Flow', (WidgetTester tester) async {
    await tester.pumpWidget(const KleinPilotApp());

    // Navigate to form
    await tester.tap(find.text('Neue Anzeige vorbereiten'));
    await tester.pumpAndSettle();

    // Scroll to the preview button
    final listView = find.byType(ListView);
    await tester.drag(listView, const Offset(0, -900));
    await tester.pumpAndSettle();

    // Navigate to preview
    await tester.tap(find.text('Vorschau anzeigen'));
    await tester.pumpAndSettle();

    // Verify copy and export buttons exist
    expect(find.text('Kopieren'), findsOneWidget);
    expect(find.text('Exportieren'), findsOneWidget);
  });

  testWidgets('Keine Login/Post/Scraping-UI sichtbar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KleinPilotApp());

    // Verify no login UI
    expect(find.text('Login'), findsNothing);
    expect(find.text('Anmelden'), findsNothing);
    expect(find.text('Passwort'), findsNothing);
    expect(find.text('Account'), findsNothing);

    // Verify no auto-post UI
    expect(find.text('Posten'), findsNothing);
    expect(find.text('Veröffentlichen'), findsNothing);
    expect(find.text('Absenden'), findsNothing);

    // Verify no scraping UI
    expect(find.text('Suchen'), findsNothing);
    expect(find.text('Scrapen'), findsNothing);
  });
}
