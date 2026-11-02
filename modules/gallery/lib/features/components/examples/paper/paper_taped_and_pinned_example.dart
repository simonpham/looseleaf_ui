import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaperTapedAndPinnedExample extends StatelessWidget {
  const PaperTapedAndPinnedExample({super.key});

  static const _wide = 672.0;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final sheets = [
        const Paper(
          tape: PaperTape.both,
          tapeKind: TapeKind.washiDots,
          seed: 'a',
          padding: EdgeInsets.all(Spacing.d20),
          child: _Note(
            title: 'Taped up',
            body: 'two strips, one at each corner',
          ),
        ),
        const Paper(
          stock: StockName.indexCard,
          fastener: FastenerKind.pin,
          seed: 'b',
          padding: EdgeInsets.fromLTRB(
            Spacing.d20,
            Spacing.d12,
            Spacing.d20,
            Spacing.d20,
          ),
          child: _Note(
            title: 'Pinned',
            body: 'a push-pin through the top',
            gap: Spacing.d12,
          ),
        ),
        const Paper(
          stock: StockName.slip,
          fastener: FastenerKind.clip,
          fastenerTone: Accent.sky,
          seed: 'c',
          padding: EdgeInsets.all(Spacing.d20),
          child: _Note(title: 'Clipped', body: 'plastic-coated, sky blue'),
        ),
      ];
      return Padding(
        padding: const EdgeInsets.all(Spacing.d24),
        child: switch (constraints.maxWidth >= _wide) {
          true => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d40,
            children: [
              for (final sheet in sheets) Expanded(child: sheet),
            ],
          ),
          false => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d40,
            children: sheets,
          ),
        },
      );
    },
  );
}

class _Note extends StatelessWidget {
  const _Note({required this.title, required this.body, this.gap = 0});

  final String title;
  final String body;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: Spacing.d128 - Spacing.d40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: gap,
        children: [
          Text(
            title,
            style: theme.typography.face(
              KevinSansFace.script,
              cssSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(body, style: theme.typography.interface(cssSize: 14)),
        ],
      ),
    );
  }
}
