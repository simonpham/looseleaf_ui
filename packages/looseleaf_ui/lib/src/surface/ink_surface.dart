import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/ink_state.dart';
import 'package:looseleaf_ui/src/surface/ink_surface_motion.dart';
import 'package:looseleaf_ui/src/surface/ink_surface_painter.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Draws an ink frame behind [child], sized to it, and shows the layers that
/// match [states] with Looseleaf's transitions: layers fade in and out,
/// `checked` pops in, the frame tilts on hover, `fill` parts misregister,
/// and the rest layer sinks when pressed.
///
/// The Flutter side of upstream `<Ink>` (`src/lib/ink/react/ink-layer.tsx`).
/// Frames come from [cache], keyed like upstream `frameKey`, so surfaces with
/// the same source, seed and size share one drawing.
class InkSurface extends StatefulWidget {
  const InkSurface({
    super.key,
    required this.source,
    required this.seed,
    this.states = const {},
    this.child,
    this.cache,
    this.pad,
    this.currentColor,
    this.sinkSelf = false,
    this.eagerLayers = const {},
    this.still,
  });

  /// What draws the frame.
  final InkSource source;

  /// The drawing seed; the same seed draws the same strokes.
  final String seed;

  /// The widget's current states.
  final Set<InkState> states;

  final Widget? child;

  /// Defaults to [InkFrameCache.shared].
  final InkFrameCache? cache;

  /// A fixed pad overriding the source's.
  final double? pad;

  /// `currentColor`; defaults to the ambient text color, then the ink token.
  final Color? currentColor;

  /// Press sinks sideways only (`data-ink-sink="self"`).
  final bool sinkSelf;

  /// Lazy layers to draw up front instead of on first use. At the `hi` tier
  /// every lazy layer is drawn up front.
  final Set<String> eagerLayers;

  /// Whether the frame stays put on hover; defaults to the theme's.
  final bool? still;

  @override
  State<InkSurface> createState() => _InkSurfaceState();
}

class _InkSurfaceState extends State<InkSurface> with TickerProviderStateMixin {
  late final InkSurfaceMotion _motion = InkSurfaceMotion(this);
  final Set<String> _triggered = {};
  late Listenable _repaint;
  bool _hasHover = false;
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    _repaint = Listenable.merge([_motion.listenable, InkTextures.instance]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
    _animate = true;
  }

  @override
  void didUpdateWidget(InkSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final theme = LooseleafTheme.of(context);
    final reduced =
        theme.motion == LooseleafMotion.reduced ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    for (final state in widget.states) {
      if (widget.source.lazyLayers.contains(state.layer)) {
        _triggered.add(state.layer);
      }
    }
    final created = _motion.update(
      widget.states,
      hasHover: _hasHover,
      still: widget.still ?? theme.still,
      animate: _animate && !reduced,
    );
    if (created) {
      _repaint = Listenable.merge([_motion.listenable, InkTextures.instance]);
    }
  }

  void _onFrame(InkFrame frame) {
    _hasHover = frame.has(InkLayers.hover);
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final lazy = switch (theme.effectiveTier) {
      LooseleafTier.hi => widget.source.lazyLayers,
      LooseleafTier.lo => {...widget.eagerLayers, ..._triggered},
    };
    return CustomPaint(
      painter: InkSurfacePainter(
        source: widget.source,
        cache: widget.cache ?? InkFrameCache.shared,
        seed: widget.seed,
        theme: theme,
        currentColor:
            widget.currentColor ??
            DefaultTextStyle.of(context).style.color ??
            theme.colors.ink,
        states: widget.states,
        lazy: lazy,
        motion: _motion,
        sinkSelf: widget.sinkSelf,
        pad: widget.pad,
        onFrame: _onFrame,
        repaint: _repaint,
      ),
      child: widget.child ?? const SizedBox.expand(),
    );
  }
}
