import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/typography/typography_style.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// [child] (usually a [Text] or [Text.rich]) in one of the
/// [TypographyStyle]s: the shared body of [P], [Lead], [Large], [Small],
/// [Muted], [H3] and [H4].
class TypographyText extends StatelessWidget {
  const TypographyText({
    super.key,
    required this.style,
    required this.child,
    this.header = false,
  });

  final TypographyStyle style;
  final Widget child;

  /// Marks it a heading for screen readers.
  final bool header;

  @override
  Widget build(BuildContext context) => Semantics(
    header: header,
    child: DefaultTextStyle.merge(
      style: style.resolve(LooseleafTheme.of(context)),
      child: child,
    ),
  );
}

/// Body text: 17 px with an airy 1.7 line height.
///
/// Mirrors `P` in upstream `src/components/ui/typography.tsx`.
class P extends StatelessWidget {
  const P({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TypographyText(style: TypographyStyle.p, child: child);
}

/// An introduction line: larger, muted.
///
/// Mirrors `Lead` in upstream `src/components/ui/typography.tsx`.
class Lead extends StatelessWidget {
  const Lead({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TypographyText(style: TypographyStyle.lead, child: child);
}

/// Large bold text.
///
/// Mirrors `Large` in upstream `src/components/ui/typography.tsx`.
class Large extends StatelessWidget {
  const Large({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TypographyText(style: TypographyStyle.large, child: child);
}

/// Small bold print.
///
/// Mirrors `Small` in upstream `src/components/ui/typography.tsx`.
class Small extends StatelessWidget {
  const Small({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TypographyText(style: TypographyStyle.small, child: child);
}

/// Small muted text, for captions.
///
/// Mirrors `Muted` in upstream `src/components/ui/typography.tsx`.
class Muted extends StatelessWidget {
  const Muted({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TypographyText(style: TypographyStyle.muted, child: child);
}

/// A third-level heading in the script face.
///
/// Mirrors `H3` in upstream `src/components/ui/typography.tsx`.
class H3 extends StatelessWidget {
  const H3({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TypographyText(style: TypographyStyle.h3, header: true, child: child);
}

/// A fourth-level heading in the hand face.
///
/// Mirrors `H4` in upstream `src/components/ui/typography.tsx`.
class H4 extends StatelessWidget {
  const H4({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      TypographyText(style: TypographyStyle.h4, header: true, child: child);
}
