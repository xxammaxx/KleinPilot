import 'package:flutter/material.dart';
import '../models/draft.dart';
import 'preview_screen.dart';

/// Draft form screen.
///
/// Collects all fields for a local Kleinanzeigen listing draft.
/// No network, no auto-posting, no scraping.
class DraftFormScreen extends StatefulWidget {
  const DraftFormScreen({super.key});

  @override
  State<DraftFormScreen> createState() => _DraftFormScreenState();
}

class _DraftFormScreenState extends State<DraftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _draft = Draft();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anzeigenentwurf')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildField(
              'Titel',
              _draft.title,
              (v) => _draft.title = v,
              maxLines: 1,
            ),
            _buildField(
              'Kategorie (Freitext)',
              _draft.categoryNote,
              (v) => _draft.categoryNote = v,
              maxLines: 1,
            ),
            _buildField(
              'Zustand',
              _draft.condition,
              (v) => _draft.condition = v,
              maxLines: 1,
              hint: 'z.B. Neu, Gebraucht, Gut, Defekt',
            ),
            _buildField(
              'Beschreibung / Notizen',
              _draft.description,
              (v) => _draft.description = v,
              maxLines: 4,
            ),
            _buildField(
              'Mängel / Defekte',
              _draft.defects,
              (v) => _draft.defects = v,
              maxLines: 3,
            ),
            _buildField(
              'Lieferumfang',
              _draft.includedItems,
              (v) => _draft.includedItems = v,
              maxLines: 3,
            ),
            _buildField(
              'Preisvorstellung',
              _draft.priceNote,
              (v) => _draft.priceNote = v,
              maxLines: 1,
              hint: 'z.B. VB 50€, oder Festpreis',
            ),
            _buildField(
              'Übergabe (Abholung / Versand)',
              _draft.handoverNote,
              (v) => _draft.handoverNote = v,
              maxLines: 2,
            ),
            _buildField(
              'Standort (ungefähre Angabe)',
              _draft.locationNote,
              (v) => _draft.locationNote = v,
              maxLines: 1,
              hint: 'z.B. Stadtteil, PLZ (freiwillig)',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onPreview,
                icon: const Icon(Icons.preview),
                label: const Text('Vorschau anzeigen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String initialValue,
    ValueChanged<String> onChanged, {
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _onPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(draft: _draft)),
    );
  }
}
