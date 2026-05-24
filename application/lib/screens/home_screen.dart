import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'rehearsal_screen.dart';

class HomeScreen extends StatefulWidget {
  final ApiService apiService;

  const HomeScreen({super.key, required this.apiService});

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
      final count = await widget.apiService.getDueCount();
      if (!mounted) return;
      setState(() => _dueCount = count);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to load review count. Check the backend connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _startRehearsal() async {
    setState(() => _loading = true);
    try {
      final words = await widget.apiService.getRehearsalWords(
        page: 0,
        size: 10,
      );
      if (!mounted) return;

      if (words.isEmpty) {
        _showSnack('No due words found.');
        return;
      }

      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RehearsalScreen(words: words, apiService: widget.apiService),
        ),
      );

      await _refresh();
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to start rehearsal. Backend not reachable?');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final targetReviews = _dueCount < 10 ? 10 : _dueCount;
    final reviewProgress = targetReviews == 0
        ? 0.0
        : (_dueCount / targetReviews).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _HeroDashboardCard(
              dueCount: _dueCount,
              loading: _loading,
              progress: reviewProgress,
              onStart: _loading ? null : _startRehearsal,
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 620;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      width: compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 24) / 3,
                      icon: Icons.today_rounded,
                      title: 'Today',
                      value: '$_dueCount',
                      caption: 'reviews queued',
                      color: colorScheme.primary,
                    ),
                    _MetricCard(
                      width: compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 24) / 3,
                      icon: Icons.track_changes_rounded,
                      title: 'Retention',
                      value: _dueCount == 0 ? '100%' : '86%',
                      caption: 'current estimate',
                      color: const Color(0xFF0F766E),
                    ),
                    _MetricCard(
                      width: compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 24) / 3,
                      icon: Icons.auto_graph_rounded,
                      title: 'Pace',
                      value: targetReviews.toString(),
                      caption: 'daily target',
                      color: const Color(0xFF7C3AED),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            _ProgressBars(dueCount: _dueCount),
          ],
        ),
      ),
    );
  }
}

class _HeroDashboardCard extends StatelessWidget {
  final int dueCount;
  final bool loading;
  final double progress;
  final VoidCallback? onStart;

  const _HeroDashboardCard({
    required this.dueCount,
    required this.loading,
    required this.progress,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 520;
            final ring = _ProgressRing(
              progress: progress,
              label: loading ? '...' : '$dueCount',
            );
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready for review',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  loading ? 'Syncing your queue' : '$dueCount words due today',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Recall first, reveal second, then grade honestly. The scheduler will handle the spacing.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start rehearsal'),
                ),
              ],
            );

            if (compact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: ring),
                  const SizedBox(height: 18),
                  content,
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: content),
                const SizedBox(width: 24),
                ring,
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double progress;
  final String label;

  const _ProgressRing({required this.progress, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox.square(
      dimension: 132,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 11,
            strokeCap: StrokeCap.round,
            backgroundColor: colorScheme.surface,
          ),
          Center(
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String value;
  final String caption;
  final Color color;

  const _MetricCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
    required this.caption,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    Text(caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressBars extends StatelessWidget {
  final int dueCount;

  const _ProgressBars({required this.dueCount});

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('New', 0.42, const Color(0xFF2563EB)),
      ('Learning', dueCount == 0 ? 0.12 : 0.68, const Color(0xFFEA580C)),
      ('Mature', dueCount == 0 ? 0.9 : 0.54, const Color(0xFF0F766E)),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning mix',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            ...rows.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(row.$1),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: row.$2,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(999),
                      color: row.$3,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
