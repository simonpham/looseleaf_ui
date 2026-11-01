import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/avatar/avatar_size.dart';

/// What an [Avatar] hands its parts: its size, and whether its image has
/// loaded (the fallback hides once it has).
class AvatarScope extends InheritedWidget {
  const AvatarScope({
    super.key,
    required this.size,
    required this.loaded,
    required this.onLoaded,
    required super.child,
  });

  final AvatarSize size;
  final bool loaded;

  /// Called by [AvatarImage] with whether its image is showing.
  final ValueChanged<bool> onLoaded;

  static AvatarScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AvatarScope>();

  @override
  bool updateShouldNotify(AvatarScope oldWidget) =>
      oldWidget.size != size ||
      oldWidget.loaded != loaded ||
      oldWidget.onLoaded != onLoaded;
}

/// What an [AvatarGroup] hands its avatars: their size and the color of
/// the ring that cuts each one out of the last.
class AvatarGroupScope extends InheritedWidget {
  const AvatarGroupScope({
    super.key,
    required this.size,
    required this.cut,
    required super.child,
  });

  final AvatarSize size;
  final Color cut;

  static AvatarGroupScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AvatarGroupScope>();

  @override
  bool updateShouldNotify(AvatarGroupScope oldWidget) =>
      oldWidget.size != size || oldWidget.cut != cut;
}
