import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/draft.dart';
import '../services/draft_formatter.dart';

/// Preview screen.
///
/// Displays the generated listing text and provides manual copy/export buttons.
/// No network, no auto-posting, no scraping.
class PreviewScreen extends StatelessWidget {
  final Draft draft;

  const PreviewScreen({super.key, required this.draft});

  @override
  Widget build(BuildContext context) {
    final formattedText = DraftFormatter().format(draft);

    return Scaffold(
      appBar: AppBar(title: const Text('Vorschau')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Bitte manuell prüfen — kein automatisches Posten!',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (draft.photoPaths.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.photo_library, color: Colors.teal, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Fotos: ${draft.photoPaths.length} lokal angehängt',
                    style: const TextStyle(
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Fotos müssen später manuell geprüft und hochgeladen werden, '
                'falls du sie verwenden möchtest.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    formattedText,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: formattedText));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Text in die Zwischenablage kopiert!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Kopieren'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Manual export: open share sheet (if available) or show text
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Text exportieren'),
                          content: Text(
                            formattedText,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 20,
                            overflow: TextOverflow.ellipsis,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Schließen'),
                            ),
                            TextButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: formattedText),
                                );
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Text kopiert — manuell in Kleinanzeigen.de einfügen',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Kopieren & Schließen'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.ios_share),
                    label: const Text('Exportieren'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
