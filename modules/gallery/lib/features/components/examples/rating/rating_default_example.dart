import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RatingDefaultExample extends StatefulWidget {
  const RatingDefaultExample({super.key});

  @override
  State<RatingDefaultExample> createState() => _RatingDefaultExampleState();
}

class _RatingDefaultExampleState extends State<RatingDefaultExample> {
  double _value = 3;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d8,
      children: [
        Rating(
          value: _value,
          onChanged: (value) => setState(() => _value = value),
          semanticLabel: 'Rate this notebook',
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            switch (_value) {
              0 => 'Not rated yet.',
              final value => 'You gave it ${Rating.format(value)} out of 5.',
            },
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
