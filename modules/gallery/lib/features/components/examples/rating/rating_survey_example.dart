import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RatingSurveyExample extends StatefulWidget {
  const RatingSurveyExample({super.key});

  @override
  State<RatingSurveyExample> createState() => _RatingSurveyExampleState();
}

class _RatingSurveyExampleState extends State<RatingSurveyExample> {
  static const _rows = [
    ('pace', 'Pace', RatingIcon.star),
    ('snacks', 'Snacks', RatingIcon.heart),
    ('sun', 'Sunshine', RatingIcon.sun),
  ];

  final _values = <String, double>{'pace': 4, 'snacks': 5, 'sun': 2};

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final total = _values.values.fold<double>(0, (sum, value) => sum + value);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          for (final (key, label, icon) in _rows)
            Row(
              spacing: Spacing.d16,
              children: [
                Expanded(child: Text(label, style: theme.typography.label())),
                Rating(
                  icon: icon,
                  value: _values[key] ?? 0,
                  onChanged: (value) => setState(() => _values[key] = value),
                  semanticLabel: label,
                  clearable: true,
                ),
              ],
            ),
          Text(
            'Total: ${Rating.format(total)} of 15',
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
