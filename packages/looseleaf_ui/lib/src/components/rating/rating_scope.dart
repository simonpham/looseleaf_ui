import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/rating/rating_size.dart';

/// What a [Rating] hands its [RatingItem]s: the value shown, the choice,
/// and the radios' focus nodes and callbacks.
///
/// Mirrors `RatingContext` in upstream `src/components/ui/rating.tsx`.
class RatingScope extends InheritedWidget {
  const RatingScope({
    super.key,
    required super.child,
    required this.max,
    required this.allowHalf,
    required this.icon,
    required this.size,
    required this.shown,
    required this.current,
    required this.interactive,
    required this.disabled,
    required this.readOnly,
    required this.invalid,
    required this.tabStop,
    required this.seed,
    required this.label,
    required this.select,
    required this.preview,
    required this.focusNodeFor,
  });

  final int max;
  final bool allowHalf;
  final RatingIcon icon;
  final RatingSize size;

  /// The value drawn: the hover preview, else [current].
  final double shown;

  /// The chosen value.
  final double current;

  /// Neither read-only nor disabled.
  final bool interactive;
  final bool disabled;
  final bool readOnly;
  final bool invalid;

  /// The value whose radio is in the tab order.
  final double tabStop;
  final String seed;

  /// A radio's accessible name.
  final String Function(double value, int max) label;

  /// Chooses a value.
  final ValueChanged<double> select;

  /// Previews a value under the mouse; null ends the preview.
  final ValueChanged<double?> preview;

  /// The focus node of the radio for a value.
  final FocusNode Function(double value) focusNodeFor;

  /// The nearest scope; [RatingItem]s live inside a [Rating].
  static RatingScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RatingScope>();
    if (scope == null) {
      throw FlutterError('RatingItem must be used within a Rating.');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(RatingScope oldWidget) =>
      oldWidget.max != max ||
      oldWidget.allowHalf != allowHalf ||
      oldWidget.icon != icon ||
      oldWidget.size != size ||
      oldWidget.shown != shown ||
      oldWidget.current != current ||
      oldWidget.interactive != interactive ||
      oldWidget.disabled != disabled ||
      oldWidget.readOnly != readOnly ||
      oldWidget.invalid != invalid ||
      oldWidget.tabStop != tabStop ||
      oldWidget.seed != seed ||
      oldWidget.label != label;
}
