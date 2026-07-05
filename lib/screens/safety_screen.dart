import 'package:flutter/material.dart';

/// Safety / About screen.
///
/// Displays the safety guarantees of KleinPilot: no login, no auto-posting,
/// no scraping, no messaging automation, local-first.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sicherheit & Über KleinPilot')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Icon(Icons.shield, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'KleinPilot — Sicherheitserklärung',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildItem(
            'Kein Login',
            'KleinPilot benötigt keinen Account und sammelt keine Anmeldedaten.',
          ),
          _buildItem(
            'Kein automatisches Posten',
            'KleinPilot postet keine Anzeigen automatisch. Alles muss manuell geprüft und kopiert werden.',
          ),
          _buildItem(
            'Kein Scraping',
            'KleinPilot liest keine Inhalte von Kleinanzeigen.de oder anderen Plattformen aus.',
          ),
          _buildItem(
            'Kein Messaging',
            'KleinPilot sendet und empfängt keine Nachrichten.',
          ),
          _buildItem(
            'Keine Telemetrie',
            'KleinPilot sammelt keine Nutzungsdaten, keine Analyse-Daten, keine Tracking-Daten.',
          ),
          _buildItem(
            'Lokal-first',
            'Alle Daten bleiben auf deinem Gerät. Keine Cloud, kein Sync, keine externe Speicherung.',
          ),
          _buildItem(
            'Keine Hintergrund-Aktivitäten',
            'Die App läuft nur, wenn du sie öffnest. Keine Hintergrunddienste, keine Uploads.',
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Haftungsausschluss',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'KleinPilot ist ein rein manuelles Hilfswerkzeug zur lokalen Entwurfserstellung. '
            'Der Nutzer ist selbst dafür verantwortlich, die erstellten Entwürfe zu prüfen '
            'und manuell auf Kleinanzeigen.de oder anderen Plattformen einzustellen. '
            'KleinPilot übernimmt keine Haftung für Inhalte oder deren Verwendung.',
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
