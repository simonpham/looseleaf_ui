import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaperStickyWallExample extends StatelessWidget {
  const PaperStickyWallExample({super.key});

  static const _side = 144.0;
  static const _notes = [
    (
      stock: StockName.stickyYellow,
      head: 'todo',
      body: 'buy more ink',
      curl: true,
    ),
    (
      stock: StockName.stickyGreen,
      head: 'done',
      body: 'book the venue',
      curl: false,
    ),
    (
      stock: StockName.stickyOrange,
      head: 'careful',
      body: 'the glue is wet',
      curl: false,
    ),
    (stock: StockName.stickyPink, head: 'urgent', body: 'call mum', curl: true),
    (
      stock: StockName.stickyBlue,
      head: 'tip',
      body: 'tape it down first',
      curl: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Spacing.d16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: Spacing.d24,
        runSpacing: Spacing.d24,
        children: [
          for (final note in _notes)
            SizedBox.square(
              dimension: _side,
              child: Paper(
                stock: note.stock,
                curl: note.curl,
                seed: note.head,
                padding: const EdgeInsets.all(Spacing.d16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    Text(
                      note.head,
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 24,
                        cssLineHeight: 1,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      note.body,
                      style: theme.typography.interface(cssSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
