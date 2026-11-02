import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One setup step: its id, title, hint and action label.
typedef Onboarding01Step = ({
  String id,
  String title,
  InlineSpan hint,
  String action,
});

/// The five setup steps, in order.
const onboarding01Steps = <Onboarding01Step>[
  (
    id: 'name',
    title: 'Name your first notebook',
    hint: TextSpan(text: 'Give it a cover and a name people will remember.'),
    action: 'Name it',
  ),
  (
    id: 'invite',
    title: 'Invite a teammate',
    hint: TextSpan(text: 'Notes are better with company.'),
    action: 'Invite',
  ),
  (
    id: 'pin',
    title: 'Pin a page you love',
    hint: TextSpan(text: 'Pinned pages sit at the top of every notebook.'),
    action: 'Show me',
  ),
  (
    id: 'draw',
    title: 'Draw something, anything',
    hint: TextSpan(
      text: 'Every page has a sketch pad. Stubby will not judge.',
    ),
    action: 'Open sketch pad',
  ),
  (
    id: 'jump',
    title: 'Try the shortcut',
    hint: TextSpan(
      children: [
        TextSpan(text: 'Press '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Kbd(child: Text('⌘')),
        ),
        TextSpan(text: ' '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Kbd(child: Text('K')),
        ),
        TextSpan(text: ' to jump to any page.'),
      ],
    ),
    action: 'Try it',
  ),
];

/// The checklist: a checkbox, title and hint per step, with an action
/// button beside it from 448 px (under the hint below that).
///
/// Mirrors upstream `src/blocks/onboarding-01/components/onboarding-01-steps.tsx`.
class Onboarding01Steps extends StatelessWidget {
  const Onboarding01Steps({
    super.key,
    required this.done,
    required this.onDoneChange,
    this.onAction,
  });

  final Set<String> done;
  final void Function(String id, bool done) onDoneChange;
  final ValueChanged<String>? onAction;

  static const double _besideFrom = 448;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final beside = constraints.maxWidth >= _besideFrom;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: switch (beside) {
          true => Spacing.d16,
          false => Spacing.d20,
        },
        children: [
          for (final step in onboarding01Steps)
            _StepRow(
              step: step,
              done: done.contains(step.id),
              beside: beside,
              onChanged: (value) => onDoneChange(step.id, value),
              onAction: () => onAction?.call(step.id),
            ),
        ],
      );
    },
  );
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.done,
    required this.beside,
    required this.onChanged,
    required this.onAction,
  });

  final Onboarding01Step step;
  final bool done;
  final bool beside;
  final ValueChanged<bool> onChanged;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final action = Button(
      variant: ButtonVariant.outline,
      size: ButtonSize.sm,
      semanticLabel: '${step.action}, ${step.title.toLowerCase()}',
      onPressed: onAction,
      child: Text(step.action),
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Label(
          onPressed: () => onChanged(!done),
          child: Text(
            step.title,
            style: theme.typography
                .face(
                  KevinSansFace.hand,
                  cssSize: 17,
                  cssLineHeight: 24 / 17,
                  fontWeight: FontWeight.w700,
                  color: switch (done) {
                    true => theme.colors.inkMuted,
                    false => theme.colors.ink,
                  },
                )
                .copyWith(
                  decoration: switch (done) {
                    true => TextDecoration.lineThrough,
                    false => TextDecoration.none,
                  },
                ),
          ),
        ),
        Text.rich(
          step.hint,
          style: theme.typography.face(
            KevinSansFace.hand,
            cssSize: 15,
            cssLineHeight: 24 / 15,
            color: theme.colors.inkSoft,
          ),
        ),
        if (!beside)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.d8),
            child: action,
          ),
      ],
    );
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d12,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: Spacing.d2),
          child: Checkbox(
            value: done,
            size: Spacing.d20,
            semanticLabel: step.title,
            onChanged: onChanged,
          ),
        ),
        Expanded(child: text),
      ],
    );
    if (!beside) return row;
    return Row(
      spacing: Spacing.d12,
      children: [
        Expanded(child: row),
        action,
      ],
    );
  }
}
