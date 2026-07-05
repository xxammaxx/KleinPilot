import '../models/draft.dart';

/// Formats a [Draft] into a human-readable, copy-ready German listing text.
///
/// No network calls, no AI, no automation — pure deterministic local formatting.
///
/// Design principles:
/// - Title as heading (no "Titel:" prefix)
/// - Description as natural intro sentence (no "Beschreibung:" prefix)
/// - Section headers for optional fields only when present
/// - Proper singular/plural for photo count
/// - Manual review notice always at end
/// - Empty/whitespace-only fields silently omitted
///
/// Future: Template modes (sparePart, electronics, furniture, bike, etc.)
/// could specialize the intro sentence and section ordering, but are
/// deferred to keep this pass small and testable.
class DraftFormatter {
  String format(Draft draft) {
    final buffer = StringBuffer();

    // --- Title (required, serves as heading) ---
    final title = draft.title.trim();
    if (title.isNotEmpty) {
      buffer.writeln(title);
      buffer.writeln();
    }

    // --- Description (natural intro, no label prefix) ---
    final description = draft.description.trim();
    if (description.isNotEmpty) {
      buffer.writeln(description);
      buffer.writeln();
    }

    // --- Condition ---
    final condition = draft.condition.trim();
    if (condition.isNotEmpty) {
      buffer.writeln('Zustand:');
      buffer.writeln(condition);
      buffer.writeln();
    }

    // --- Defects ---
    final defects = draft.defects.trim();
    if (defects.isNotEmpty) {
      buffer.writeln('Mängel / Hinweise:');
      buffer.writeln(defects);
      buffer.writeln();
    }

    // --- Included items ---
    final includedItems = draft.includedItems.trim();
    if (includedItems.isNotEmpty) {
      buffer.writeln('Lieferumfang:');
      buffer.writeln(includedItems);
      buffer.writeln();
    }

    // --- Photos (with proper singular/plural) ---
    if (draft.photoPaths.isNotEmpty) {
      final count = draft.photoPaths.length;
      buffer.writeln('Fotos:');
      if (count == 1) {
        buffer.writeln(
          '1 Foto lokal angehängt. Bitte vor dem Einstellen manuell prüfen.',
        );
      } else {
        buffer.writeln(
          '$count Fotos lokal angehängt. Bitte vor dem Einstellen manuell prüfen.',
        );
      }
      buffer.writeln();
    }

    // --- Price ---
    final priceNote = draft.priceNote.trim();
    if (priceNote.isNotEmpty) {
      buffer.writeln('Preisvorstellung:');
      buffer.writeln(priceNote);
      buffer.writeln();
    }

    // --- Handover ---
    final handoverNote = draft.handoverNote.trim();
    if (handoverNote.isNotEmpty) {
      buffer.writeln('Übergabe:');
      buffer.writeln(handoverNote);
      buffer.writeln();
    }

    // --- Location ---
    final locationNote = draft.locationNote.trim();
    if (locationNote.isNotEmpty) {
      buffer.writeln('Standort:');
      buffer.writeln(locationNote);
      buffer.writeln();
    }

    // --- Manual review notice (always present, at end) ---
    buffer.writeln('Hinweis:');
    buffer.writeln(
      'Dies ist ein manuell zu prüfender Entwurf. '
      'Kein automatisches Posting.',
    );

    return buffer.toString().trim();
  }
}
