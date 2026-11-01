import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/bookmark/bookmark.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A ribbon bookmark you press, 32 × 48 px with a hit area 6 px larger all
/// round. Unpressed, a dashed pencil ghost of a ribbon marks the place;
/// pressed ([value] true), the woven, edge-stitched ribbon hangs there in
/// its [tone] and casts a short shadow. Hover washes the ribbon's colour in.
///
/// It is a toggle button: tap, Enter and Space call [onChanged] with the
/// next value, and screen readers hear [semanticLabel] (say what it saves)
/// with the pressed state. Keyboard focus draws the focus ring round the
/// box.
///
/// ```dart
/// Bookmark(
///   value: saved,
///   onChanged: (value) => setState(() => saved = value),
///   semanticLabel: 'Save this article',
/// )
/// ```
///
/// Mirrors `Bookmark` in upstream `src/components/ui/bookmark.tsx`.
class Bookmark extends StatefulWidget {
  const Bookmark({
    super.key,
    required this.value,
    this.onChanged,
    this.tone = Accent.tomato,
    this.disabled = false,
    this.width = Spacing.d32,
    this.height = Spacing.d48,
    this.tilt = true,
    this.tiltDegrees,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel = 'Bookmark',
    this.forcedStates = const {},
  });

  /// The largest seeded turn, in degrees.
  static const double tiltMax = 1.4;

  /// Pressed: the ribbon hangs.
  final bool value;

  /// Called with the next value on tap, Enter and Space. A null callback
  /// does not disable the bookmark; [disabled] does.
  final ValueChanged<bool>? onChanged;

  /// The ribbon's colour.
  final Accent tone;

  /// A pale ghost that cannot be pressed, out of the tab order.
  final bool disabled;

  /// The box's width; upstream's `w-8`.
  final double width;

  /// The box's height; upstream's `h-12`.
  final double height;

  /// False hangs it straight.
  final bool tilt;

  /// A fixed turn in degrees; seeded within 1.4° when null.
  final double? tiltDegrees;

  /// Pins the weave, the ghost and the turn.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name: what the bookmark saves. It stays the same in
  /// both states; the pressed state is announced on its own.
  final String semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Bookmark> createState() => _BookmarkState();
}

class _BookmarkState extends State<Bookmark> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final seed = inkSeed(widget.seed);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, Bookmark.tiltMax),
    };
    final params = BookmarkParams(
      tone: widget.tone,
      mode: BookmarkMode.toggle,
      disabled: widget.disabled,
    );
    final source = RecipeInkSource(
      bookmarkRecipe,
      params,
      json: params.toJson(),
    );
    return Semantics(
      container: true,
      button: true,
      toggled: widget.value,
      enabled: !widget.disabled,
      label: widget.semanticLabel,
      child: InkInteraction(
        enabled: !widget.disabled,
        onActivate: () => widget.onChanged?.call(!widget.value),
        states: {...widget.forcedStates, if (widget.value) InkState.checked},
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        disabledMouseCursor: SystemMouseCursors.forbidden,
        hitSlop: const EdgeInsets.all(Spacing.d6),
        builder: (context, states) => SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              Transform.rotate(
                angle: PaperInk.tilt(context, degrees),
                child: BookmarkShadow(
                  cast: widget.value && !widget.disabled,
                  child: InkSurface(source: source, seed: seed, states: states),
                ),
              ),
              if (states.contains(InkState.focused)) const _FocusRing(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusRing extends StatelessWidget {
  const _FocusRing();

  @override
  Widget build(BuildContext context) {
    final focus = LooseleafTheme.of(context).colors.focus;
    return Positioned(
      left: -Spacing.d4,
      top: -Spacing.d4,
      right: -Spacing.d4,
      bottom: -Spacing.d4,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: focus, width: Spacing.d2),
          ),
        ),
      ),
    );
  }
}
