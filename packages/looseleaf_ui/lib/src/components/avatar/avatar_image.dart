import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/avatar/avatar_scope.dart';

/// The picture of an [Avatar], cut to a circle. It shows once it has
/// loaded; until then, and if it fails, the [AvatarFallback] does.
///
/// Mirrors `AvatarImage` in upstream `src/components/ui/avatar.tsx`.
class AvatarImage extends StatelessWidget {
  const AvatarImage({super.key, required this.image, this.semanticLabel});

  final ImageProvider image;

  /// The picture's description (`alt`); decorative when null.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scope = AvatarScope.maybeOf(context);
    return ClipOval(
      child: Image(
        image: image,
        fit: BoxFit.cover,
        semanticLabel: semanticLabel,
        excludeFromSemantics: semanticLabel == null,
        frameBuilder: (context, child, frame, _) {
          final loaded = frame != null;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => scope?.onLoaded(loaded),
          );
          if (!loaded) return const SizedBox.shrink();
          return child;
        },
        errorBuilder: (context, error, stack) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => scope?.onLoaded(false),
          );
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
