import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/api_service.dart';

class RehearsalScreen extends StatefulWidget {
  final List<VocabWord> words;
  const RehearsalScreen({super.key, required this.words});

  @override
  State<RehearsalScreen> createState() => _RehearsalScreenState();
}

class _RehearsalScreenState extends State<RehearsalScreen> {
  int _index = 0;
  bool _showDetails = false;
  bool _submitting = false;

  final Map<int, List<String>> _history = {1: [], 2: [], 3: [], 4: [], 5: []};

  VocabWord get _current => widget.words[_index];

  Future<void> _grade(int grade) async {
    final word = _current;
    setState(() => _submitting = true);

    try {
      await ApiService.submitGrade(word.id, grade);
      _history[grade]!.add(word.word);
    } catch (_) {
      // Still record locally even if backend fails
      _history[grade]!.add(word.word);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to submit grade. Saved locally for session.")),
        );
      }
    } finally {
      if (!mounted) return;
      setState(() => _submitting = false);
    }

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
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Session Complete", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ..._history.entries.where((e) => e.value.isNotEmpty).map((e) {
              return ListTile(
                leading: CircleAvatar(child: Text("${e.key}")),
                title: Text("Grade ${e.key}"),
                subtitle: Text(e.value.join(", ")),
              );
            }),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _index = 0;
                        _showDetails = false;
                        _history.forEach((k, v) => v.clear());
                      });
                    },
                    child: const Text("Restart"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Done"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _current;
    final progress = (_index + 1) / widget.words.length;

    return Scaffold(
      appBar: AppBar(
        title: Text("Rehearsal ${_index + 1}/${widget.words.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 18),

            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(word.word, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      _showDetails ? "Check details and grade yourself." : "Try to recall the meaning first.",
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _showDetails ? _details(word) : _recallHint(),
              ),
            ),

            const SizedBox(height: 12),

            if (!_showDetails)
              FilledButton.icon(
                onPressed: () => setState(() => _showDetails = true),
                icon: const Icon(Icons.visibility),
                label: const Text("Show details"),
              )
            else
              _gradingRow(),
          ],
        ),
      ),
    );
  }

  Widget _recallHint() => const Center(
        key: ValueKey("recall"),
        child: Text("Recall meaning…", style: TextStyle(fontSize: 18)),
      );

  Widget _details(VocabWord w) {
    return SingleChildScrollView(
      key: const ValueKey("details"),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Definitions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...w.definitions.map((d) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("•  "),
                    Expanded(child: Text(d)),
                  ],
                ),
              )),
          if (w.synonyms != null) _infoBox("Synonyms", w.synonyms!),
          if (w.antonyms != null) _infoBox("Antonyms", w.antonyms!),
          const SizedBox(height: 14),
          const Text("Examples", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          ...w.examples.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text("“$e”", style: const TextStyle(fontStyle: FontStyle.italic)),
              )),
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text("$label: ", style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _gradingRow() {
    return IgnorePointer(
      ignoring: _submitting,
      child: Opacity(
        opacity: _submitting ? 0.6 : 1,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [1, 2, 3, 4, 5].map((g) => _gradeButton(g)).toList(),
        ),
      ),
    );
  }

  Widget _gradeButton(int grade) {
    final colors = [Colors.red, Colors.orange, Colors.amber, Colors.lightGreen, Colors.green];
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () => _grade(grade),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors[grade - 1],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text("$grade"),
        ),
      ),
    );
  }
}