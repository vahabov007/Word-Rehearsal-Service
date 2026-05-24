import 'package:flutter/material.dart';

import '../models/vocab_word.dart';
import '../services/api_service.dart';
import '../widgets/multi_meaning_card.dart';
import '../widgets/review_feedback_panel.dart';

class RehearsalScreen extends StatefulWidget {
  final List<VocabWord> words;
  final ApiService apiService;

  const RehearsalScreen({
    super.key,
    required this.words,
    required this.apiService,
  });

  @override
  State<RehearsalScreen> createState() => _RehearsalScreenState();
}

class _RehearsalScreenState extends State<RehearsalScreen> {
  int _index = 0;
  bool _showDetails = false;
  bool _submitting = false;

  final Map<int, List<String>> _history = {1: [], 2: [], 3: [], 5: []};

  VocabWord get _current => widget.words[_index];

  Future<void> _grade(int grade) async {
    final word = _current;
    setState(() => _submitting = true);

    try {
      await widget.apiService.submitGrade(word.id, grade);
      _history.putIfAbsent(grade, () => []).add(word.word);
    } catch (_) {
      _history.putIfAbsent(grade, () => []).add(word.word);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Backend did not accept the grade. Saved locally for this session.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }

    if (!mounted) return;

    if (_index < widget.words.length - 1) {
      setState(() {
        _index++;
        _showDetails = false;
      });
    } else {
      _showSummary();
    }
  }

  void _showSummary() {
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      showDragHandle: true,
      builder: (context) {
        final entries = _history.entries
            .where((entry) => entry.value.isNotEmpty)
            .toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Session complete',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                if (entries.isEmpty)
                  const Text('No grades were recorded.')
                else
                  ...entries.map((entry) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text('${entry.key}')),
                      title: Text(_gradeLabel(entry.key)),
                      subtitle: Text(
                        entry.value.join(', '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _index = 0;
                          _showDetails = false;
                          _history.forEach((_, value) => value.clear());
                        });
                      },
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Restart'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.done_rounded),
                      label: const Text('Done'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSynonymLookup(String synonym) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Lookup cue selected: $synonym')));
  }

  String _gradeLabel(int grade) {
    return switch (grade) {
      1 => 'Again',
      2 => 'Hard',
      3 => 'Good',
      5 => 'Easy',
      _ => 'Grade $grade',
    };
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_index + 1) / widget.words.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Review ${_index + 1}/${widget.words.length}'),
        actions: [
          IconButton(
            onPressed: _submitting
                ? null
                : () => setState(() => _showDetails = !_showDetails),
            icon: Icon(
              _showDetails
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
            ),
            tooltip: _showDetails ? 'Hide details' : 'Reveal details',
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 156,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: MultiMeaningCard(
                            word: _current,
                            isRevealed: _showDetails,
                            onReveal: () => setState(() => _showDetails = true),
                            onSynonymSelected: _showSynonymLookup,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _showDetails
                      ? Padding(
                          key: const ValueKey('review-panel'),
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 720),
                            child: ReviewFeedbackPanel(
                              isSubmitting: _submitting,
                              onGradeSelected: _grade,
                            ),
                          ),
                        )
                      : Padding(
                          key: const ValueKey('reveal-button'),
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () =>
                                  setState(() => _showDetails = true),
                              icon: const Icon(Icons.visibility_rounded),
                              label: const Text('Reveal details'),
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
