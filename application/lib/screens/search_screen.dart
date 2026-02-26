import 'dart:async';
import 'package:flutter/material.dart';
import '../models/vocab_word.dart';
import '../services/api_service.dart';
import 'word_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<VocabWord> _results = [];
  String? _error;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  Future<void> _search(String value) async {
    final q = value.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ApiService.searchWords(q);
      if (!mounted) return;
      setState(() => _results = res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Search failed. Backend not reachable?");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Search")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: "Type a word...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _results = []);
                        },
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),

            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: TextStyle(color: cs.error)),
              ),

            const SizedBox(height: 12),
            Expanded(
              child: _results.isEmpty
                  ? Center(
                      child: Text(
                        "Search results will appear here.",
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final w = _results[i];
                        return ListTile(
                          title: Text(w.word, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            w.definitions.isEmpty ? "No definition" : w.definitions.first,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Icon(w.isReady ? Icons.check_circle : Icons.edit_note, color: w.isReady ? Colors.green : Colors.orange),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => WordDetailsScreen(word: w)),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}