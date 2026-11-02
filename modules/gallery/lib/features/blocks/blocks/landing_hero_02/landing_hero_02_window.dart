import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The product shot under the hero: a taped page with today's tasks to
/// tick (margin notes from 672 px wide, a tally, a progress line and an
/// "All done" stamp once every box is ticked) and a "This week" tab, with
/// Stubby peeking over the top.
///
/// Mirrors upstream
/// `src/blocks/landing-hero-02/components/landing-hero-02-window.tsx`.
class LandingHero02Window extends StatefulWidget {
  const LandingHero02Window({super.key});

  @override
  State<LandingHero02Window> createState() => _LandingHero02WindowState();
}

class _LandingHero02WindowState extends State<LandingHero02Window> {
  static const _tasks = [
    (id: 'invoices', label: 'Send the invoices', done: true),
    (id: 'post', label: 'Draft the launch post', done: true),
    (id: 'review', label: 'Review Ada’s pull request', done: false),
    (id: 'offsite', label: 'Book the offsite', done: false),
    (id: 'plant', label: 'Water the plant', done: false),
  ];
  static const _week = [
    (day: 'Mon', value: 100),
    (day: 'Tue', value: 80),
    (day: 'Wed', value: 60),
    (day: 'Thu', value: 20),
    (day: 'Fri', value: 0),
  ];
  static const _people = ['Ada Lovelace', 'Jo Okafor', 'Sam Reyes'];

  static const double _maxWidth = 768;
  static const double _notesWidth = 192;
  static const double _notesGutter = 208;
  static const double _rowHeight = 44;
  static const double _dayWidth = 48;

