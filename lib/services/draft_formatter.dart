import '../models/draft.dart';

/// Formats a [Draft] into a human-readable listing text block.
///
/// No network calls, no automation — pure local text generation.
class DraftFormatter {
  String format(Draft draft) {
    final buffer = StringBuffer();

    void appendIfNotEmpty(String label, String value) {
      if (value.trim().isNotEmpty) {
        buffer.writeln('$label:\n$value\n');
      }
    }

    appendIfNotEmpty('Titel', draft.title);
    appendIfNotEmpty('Kategorie', draft.categoryNote);
    appendIfNotEmpty('Zustand', draft.condition);
    appendIfNotEmpty('Beschreibung', draft.description);
    appendIfNotEmpty('Mängel / Defekte', draft.defects);
    appendIfNotEmpty('Lieferumfang', draft.includedItems);
    appendIfNotEmpty('Preisvorstellung', draft.priceNote);
    appendIfNotEmpty('Übergabe', draft.handoverNote);
    appendIfNotEmpty('Standort', draft.locationNote);

    if (draft.photoPaths.isNotEmpty) {
      buffer.writeln(
        'Fotos: ${draft.photoPaths.length} Foto(s) lokal angehängt',
      );
      buffer.writeln('(Fotos bleiben lokal und werden nicht hochgeladen)\n');
    }

    buffer.writeln('---');
    buffer.writeln(
      'Hinweis: Dies ist ein manuell zu prüfender Entwurf. '
      'Kein automatisches Posting.',
    );

    return buffer.toString().trim();
  }
}
