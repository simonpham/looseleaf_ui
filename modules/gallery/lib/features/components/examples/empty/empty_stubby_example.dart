import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class EmptyStubbyExample extends StatelessWidget {
  const EmptyStubbyExample({super.key});

  static const _states = [
    (
      pose: 'search',
      title: 'No results',
      text: 'Nothing matches “ghost pepper”. Try a shorter word.',
      action: 'Clear search',
    ),
    (
      pose: 'sleep',
      title: 'All quiet',
      text: 'Nothing is scheduled today. Enjoy it.',
      action: null,
    ),
    (
      pose: 'unplug',
      title: 'You are offline',
      text: 'Changes are kept on this page and sent when the line is back.',
      action: 'Try again',
    ),
  ];

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cards = [
        for (final state in _states)
          Empty(
            seed: state.pose,
            padding: const EdgeInsets.all(Spacing.d16),
            children: [
              EmptyHeader(
                children: [
                  EmptyMedia(pose: state.pose, size: Spacing.d112),
                  EmptyTitle(child: Text(state.title)),
                  EmptyDescription(child: Text(state.text)),
                ],
              ),
              if (state.action case final action?)
                EmptyContent(
                  children: [
                    Button(
                      size: ButtonSize.sm,
                      onPressed: () {},
                      child: Text(action),
                    ),
                  ],
                ),
            ],
          ),
      ];
      if (constraints.maxWidth < 768) {
        return Column(spacing: Spacing.d8, children: cards);
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d8,
        children: [for (final card in cards) Expanded(child: card)],
      );
    },
  );
}
