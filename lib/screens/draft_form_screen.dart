import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/draft.dart';
import '../services/draft_storage.dart';
import 'preview_screen.dart';

/// Draft form screen.
///
/// Collects all fields for a local Kleinanzeigen listing draft.
/// No network, no auto-posting, no scraping.
///
/// If [existingDraft] is provided, the form is pre-populated with
/// the saved draft's values (editing mode).
class DraftFormScreen extends StatefulWidget {
  final Draft? existingDraft;

  const DraftFormScreen({super.key, this.existingDraft});

  @override
  State<DraftFormScreen> createState() => _DraftFormScreenState();
}

class _DraftFormScreenState extends State<DraftFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final Draft _draft;
  final DraftStorage _storage = DraftStorage();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // If loading an existing draft, copy its values.
    // Otherwise start with a fresh draft.
    if (widget.existingDraft != null) {
      _draft = widget.existingDraft!.copyWith();
    } else {
      _draft = Draft();
    }
  }

  bool get _isEditing => widget.existingDraft != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Entwurf bearbeiten' : 'Anzeigenentwurf'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Local-only notice ---
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.teal.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.teal),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Nur lokal auf diesem Gerät gespeichert.',
                      style: TextStyle(fontSize: 12, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
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
            _buildPhotoSection(),
            const SizedBox(height: 16),

            // --- Save Draft button ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _onSave,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isEditing ? 'Entwurf aktualisieren' : 'Entwurf speichern',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- Preview button ---
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _onPreview,
                icon: const Icon(Icons.preview),
                label: const Text('Vorschau anzeigen'),
                style: OutlinedButton.styleFrom(
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

  Widget _buildPhotoSection() {
    final photoCount = _draft.photoPaths.length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.photo_library, color: Colors.teal),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Fotos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                if (photoCount > 0)
                  Text(
                    '$photoCount Foto(s)',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (photoCount > 0) ...[
              ..._draft.photoPaths.asMap().entries.map((entry) {
                final idx = entry.key;
                final path = entry.value;
                final fileName = path.split('/').last;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      const Icon(Icons.image, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        tooltip: 'Foto entfernen',
                        onPressed: () => _removePhoto(idx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(
                  photoCount > 0
                      ? 'Weiteres Foto hinzufügen'
                      : 'Fotos hinzufügen',
                ),
              ),
            ),
            if (photoCount > 0) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    setState(() => _draft.photoPaths.clear());
                  },
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Alle Fotos entfernen'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.orange),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fotos bleiben lokal auf deinem Gerät und werden nicht automatisch hochgeladen.',
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile != null && mounted) {
      setState(() {
        _draft.photoPaths.add(xFile.path);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _draft.photoPaths.removeAt(index);
    });
  }

  Future<void> _onSave() async {
    setState(() => _saving = true);
    try {
      await _storage.saveDraft(_draft);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entwurf lokal gespeichert.'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _onPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PreviewScreen(draft: _draft)),
    );
  }
}
