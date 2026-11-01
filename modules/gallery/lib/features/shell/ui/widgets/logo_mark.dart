import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The notebook-page logo: a tilted sheet with blue rules, a marker swipe,
/// a red margin and three punched holes.
///
/// Mirrors `LogoMark` in upstream `src/docs/shell/LogoMark.tsx`.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = Spacing.d34});

  final double size;

  static final InkDocument _document = InkDocument.parse(_markup);

  static String get _markup {
    const rules = [14.5, 20.5, 26.5, 32.5, 38.5];
    const holes = [12.8, 24.4, 36];
    return [
      '<g transform="rotate(-6 26 24)">',
      '<path d="M14.6 5.1Q26.4 4.5 38.6 4.8Q41 4.9 41.1 7.3Q41.6 24.4 41.4 40.9Q41.3 43.3 38.9 43.4Q25.8 44 14.2 43.8Q11.8 43.7 11.8 41.4Q11.6 24 12 7.6Q12.1 5.2 14.6 5.1Z" fill="var(--ll-paper)" stroke="var(--ll-ink)" stroke-width="2.2" stroke-linejoin="round"/>',
      for (final y in rules)
        '<path d="M22.8 ${y}H38.4" stroke="var(--ll-ink-you)" stroke-opacity="0.5" stroke-width="1.2" stroke-linecap="round" fill="none"/>',
      '<path d="M24.2 20.1Q30.2 19.4 35.6 20" stroke="var(--ll-marker)" stroke-opacity="0.9" stroke-width="3.4" stroke-linecap="round" fill="none"/>',
      '<path d="M20.6 5.8L20.8 43" stroke="var(--ll-red)" stroke-opacity="0.85" stroke-width="1.3" stroke-linecap="round" fill="none"/>',
      for (final y in holes)
        '<circle cx="16.2" cy="$y" r="2.1" fill="var(--ll-desk)" stroke="var(--ll-ink)" stroke-width="1.5"/>',
      '</g>',
    ].join();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _LogoPainter(LooseleafTheme.of(context), size),
    ),
  );
}

class _LogoPainter extends CustomPainter {
  _LogoPainter(this.theme, this.size);

  final LooseleafThemeData theme;
  final double size;

  @override
  void paint(Canvas canvas, Size _) {
    canvas.scale(size / 48);
    InkPainter(
      LogoMark._document,
      InkPaintContext(theme: theme),
    ).paintLayer(canvas, 'rest');
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.size != size;
}
