import 'package:flutter/material.dart';

import '../models/vocab_word.dart';
import '../widgets/multi_meaning_card.dart';
import '../widgets/vocab_badge.dart';

class WordDetailsScreen extends StatelessWidget {
  final VocabWord word;

  const WordDetailsScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(word.word)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      word.word,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    VocabBadge(
                      label: word.isReady ? 'Ready' : 'Draft',
                      color: word.isReady
                          ? const Color(0xFF0F766E)
                          : const Color(0xFFEA580C),
                      icon: word.isReady
                          ? Icons.check_rounded
                          : Icons.edit_rounded,
                    ),
                    VocabBadge(
                      label: '${word.meanings.length} meanings',
                      color: colorScheme.tertiary,
                      icon: Icons.layers_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            MultiMeaningCard(
              word: word,
              isRevealed: true,
              onReveal: () {},
              onSynonymSelected: (synonym) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lookup cue selected: $synonym')),
                );
              },
            ),
            if (word.antonyms != null || word.contextParagraph != null) ...[
              const SizedBox(height: 14),
              _ExtraInfoCard(word: word),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExtraInfoCard extends StatelessWidget {
  final VocabWord word;

  const _ExtraInfoCard({required this.word});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (word.antonyms != null) ...[
              Text('Antonyms', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(word.antonyms!),
            ],
            if (word.contextParagraph != null) ...[
              if (word.antonyms != null) const SizedBox(height: 14),
              Text('Context', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(word.contextParagraph!),
            ],
          ],
        ),
      ),
    );
  }
}
