import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// What a [TearOff] tells its parts.
///
/// Mirrors `useTearOff` in upstream `src/components/ui/tear-off.tsx`.
class TearOffScope extends InheritedWidget {
  const TearOffScope({
    super.key,
    required this.torn,
    required this.gone,
    required this.restored,
    required this.orientation,
    required this.disabled,
    required this.tear,
    required super.child,
  });

  /// Whether the stub has come off.
  final bool torn;

  /// Whether the torn stub has finished falling and left the layout.
  final bool gone;

  /// Whether the stub was just put back (it drops in).
  final bool restored;

  /// [Axis.horizontal] puts the stub after the body, [Axis.vertical]
  /// under it.
  final Axis orientation;

  final bool disabled;

  /// Tears the stub off; nothing once torn or when disabled.
  final VoidCallback tear;

  /// Which side of the body is perforated, and which side of the stub.
  ({SheetSide body, SheetSide stub}) sides(TextDirection direction) =>
      switch ((orientation, direction)) {
        (Axis.vertical, _) => (body: SheetSide.bottom, stub: SheetSide.top),
        (Axis.horizontal, TextDirection.rtl) => (
          body: SheetSide.left,
          stub: SheetSide.right,
        ),
        (Axis.horizontal, TextDirection.ltr) => (
          body: SheetSide.right,
          stub: SheetSide.left,
        ),
      };

  /// [side] perforated, or torn once the stub is off; the rest cut.
  EdgeSpec edge(SheetSide side) {
    final kind = switch (torn) {
      true => EdgeKind.torn,
      false => EdgeKind.perf,
    };
    return switch (side) {
      SheetSide.top => EdgeSpec(top: kind),
      SheetSide.right => EdgeSpec(right: kind),
      SheetSide.bottom => EdgeSpec(bottom: kind),
      SheetSide.left => EdgeSpec(left: kind),
    };
  }

  /// The enclosing tear-off's scope.
  static TearOffScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TearOffScope>();
    if (scope == null) {
      throw FlutterError('TearOff parts must be used inside a TearOff.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(TearOffScope oldWidget) =>
      oldWidget.torn != torn ||
      oldWidget.gone != gone ||
      oldWidget.restored != restored ||
      oldWidget.orientation != orientation ||
      oldWidget.disabled != disabled ||
      oldWidget.tear != tear;
}
