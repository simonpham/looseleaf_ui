import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' show MarkerTone;
import 'package:looseleaf_ui/src/components/marker/marker_variant.dart';

/// Tells a [Marker]'s parts which variant and tone they sit in, like
/// upstream's `group/marker` data attributes.
class MarkerScope extends InheritedWidget {
  const MarkerScope({
    super.key,
    required this.variant,
    required this.tone,
    required super.child,
  });

  final MarkerVariant variant;
  final MarkerTone tone;

  /// The nearest scope, or null outside a marker.
  static MarkerScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MarkerScope>();

  @override
  bool updateShouldNotify(MarkerScope oldWidget) =>
      oldWidget.variant != variant || oldWidget.tone != tone;
}
