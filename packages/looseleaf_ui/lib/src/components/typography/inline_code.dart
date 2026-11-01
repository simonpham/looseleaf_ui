import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A short piece of code in running text: monospace at 85% on a muted
/// patch with uneven corners. Use it in a [WidgetSpan] inside [Text.rich],
/// or on its own.
///
/// ```dart
/// Text.rich(TextSpan(children: [
///   TextSpan(text: 'Run '),
///   WidgetSpan(
///     alignment: PlaceholderAlignment.baseline,
///     baseline: TextBaseline.alphabetic,
///     child: InlineCode('npm run notes'),
///   ),
/// ]))
/// ```
///
/// Mirrors `InlineCode` in upstream `src/components/ui/typography.tsx`.
class InlineCode extends StatelessWidget {
  const InlineCode(this.code, {super.key});

  final String code;

  /// `--font-mono`.
  static const List<String> monoFamilies = [
    'IBM Plex Mono',
    'SF Mono',
    'Menlo',
    'monospace',
  ];

  /// `text-[0.85em]`.
  static const double _scale = 0.85;

  /// `[border-radius:2px_6px_3px_5px/5px_2px_6px_3px]`.
  static const BorderRadius _corners = BorderRadius.only(
    topLeft: Radius.elliptical(Spacing.d2, 5),
    topRight: Radius.elliptical(Spacing.d6, Spacing.d2),
    bottomRight: Radius.elliptical(3, Spacing.d6),
    bottomLeft: Radius.elliptical(5, 3),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final ambient = DefaultTextStyle.of(context).style;
    final size = (ambient.fontSize ?? theme.typography.bodySize) * _scale;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.paperShade,
        borderRadius: _corners,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size / _scale * 0.35,
          vertical: size / _scale * 0.15,
        ),
        child: Text(
          code,
          style: TextStyle(
            fontFamily: monoFamilies.first,
            fontFamilyFallback: monoFamilies.sublist(1),
            fontSize: size,
            fontWeight: FontWeight.w500,
            height: 1.2,
            color: theme.colors.ink,
          ),
        ),
      ),
    );
  }
}
