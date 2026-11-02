import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One thing a good password has.
typedef ResetPassword01Rule = ({String label, bool Function(String) test});

/// The checklist under the new password: each rule ticks green once the
/// password meets it.
class ResetPassword01Rules extends StatelessWidget {
  const ResetPassword01Rules({super.key, required this.password});

  /// The password typed so far.
  final String password;

  /// What a good password has.
  static final List<ResetPassword01Rule> rules = [
    (label: '8 or more characters', test: (p) => p.length >= 8),
    (label: 'A number', test: (p) => RegExp(r'\d').hasMatch(p)),
    (
      label: 'A capital and a small letter',
      test: (p) => RegExp('[a-z]').hasMatch(p) && RegExp('[A-Z]').hasMatch(p),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      label: 'A good password has',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d4,
        children: [
          for (final rule in rules)
            _RuleRow(label: rule.label, met: rule.test(password), theme: theme),
        ],
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  const _RuleRow({required this.label, required this.met, required this.theme});

  final String label;
  final bool met;
  final LooseleafThemeData theme;

  @override
  Widget build(BuildContext context) {
    final color = switch (met) {
      true => theme.colors.green,
      false => theme.colors.inkMuted,
    };
    return Semantics(
      label:
          '${switch (met) {
            true => 'Done: ',
            false => 'Not yet: ',
          }}$label',
      excludeSemantics: true,
      child: Row(
        spacing: Spacing.d8,
        children: [
          InkIcon(
            switch (met) {
              true => 'circle-check',
              false => 'circle',
            },
            size: Spacing.d16,
            color: color,
          ),
          Flexible(
            child: Text(
              label,
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 14,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
