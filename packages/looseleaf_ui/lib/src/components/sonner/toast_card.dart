import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/breadcrumb/breadcrumb.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sonner/sonner.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What sits on top of a toast's paper.
enum ToastDecoration {
  none,

  /// A strip of kraft tape across the top.
  tape,

  /// A red push pin at the top.
  pin,
}

/// One toast: a slip of paper (or a sticky, or a guest check, by type)
/// with an icon, a bold title, a muted description and its buttons.
///
/// Mirrors the toast class names of upstream `src/components/ui/sonner.tsx`.
class ToastCard extends StatelessWidget {
  const ToastCard({
    super.key,
    required this.toast,
    required this.onClose,
    this.closeButton = false,
    this.decoration = ToastDecoration.none,
    this.showContent = true,
  });

  final ToastData toast;

  /// Closes the toast (after an action, a cancel or the close button).
  final VoidCallback onClose;

  /// Shows the small × in the top end corner.
  final bool closeButton;
  final ToastDecoration decoration;

  /// False hides the writing, for a toast tucked behind the front one.
  final bool showContent;

  /// `--width`: `min(360px, 100vw - 32px)`.
  static const double width = 360;

  /// `p-4 compact:p-3.5 calm:p-3`.
  static const _padding = ByDensity(
    comfortable: Spacing.d16,
    compact: Spacing.d14,
    calm: Spacing.d12,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final type = toast.type;
    final decorated = switch (calm) {
      true => ToastDecoration.none,
      false => decoration,
    };
    return Semantics(
      container: true,
      liveRegion: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Paper(
            stock: type.stock,
            shadow: type.shadow,
            tiltDegrees: type.tilt,
            seed: 'toast-${toast.id}',
            tape: switch (decorated) {
              ToastDecoration.tape => PaperTape.top,
              _ => null,
            },
            tapeKind: TapeKind.kraft,
            fastener: switch (decorated) {
              ToastDecoration.pin => FastenerKind.pin,
              _ => null,
            },
            padding: EdgeInsets.all(_padding.of(context)),
            child: AnimatedOpacity(
              opacity: switch (showContent) {
                true => 1,
                false => 0,
              },
              duration: InkMotion.of(context, InkMotion.fade),
              child: _content(context, theme),
            ),
          ),
          if (closeButton && toast.dismissible)
            PositionedDirectional(
              top: Spacing.d6,
              end: Spacing.d6,
              child: _Close(onPressed: _closeBy(toast.onDismiss)),
            ),
        ],
      ),
    );
  }

  VoidCallback _closeBy(VoidCallback? callback) => () {
    callback?.call();
    onClose();
  };

  Widget _content(BuildContext context, LooseleafThemeData theme) {
    final colors = theme.colors;
    final type = toast.type;
    final icon = toast.icon ?? _icon(type);
    final description = toast.description;
    final action = toast.action;
    final cancel = toast.cancel;
    return InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 15,
        color: colors.ink,
      ),
      iconSize: Spacing.d20,
      child: Row(
        spacing: Spacing.d12,
        children: [
          ?icon,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d2,
              children: [
                Text(
                  toast.title,
                  style: theme.typography.face(
                    KevinSansFace.hand,
                    cssSize: 15,
                    cssLineHeight: 1.375,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (description != null)
                  Text(
                    description,
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 14,
                      cssLineHeight: 1.375,
                      color: colors.inkMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (cancel != null)
            _Cancel(label: cancel.label, onPressed: _closeBy(cancel.onPressed)),
          if (action != null)
            _Action(label: action.label, onPressed: _closeBy(action.onPressed)),
        ],
      ),
    );
  }

  static Widget? _icon(ToastType type) {
    final name = type.icon;
    if (name == null) return null;
    final icon = InkIcon(name, size: Spacing.d20);
    if (type != ToastType.loading) return icon;
    return _Spin(child: icon);
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      button: true,
      child: InkInteraction(
        onActivate: onPressed,
        builder: (context, states) => TweenAnimationBuilder<double>(
          tween: Tween(
            end: switch (states.contains(InkState.pressed)) {
              true => InkMotion.pressSink,
              false => 0,
            },
          ),
          duration: InkMotion.of(context, InkMotion.press),
          builder: (context, sink, child) =>
              Transform.translate(offset: Offset(0, sink), child: child),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colors.hiSelect,
              borderRadius: BreadcrumbLink.swipeCorners,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: Spacing.d24),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.d10,
                  vertical: Spacing.d2,
                ),
                child: Center(
                  widthFactor: 1,
                  child: Text(
                    label,
                    softWrap: false,
                    style: theme.typography.face(
                      KevinSansFace.hand,
                      cssSize: 14,
                      cssLineHeight: 20 / 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.selectionText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Cancel extends StatelessWidget {
  const _Cancel({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      button: true,
      child: InkInteraction(
        onActivate: onPressed,
        builder: (context, states) {
          final color = switch (states.contains(InkState.hovered)) {
            true => theme.colors.ink,
            false => theme.colors.inkMuted,
          };
          return ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Spacing.d24),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.d8,
                vertical: Spacing.d2,
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  softWrap: false,
                  style: theme.typography
                      .face(
                        KevinSansFace.hand,
                        cssSize: 14,
                        cssLineHeight: 20 / 14,
                        color: color,
                      )
                      .copyWith(
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.wavy,
                        decorationColor: color,
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Close extends StatelessWidget {
  const _Close({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      button: true,
      label: 'Close toast',
      child: InkInteraction(
        onActivate: onPressed,
        builder: (context, states) => DecoratedBox(
          decoration: BoxDecoration(
            color: switch (states.contains(InkState.hovered)) {
              true => theme.colors.hiSelect,
              false => theme.colors.hiSelect.withValues(alpha: 0),
            },
            borderRadius: BreadcrumbLink.swipeCorners,
          ),
          child: SizedBox.square(
            dimension: Spacing.d24,
            child: Center(
              child: InkIcon('x', size: Spacing.d14, color: theme.colors.ink),
            ),
          ),
        ),
      ),
    );
  }
}

class _Spin extends StatefulWidget {
  const _Spin({required this.child});

  final Widget child;

  @override
  State<_Spin> createState() => _SpinState();
}

class _SpinState extends State<_Spin> with SingleTickerProviderStateMixin {
  /// Tailwind's `animate-spin`.
  static const Duration _turn = Duration(seconds: 1);

  late final AnimationController _clock;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(
      vsync: this,
      duration: _turn,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (InkMotion.reducedIn(context)) {
      _clock.stop();
      return;
    }
    if (!_clock.isAnimating) _clock.repeat();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _clock, child: widget.child);
}
