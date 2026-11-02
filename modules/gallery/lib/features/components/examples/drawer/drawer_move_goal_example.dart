import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

const _data = [400, 300, 200, 300, 200, 278, 189, 239, 300, 200, 278, 189, 349];

class DrawerMoveGoalExample extends StatefulWidget {
  const DrawerMoveGoalExample({super.key});

  @override
  State<DrawerMoveGoalExample> createState() => _DrawerMoveGoalExampleState();
}

class _DrawerMoveGoalExampleState extends State<DrawerMoveGoalExample> {
  int _goal = 350;

  void _move(int by) => setState(() => _goal = (_goal + by).clamp(200, 400));

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Drawer(
      content: DrawerContent(
        seed: 'goal',
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DrawerHeader(
                    children: [
                      DrawerTitle(Text('Move goal')),
                      DrawerDescription(Text('Set your daily activity goal.')),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Spacing.d16,
                      Spacing.d16,
                      Spacing.d16,
                      0,
                    ),
                    child: Column(
                      spacing: Spacing.d16,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: Spacing.d16,
                          children: [
                            Button(
                              variant: ButtonVariant.outline,
                              size: ButtonSize.icon,
                              shape: ButtonShape.pill,
                              disabled: _goal <= 200,
                              semanticLabel: 'Decrease',
                              onPressed: () => _move(-10),
                              child: const InkIcon('minus'),
                            ),
                            Column(
                              children: [
                                Text(
                                  '$_goal',
                                  style: theme.typography
                                      .title(cssSize: 72)
                                      .copyWith(
                                        height: 1,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                ),
                                Text(
                                  'Calories/day',
                                  style: theme.typography.face(
                                    KevinSansFace.type,
                                    cssSize: 11.2,
                                    color: theme.colors.inkMuted,
                                  ),
                                ),
                              ],
                            ),
                            Button(
                              variant: ButtonVariant.outline,
                              size: ButtonSize.icon,
                              shape: ButtonShape.pill,
                              disabled: _goal >= 400,
                              semanticLabel: 'Increase',
                              onPressed: () => _move(10),
                              child: const InkIcon('plus'),
                            ),
                          ],
                        ),
                        ExcludeSemantics(
                          child: SizedBox(
                            height: Spacing.d64,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: Spacing.d4,
                              children: [
                                for (final value in _data)
                                  FractionallySizedBox(
                                    heightFactor: value / 400,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: theme.colors.pencilMark
                                            .withValues(alpha: 0.35),
                                        border: Border(
                                          top: BorderSide(
                                            color: theme.colors.pencilMark,
                                          ),
                                          left: BorderSide(
                                            color: theme.colors.pencilMark,
                                          ),
                                          right: BorderSide(
                                            color: theme.colors.pencilMark,
                                          ),
                                        ),
                                      ),
                                      child: const SizedBox(width: Spacing.d10),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DrawerFooter(
                    children: [
                      Button(onPressed: () {}, child: const Text('Submit')),
                      DrawerClose(
                        builder: (context, close) => Button(
                          variant: ButtonVariant.outline,
                          onPressed: close,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      child: DrawerTrigger.builder(
        builder: (context, drawer) => Button(
          variant: ButtonVariant.outline,
          onPressed: drawer.show,
          child: const Text('Open drawer'),
        ),
      ),
    );
  }
}
