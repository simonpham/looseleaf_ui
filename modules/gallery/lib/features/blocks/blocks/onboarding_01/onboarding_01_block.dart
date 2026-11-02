import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/onboarding_01/onboarding_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A setup checklist on a taped card: five steps to tick off, a tally and a
/// progress bar, and Stubby writing along. Finishing them stamps "All set"
/// and throws confetti; "Skip for now" folds it into a single link.
///
/// Mirrors upstream `src/blocks/onboarding-01/page.tsx`.
class Onboarding01Block extends StatefulWidget {
  const Onboarding01Block({
    super.key,
    this.defaultDone = const ['name', 'invite'],
    this.onDoneChange,
    this.onAction,
  });

  final List<String> defaultDone;
  final ValueChanged<List<String>>? onDoneChange;
  final ValueChanged<String>? onAction;

  @override
  State<Onboarding01Block> createState() => _Onboarding01BlockState();
}

class _Onboarding01BlockState extends State<Onboarding01Block> {
  static const double _maxWidth = 576;
  static const double _wideFrom = 576;

  late final Set<String> _done = {
    for (final step in onboarding01Steps)
      if (widget.defaultDone.contains(step.id)) step.id,
  };
  bool _hidden = false;

  void _change(String id, bool done) {
    setState(() {
      if (done) {
        _done.add(id);
        return;
      }
      _done.remove(id);
    });
    widget.onDoneChange?.call([
      for (final step in onboarding01Steps)
        if (_done.contains(step.id)) step.id,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final total = onboarding01Steps.length;
    final count = _done.length;
    final all = count == total;
    if (_hidden) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.d16,
          vertical: Spacing.d40,
        ),
        child: Center(
          child: Button(
            variant: ButtonVariant.link,
            autofocus: true,
            onPressed: () => setState(() => _hidden = false),
            child: Text('Show the setup checklist ($count of $total done)'),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: switch (constraints.maxWidth >= _wideFrom) {
          true => const EdgeInsets.symmetric(
            horizontal: Spacing.d32,
            vertical: Spacing.d56,
          ),
          false => const EdgeInsets.symmetric(
            horizontal: Spacing.d28,
            vertical: Spacing.d40,
          ),
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Confetti(
              active: all,
              options: const ConfettiOptions(count: 80),
              child: Card(
                tape: PaperTape.top,
                tapeKind: TapeKind.washiDots,
                seed: 'onboarding-card',
                children: [
                  CardHeader(
                    children: [
                      const CardTitle(Text('Let’s get you set up')),
                      const CardDescription(
                        Text('Five small things. Tick them off as you go.'),
                      ),
                      CardAction(
                        child: Mascot(
                          pose: switch (all) {
                            true => 'celebrate',
                            false => 'write',
                          },
                          size: 80,
                        ),
                      ),
                    ],
                  ),
                  CardContent(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d24,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          spacing: Spacing.d8,
                          children: [
                            Row(
                              spacing: Spacing.d16,
                              children: [
                                Semantics(
                                  liveRegion: true,
                                  child: Text.rich(
                                    style: theme.typography.face(
                                      KevinSansFace.hand,
                                      cssSize: 15,
                                      color: theme.colors.inkSoft,
                                    ),
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$count',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colors.ink,
                                          ),
                                        ),
                                        TextSpan(text: ' of $total done'),
                                      ],
                                    ),
                                  ),
                                ),
                                Tally(
                                  count: count,
                                  tone: MarkPen.blue,
                                  label: '$count steps done',
                                ),
                              ],
                            ),
                            Progress(
                              value: count.toDouble(),
                              max: total.toDouble(),
                              tone: switch (all) {
                                true => ProgressTone.green,
                                false => ProgressTone.marker,
                              },
                              semanticLabel: 'Setup progress',
                              semanticValue: '$count of $total steps done',
                            ),
                          ],
                        ),
                        Onboarding01Steps(
                          done: _done,
                          onDoneChange: _change,
                          onAction: widget.onAction,
                        ),
                      ],
                    ),
                  ),
                  CardFooter(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: Spacing.d12,
                    children: switch (all) {
                      true => [
                        const Stamp(
                          text: 'All set',
                          ink: StampPadInk.green,
                          w: 124,
                          h: 46,
                          tilt: -6,
                          seed: 'onboarding-stamp',
                        ),
                        Button(
                          onPressed: () {},
                          child: const Text('Start writing'),
                        ),
                      ],
                      false => [
                        Button(
                          variant: ButtonVariant.ghost,
                          onPressed: () => setState(() => _hidden = true),
                          child: const Text('Skip for now'),
                        ),
                      ],
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