  final Map<String, bool> _done = {
    for (final task in _tasks) task.id: task.done,
  };

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final count = _done.values.where((done) => done).length;
    final all = count == _tasks.length;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final roomy = width >= 576;
        final notes = width >= 672;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxWidth),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const PositionedDirectional(
                  end: Spacing.d48,
                  top: -91,
                  child: IgnorePointer(child: Mascot(pose: 'peek', size: 112)),
                ),
                Paper(
                  tiltDegrees: 0.5,
                  tape: PaperTape.both,
                  tapeKind: TapeKind.washiStripes,
                  shadow: PaperShadow.lift,
                  seed: 'hero-window',
                  padding: EdgeInsets.fromLTRB(
                    switch (roomy) {
                      true => Spacing.d32,
                      false => Spacing.d20,
                    },
                    Spacing.d20,
                    switch (roomy) {
                      true => Spacing.d32,
                      false => Spacing.d20,
                    },
                    switch (roomy) {
                      true => Spacing.d40,
                      false => Spacing.d24,
                    },
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d16,
                    children: [
                      Row(
                        spacing: Spacing.d16,
                        children: [
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(text: 'penmark '),
                                  TextSpan(
                                    text: '/ week 39',
                                    style: theme.typography.face(
                                      KevinSansFace.hand,
                                      cssSize: 16,
                                      cssLineHeight: 1,
                                      color: theme.colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                              style: theme.typography.face(
                                KevinSansFace.script,
                                cssSize: 24,
                                cssLineHeight: 1,
                                fontWeight: FontWeight.w700,
                                color: theme.colors.ink,
                              ),
                            ),
                          ),
                          AvatarGroup(
                            children: [
                              for (final name in _people)
                                Avatar(children: [AvatarFallback(name: name)]),
                            ],
                          ),
                        ],
                      ),
                      Tabs(
                        defaultValue: 'today',
                        children: [
                          const TabsList(
                            variant: TabsVariant.line,
                            children: [
                              TabsTrigger(value: 'today', child: Text('Today')),
                              TabsTrigger(
                                value: 'week',
                                child: Text('This week'),
                              ),
                            ],
                          ),
                          TabsContent(
                            value: 'today',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: Spacing.d20,
                              children: [
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.only(
                                        end: switch (notes) {
                                          true => _notesGutter,
                                          false => 0,
                                        },
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          for (final task in _tasks)
                                            _task(context, task.id, task.label),
                                        ],
                                      ),
                                    ),
                                    if (notes) ...[
                                      const PositionedDirectional(
                                        end: _notesGutter - _notesWidth,
                                        top: _rowHeight,
                                        width: _notesWidth,
                                        child: IgnorePointer(
                                          child: Align(
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: Callout(
                                              'done before lunch',
                                              seed: 'note-a',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const PositionedDirectional(
                                        end: _notesGutter - _notesWidth,
                                        top: 132,
                                        width: _notesWidth,
                                        child: IgnorePointer(
                                          child: Align(
                                            alignment: AlignmentDirectional
                                                .centerStart,
                                            child: Callout(
                                              'ask Sam first',
                                              seed: 'note-b',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: Spacing.d20,
                                  runSpacing: Spacing.d12,
                                  children: [
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minWidth: Spacing.d160,
                                      ),
                                      child: _progress(context, count, all),
                                    ),
                                    if (all)
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: 1),
                                        duration: InkMotion.of(
                                          context,
                                          InkMotion.pop,
                                        ),
                                        builder: (context, t, child) => Opacity(
                                          opacity: t,
                                          child: Transform.scale(
                                            scale: 1.6 - 0.6 * t,
                                            child: child,
                                          ),
                                        ),
                                        child: const Stamp(
                                          text: 'All done',
                                          ink: StampPadInk.green,
                                          w: 132,
                                          h: 48,
                                          tilt: -6,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          TabsContent(
                            value: 'week',
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: Spacing.d4,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                spacing: Spacing.d12,
                                children: [
                                  for (final day in _week)
                                    Row(
                                      spacing: Spacing.d12,
                                      children: [
                                        SizedBox(
                                          width: _dayWidth,
                                          child: Text(
                                            day.day,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Progress(
                                            value: day.value.toDouble(),
                                            size: ProgressSize.sm,
                                            semanticLabel:
                                                '${day.day}: ${day.value}% done',
                                          ),
                                        ),
                                        SizedBox(
                                          width: _dayWidth,
                                          child: Text(
                                            '${day.value}%',
                                            textAlign: TextAlign.end,
                                            style: theme.typography.face(
                                              KevinSansFace.hand,
                                              cssSize: 14,
                                              cssLineHeight: 20 / 14,
                                              color: theme.colors.inkMuted,
                                            ),
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
                    ],
                  ),
                ),
                if (roomy) ...[
                  const PositionedDirectional(
                    start: -Spacing.d24,
                    bottom: -Spacing.d56,
                    child: IgnorePointer(
                      child: Sticker('party-popper', size: 88, rotate: -14),
                    ),
                  ),
                  const PositionedDirectional(
                    end: -Spacing.d16,
                    bottom: -Spacing.d44,
                    child: IgnorePointer(
                      child: Sticker('rating-five', size: 80, rotate: 9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _task(BuildContext context, String id, String label) {
    final theme = LooseleafTheme.of(context);
    final done = _done[id] ?? false;
    void toggle(bool value) => setState(() => _done[id] = value);
    return SizedBox(
      height: _rowHeight,
      child: Row(
        spacing: Spacing.d12,
        children: [
          Checkbox(value: done, onChanged: toggle, semanticLabel: label),
          Expanded(
            child: Label(
              onPressed: () => toggle(!done),
              child: Text(
                label,
                style: switch (done) {
                  true =>
                    theme.typography
                        .face(
                          KevinSansFace.hand,
                          cssSize: 17,
                          color: theme.colors.inkMuted,
                        )
                        .copyWith(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: theme.colors.inkMuted,
                        ),
                  false => theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 17,
                  ),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _progress(BuildContext context, int count, bool all) {
    final theme = LooseleafTheme.of(context);
    final total = _tasks.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d6,
      children: [
        Row(
          spacing: Spacing.d16,
          children: [
            Semantics(
              liveRegion: true,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '$count',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    TextSpan(text: ' of $total done'),
                  ],
                ),
                style: theme.typography.face(
                  KevinSansFace.hand,
                  cssSize: 15,
                  color: theme.colors.inkSoft,
                ),
              ),
            ),
            Tally(count: count, label: '$count tasks done'),
          ],
        ),
        Progress(
          value: count.toDouble(),
          max: total.toDouble(),
          semanticLabel: 'Tasks done today',
          semanticValue: '$count of $total done',
          tone: switch (all) {
            true => ProgressTone.green,
            false => ProgressTone.marker,
          },
        ),
      ],
    );
  }
}
