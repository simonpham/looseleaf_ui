import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PopoverStocksAndFastenersExample extends StatelessWidget {
  const PopoverStocksAndFastenersExample({super.key});

  static const _width = Spacing.d240;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    Widget header(String title, String body) => PopoverHeader(
      children: [
        PopoverTitle(Text(title)),
        PopoverDescription(
          Text(
            body,
            style: TextStyle(color: theme.colors.ink.withValues(alpha: 0.8)),
          ),
        ),
      ],
    );
    final notes = [
      (
        'Pinned slip',
        PopoverContent(
          width: _width,
          seed: 'Pinned',
          pin: true,
          pinTone: Accent.sky,
          child: header('Pinned', 'A push-pin in stationery sky.'),
        ),
      ),
      (
        'Taped kraft',
        PopoverContent(
          width: _width,
          seed: 'Taped',
          stock: StockName.kraft,
          tape: PaperTape.top,
          child: header('Taped', 'Kraft paper under a strip of masking tape.'),
        ),
      ),
      (
        'Torn index card',
        PopoverContent(
          width: _width,
          seed: 'Torn',
          stock: StockName.indexCard,
          edge: const EdgeSpec(bottom: EdgeKind.torn),
          child: header('Torn', 'An index card with a torn bottom edge.'),
        ),
      ),
      (
        'Sticky pink',
        PopoverContent(
          width: _width,
          seed: 'Sticky',
          stock: StockName.stickyPink,
          tiltDegrees: 1.5,
          pin: true,
          pinTone: Accent.grape,
          child: header('Sticky', 'Turned a degree and a half.'),
        ),
      ),
    ];
    return Wrap(
      spacing: Spacing.d12,
      runSpacing: Spacing.d12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final (label, content) in notes)
          Popover(
            content: content,
            child: PopoverTrigger.builder(
              builder: (context, popover) => Button(
                variant: ButtonVariant.outline,
                onPressed: popover.toggle,
                child: Text(label),
              ),
            ),
          ),
      ],
    );
  }
}
