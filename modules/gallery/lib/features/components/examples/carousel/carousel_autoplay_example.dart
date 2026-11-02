import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class CarouselAutoplayExample extends StatefulWidget {
  const CarouselAutoplayExample({super.key});

  @override
  State<CarouselAutoplayExample> createState() =>
      _CarouselAutoplayExampleState();
}

class _CarouselAutoplayExampleState extends State<CarouselAutoplayExample> {
  static const _maxWidth = 320 + 2 * Carousel.arrowRoom;

  bool _paused = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final reduced = InkMotion.reducedIn(context);
    final playing = !_paused && !reduced;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d12,
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onFocusChange: (focused) => setState(() => _focused = focused),
              child: Carousel(
                semanticLabel: 'Numbered cards, playing by themselves',
                seed: 'autoplay',
                children: [
                  CarouselContent(
                    children: [
                      for (var i = 0; i < 5; i++)
                        CarouselItem(
                          semanticLabel: '${i + 1} of 5',
                          child: Padding(
                            padding: const EdgeInsets.all(Spacing.d4),
                            child: Card(
                              seed: 'auto$i',
                              padding: EdgeInsets.zero,
                              children: [
                                AspectRatio(
                                  aspectRatio: 1,
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: theme.typography.face(
                                        KevinSansFace.script,
                                        cssSize: 60,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const CarouselPrevious(),
                  const CarouselNext(),
                  _Autoplay(
                    delay: const Duration(milliseconds: 2200),
                    running: playing && !_hovered && !_focused,
                  ),
                ],
              ),
            ),
          ),
          switch (reduced) {
            true => Text(
              'Autoplay is off because you asked for less motion. Use the arrows.',
              textAlign: TextAlign.center,
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            ),
            false => Button(
              variant: ButtonVariant.ghost,
              size: ButtonSize.sm,
              leading: InkIcon(switch (playing) {
                true => 'pause',
                false => 'play',
              }),
              onPressed: () => setState(() => _paused = !_paused),
              child: Text(switch (playing) {
                true => 'Pause autoplay',
                false => 'Play autoplay',
              }),
            ),
          },
        ],
      ),
    );
  }
}

/// Steps the [Carousel] above it every [delay] while [running], back to
/// the first slide after the last.
class _Autoplay extends StatefulWidget {
  const _Autoplay({required this.delay, required this.running});

  final Duration delay;
  final bool running;

  @override
  State<_Autoplay> createState() => _AutoplayState();
}

class _AutoplayState extends State<_Autoplay> {
  Timer? _timer;

  void _sync() {
    _timer?.cancel();
    _timer = null;
    if (!widget.running) return;
    _timer = Timer.periodic(widget.delay, (_) => _step());
  }

  void _step() {
    final carousel = Carousel.maybeOf(context);
    if (carousel == null) return;
    if (carousel.canScrollNext) {
      carousel.scrollNext();
      return;
    }
    carousel.scrollTo(0);
  }

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Autoplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.running != widget.running) _sync();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
