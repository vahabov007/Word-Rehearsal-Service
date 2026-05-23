import 'package:flutter/material.dart';

class ReviewAction {
  final int grade;
  final String label;
  final String helper;
  final Color color;
  final IconData icon;

  const ReviewAction({
    required this.grade,
    required this.label,
    required this.helper,
    required this.color,
    required this.icon,
  });
}

class ReviewFeedbackPanel extends StatelessWidget {
  final bool isSubmitting;
  final ValueChanged<int> onGradeSelected;

  const ReviewFeedbackPanel({
    super.key,
    required this.isSubmitting,
    required this.onGradeSelected,
  });

  static const List<ReviewAction> actions = [
    ReviewAction(
      grade: 1,
      label: 'Again',
      helper: 'Reset',
      color: Color(0xFFDC2626),
      icon: Icons.replay_rounded,
    ),
    ReviewAction(
      grade: 2,
      label: 'Hard',
      helper: 'Soon',
      color: Color(0xFFEA580C),
      icon: Icons.trending_down_rounded,
    ),
    ReviewAction(
      grade: 3,
      label: 'Good',
      helper: 'Keep',
      color: Color(0xFF0F766E),
      icon: Icons.check_rounded,
    ),
    ReviewAction(
      grade: 5,
      label: 'Easy',
      helper: 'Later',
      color: Color(0xFF16A34A),
      icon: Icons.bolt_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: isSubmitting,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: isSubmitting ? 0.55 : 1,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 430;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: actions.map((action) {
                final rawWidth = compact
                    ? (constraints.maxWidth - 10) / 2
                    : (constraints.maxWidth - 30) / actions.length;
                final width = constraints.maxWidth < 130
                    ? constraints.maxWidth
                    : rawWidth.clamp(130.0, constraints.maxWidth).toDouble();
                return SizedBox(
                  width: width,
                  child: FilledButton.tonalIcon(
                    onPressed: () => onGradeSelected(action.grade),
                    icon: Icon(action.icon, color: action.color),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(action.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(
                          action.helper,
                          style: Theme.of(context).textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    style: FilledButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                );
              }).toList(growable: false),
            );
          },
        ),
      ),
    );
  }
}
