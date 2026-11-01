import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A field's error in red over a wavy red pencil underline (straight when
/// calm), announced as it appears. Give it a [child], or [errors]: one
/// message is a line, several are a bulleted list, duplicates collapse.
/// With neither it draws nothing.
///
/// ```dart
/// FieldError(errors: ['Use at least 8 characters.', 'Add a number.'])
/// ```
///
/// Mirrors `FieldError` in upstream `src/components/ui/field.tsx`.
class FieldError extends StatefulWidget {
  const FieldError({super.key, this.child, this.errors, this.seed});

  /// The message; wins over [errors].
  final Widget? child;

  /// Messages; nulls are skipped.
  final List<String?>? errors;

  /// Pins the underline's hand.
  final String? seed;

  @override
  State<FieldError> createState() => _FieldErrorState();
}

class _FieldErrorState extends State<FieldError> with InkSeed {
  Widget? _content() {
    if (widget.child case final child?) return child;
    final messages = {
      for (final message in widget.errors ?? const <String?>[]) ?message,
    }.toList();
    if (messages.isEmpty) return null;
    if (messages.length == 1) return Text(messages.first);
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: Spacing.d16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d4,
        children: [
          for (final message in messages)
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d6,
              children: [
                const Text('•'),
                Flexible(child: Text(message)),
              ],
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      cssLineHeight: 20 / 14,
      color: theme.colors.red,
    );
    final content = _content();
    if (content == null) return const SizedBox.shrink();
    const params = NoParams();
    return Semantics(
      container: true,
      liveRegion: true,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: InkContent(
          style: style,
          child: InkSurface(
            source: RecipeInkSource(fieldErrorRecipe, params),
            seed: inkSeed(widget.seed),
            still: true,
            child: Padding(
              padding: const EdgeInsets.only(bottom: Spacing.d4),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
