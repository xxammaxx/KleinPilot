import 'package:flutter/material.dart';
import '../models/draft.dart';
import '../services/draft_storage.dart';
import 'draft_form_screen.dart';
import 'safety_screen.dart';

/// Home / Dashboard screen.
///
/// Shows:
/// - "Neue Anzeige vorbereiten" button
/// - List of locally saved drafts with open/delete actions
/// - Safety info button
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DraftStorage _storage = DraftStorage();
  List<Draft> _savedDrafts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    final drafts = await _storage.loadDrafts();
    if (mounted) {
      setState(() {
        _savedDrafts = drafts;
        _loading = false;
      });
    }
  }

  Future<void> _deleteDraft(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Entwurf löschen'),
        content: const Text('Möchtest du diesen Entwurf wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteDraft(id);
      await _loadDrafts();
    }
  }

  void _openDraft(Draft draft) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DraftFormScreen(existingDraft: draft)),
    );
    // Reload drafts when returning (draft may have been saved/updated)
    await _loadDrafts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KleinPilot'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sicherheit & Über',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SafetyScreen()),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // --- Header ---
        Center(
          child: Column(
            children: [
              const Icon(Icons.edit_note, size: 80, color: Colors.teal),
              const SizedBox(height: 24),
              const Text(
                'KleinPilot',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lokale Anzeigen-Entwürfe vorbereiten',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // --- New draft button ---
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DraftFormScreen()),
              );
              // Reload drafts when returning from creating a new draft
              await _loadDrafts();
            },
            icon: const Icon(Icons.add),
            label: const Text('Neue Anzeige vorbereiten'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Manueller Entwurf — Kein automatisches Posten',
            style: TextStyle(fontSize: 12, color: Colors.orange),
          ),
        ),

        // --- Saved drafts section ---
        if (_savedDrafts.isNotEmpty) ...[
          const SizedBox(height: 32),
          Row(
            children: [
              const Icon(Icons.save, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Gespeicherte Entwürfe (${_savedDrafts.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock, size: 14, color: Colors.teal),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Nur lokal auf diesem Gerät gespeichert.',
                    style: TextStyle(fontSize: 11, color: Colors.teal),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ..._savedDrafts.map((draft) => _buildDraftCard(context, draft)),
        ],
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildDraftCard(BuildContext context, Draft draft) {
    final title = draft.title.trim().isEmpty
        ? 'Ohne Titel'
        : draft.title.trim();
    final updated = draft.updatedAt ?? draft.createdAt ?? '';
    // Format ISO timestamp to a short readable form
    String shortDate = '';
    if (updated.isNotEmpty) {
      try {
        final dt = DateTime.parse(updated).toLocal();
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 1) {
          shortDate = 'Gerade eben';
        } else if (diff.inHours < 1) {
          shortDate = 'Vor ${diff.inMinutes} Min.';
        } else if (diff.inDays < 1) {
          shortDate = 'Vor ${diff.inHours} Std.';
        } else if (diff.inDays < 7) {
          shortDate = 'Vor ${diff.inDays} Tagen';
        } else {
          shortDate =
              '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
        }
      } catch (_) {
        shortDate = '';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _openDraft(draft),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const Icon(Icons.article_outlined, color: Colors.teal, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (shortDate.isNotEmpty)
                      Text(
                        shortDate,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (draft.photoPaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo, size: 14, color: Colors.grey),
                      const SizedBox(width: 2),
                      Text(
                        '${draft.photoPaths.length}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                tooltip: 'Entwurf löschen',
                color: Colors.red.shade300,
                onPressed: () => _deleteDraft(draft.id!),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
