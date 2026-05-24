import 'package:flutter/material.dart';

import '../models/vocab_word.dart';
import '../models/word_meaning.dart';
import 'synonym_chip_cloud.dart';
import 'vocab_badge.dart';

class MultiMeaningCard extends StatelessWidget {
  final VocabWord word;
  final bool isRevealed;
  final VoidCallback onReveal;
  final ValueChanged<String>? onSynonymSelected;

  const MultiMeaningCard({
    super.key,
    required this.word,
    required this.isRevealed,
    required this.onReveal,
    this.onSynonymSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: !isRevealed,
      label: isRevealed ? '${word.word} details' : 'Reveal ${word.word}',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: isRevealed ? null : onReveal,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 28,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _WordHeader(word: word, isRevealed: isRevealed),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: isRevealed
                      ? _MeaningDetails(
                          key: const ValueKey('revealed-meanings'),
                          word: word,
                          onSynonymSelected: onSynonymSelected,
                        )
                      : const _RecallPrompt(key: ValueKey('hidden-meanings')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WordHeader extends StatelessWidget {
  final VocabWord word;
  final bool isRevealed;

  const _WordHeader({required this.word, required this.isRevealed});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                word.word,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            VocabBadge(
              label: '${word.meanings.length} meanings',
              color: colorScheme.tertiary,
              icon: Icons.layers_rounded,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          isRevealed
              ? 'Meanings, examples, and cue words'
              : 'Tap the card when your recall is ready',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _RecallPrompt extends StatelessWidget {
  const _RecallPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 34, bottom: 20),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.visibility_rounded, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Reveal answer',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MeaningDetails extends StatelessWidget {
  final VocabWord word;
  final ValueChanged<String>? onSynonymSelected;

  const _MeaningDetails({
    super.key,
    required this.word,
    this.onSynonymSelected,
  });

  @override
  Widget build(BuildContext context) {
    final meanings = word.meanings;
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meanings.isEmpty)
            Text(
              'No definition available yet.',
              style: Theme.of(context).textTheme.bodyLarge,
            )
          else
            ...meanings.indexed.map((entry) {
              return _MeaningTile(
                index: entry.$1 + 1,
                meaning: entry.$2,
                initiallyExpanded: entry.$1 == 0,
                onSynonymSelected: onSynonymSelected,
              );
            }),
          if (word.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ExamplesPanel(examples: word.examples),
          ],
        ],
      ),
    );
  }
}

class _MeaningTile extends StatelessWidget {
  final int index;
  final WordMeaning meaning;
  final bool initiallyExpanded;
  final ValueChanged<String>? onSynonymSelected;

  const _MeaningTile({
    required this.index,
    required this.meaning,
    required this.initiallyExpanded,
    this.onSynonymSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: colorScheme.surface.withValues(alpha: 0.62),
          collapsedBackgroundColor: colorScheme.surface.withValues(alpha: 0.46),
          leading: CircleAvatar(
            radius: 16,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              '$index',
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
          title: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              VocabBadge(
                label: meaning.partOfSpeech,
                color: colorScheme.primary,
              ),
              VocabBadge(
                label: meaning.frequency,
                color: _frequencyColor(meaning.frequency),
                icon: Icons.signal_cellular_alt_rounded,
              ),
            ],
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                meaning.definition,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.38),
              ),
            ),
            if (meaning.synonyms.isNotEmpty) ...[
              const SizedBox(height: 12),
              SynonymChipCloud(
                synonyms: meaning.synonyms,
                onSelected: onSynonymSelected,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _frequencyColor(String frequency) {
    final normalized = frequency.toLowerCase();
    if (normalized.contains('very')) return const Color(0xFF0F766E);
    if (normalized.contains('common')) return const Color(0xFF2563EB);
    return const Color(0xFF64748B);
  }
}

class _ExamplesPanel extends StatelessWidget {
  final List<String> examples;

  const _ExamplesPanel({required this.examples});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final visibleExamples = examples.take(6).toList(growable: false);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_quote_rounded, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Text(
                  'Examples',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...visibleExamples.map((example) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '"$example"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                    height: 1.32,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
