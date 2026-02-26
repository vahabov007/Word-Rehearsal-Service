import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'rehearsal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  int _dueCount = 0;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final count = await ApiService.getDueCount();
      if (!mounted) return;
      setState(() => _dueCount = count);
    } catch (e) {
      if (!mounted) return;
      _showSnack("Failed to load count. Check backend connection.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _startRehearsal() async {
    setState(() => _loading = true);
    try {
      final words = await ApiService.getRehearsalWords(page: 0, size: 10);
      if (!mounted) return;

      if (words.isEmpty) {
        _showSnack("No due words found!");
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RehearsalScreen(words: words)),
      );

      await _refresh(); // after session, refresh count
    } catch (e) {
      if (!mounted) return;
      _showSnack("Failed to start rehearsal. Backend not reachable?");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vocab Rehearse"),
        backgroundColor: cs.inversePrimary,
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh",
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              elevation: 0,
              color: cs.surfaceContainerHighest,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Words waiting for you", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _loading
                        ? const LinearProgressIndicator()
                        : Text(
                            "$_dueCount",
                            style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
                          ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _loading ? null : _startRehearsal,
                            icon: const Icon(Icons.play_arrow),
                            label: const Text("Start rehearsal"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tip: Only prepared words (with complete examples) will appear.",
                      style: TextStyle(color: cs.onSurfaceVariant),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: const ListTile(
                leading: Icon(Icons.lightbulb),
                title: Text("How it works"),
                subtitle: Text("Recall → Show details → Grade 1–5. The system schedules your next review."),
              ),
            )
          ],
        ),
      ),
    );
  }
}