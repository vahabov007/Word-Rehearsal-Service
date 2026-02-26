import 'package:flutter/material.dart';
import '../models/vocab_word.dart';

class WordDetailsScreen extends StatelessWidget {
  final VocabWord word;
  const WordDetailsScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(word.word)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: cs.surfaceContainerHighest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      word.word,
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Chip(
                    label: Text(word.isReady ? "Ready" : "Not ready"),
                    backgroundColor: word.isReady ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          _sectionTitle("Definitions"),
          ...word.definitions.map((d) => _bullet(d)),

          if (word.synonyms != null) ...[
            const SizedBox(height: 14),
            _infoCard("Synonyms", word.synonyms!),
          ],
          if (word.antonyms != null) ...[
            const SizedBox(height: 10),
            _infoCard("Antonyms", word.antonyms!),
          ],
          if (word.usageFrequency != null) ...[
            const SizedBox(height: 10),
            _infoCard("Usage", word.usageFrequency!),
          ],

          const SizedBox(height: 14),
          _sectionTitle("Examples"),
          ...word.examples.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text("“$e”", style: const TextStyle(fontStyle: FontStyle.italic)),
              )),

          if (word.contextParagraph != null && word.contextParagraph!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            _sectionTitle("Context paragraph"),
            Text(word.contextParagraph!),
          ],
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _bullet(String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("•  "),
            Expanded(child: Text(t)),
          ],
        ),
      );

  Widget _infoCard(String label, String value) => Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w700)),
              Expanded(child: Text(value)),
            ],
          ),
        ),
      );
}