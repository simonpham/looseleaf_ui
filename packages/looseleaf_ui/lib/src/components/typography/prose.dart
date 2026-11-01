import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/typography/typography.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A column of long-form content set like an article: 17 px hand text at
/// 1.7, at most 64 characters wide, with 1.15 em between the [children].
/// Fill it with the typography parts ([H1], [P], [Blockquote],
/// [TypographyList], …).
///
/// ```dart
/// const Prose(children: [
///   H1(child: Text('Field notes')),
///   P(child: Text('Most of what I remember from a book is in the margins.')),
/// ])
/// ```
///
/// Mirrors `Prose` in upstream `src/components/ui/typography.tsx`, whose
/// stylesheet styles raw HTML; here the parts carry their own styles.
class Prose extends StatelessWidget {
  const Prose({super.key, required this.children});

  final List<Widget> children;

  /// `max-width: 64ch`, in em of the body size.
  static const double _maxWidthEm = 64 * 0.5;

  /// `margin-block: 1.15em`.
  static const double _gapEm = 1.15;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final style = TypographyStyle.p
        .resolve(theme)
        .copyWith(
          color: theme.colors.ink,
        );
    final em = TypographyStyle.p.cssSize;
    return DefaultTextStyle.merge(
      style: style,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: em * _maxWidthEm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          spacing: em * _gapEm,
          children: children,
        ),
      ),
    );
  }
}
