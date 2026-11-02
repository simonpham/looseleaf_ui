import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DirectionUseDirectionExample extends StatelessWidget {
  const DirectionUseDirectionExample({super.key});

  static const _maxWidth = 448.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DirectionProvider(
      direction: TextDirection.rtl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'direction-island',
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('ציטוט מהמחברת')),
                CardDescription(
                  Text('הכותרת בעברית והציטוט באנגלית. לחצו על חץ כדי לדפדף.'),
                ),
              ],
            ),
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d20,
                children: [
                  const _Pager(pages: 5, label: 'דפי המחברת'),
                  DirectionProvider(
                    direction: TextDirection.ltr,
                    child: Container(
                      padding: const EdgeInsetsDirectional.only(
                        start: Spacing.d12,
                      ),
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          start: BorderSide(
                            color: theme.colors.pencilMark,
                            width: Spacing.d2,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d12,
                        children: [
                          Text(
                            'Draw the thing you can see, then the thing you meant.',
                            style: theme.typography.face(
                              KevinSansFace.script,
                              cssSize: 20,
                            ),
                          ),
                          Row(
                            spacing: Spacing.d12,
                            children: [
                              const _Pager(pages: 3, label: 'Quote pages'),
                              Popover(
                                content: const PopoverContent(
                                  width: 240,
                                  seed: 'direction-island-popover',
                                  semanticLabel: 'About this quote',
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      PopoverTitle(Text('Left to right')),
                                      PopoverDescription(
                                        Text(
                                          'This slip opens outside the island, so it is told its direction and keeps it.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                child: PopoverTrigger.builder(
                                  builder: (context, popover) => Button(
                                    variant: ButtonVariant.ghost,
                                    size: ButtonSize.iconSm,
                                    semanticLabel: 'About this quote',
                                    onPressed: popover.toggle,
                                    child: const InkIcon('info'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pager extends StatefulWidget {
  const _Pager({required this.pages, required this.label});

  final int pages;
  final String label;

  @override
  State<_Pager> createState() => _PagerState();
}

class _PagerState extends State<_Pager> {
  int _page = 1;

  void _go(int by) =>
      setState(() => _page = math.min(widget.pages, math.max(1, _page + by)));

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final rtl = DirectionProvider.of(context) == TextDirection.rtl;
    final step = switch ((event.logicalKey, rtl)) {
      (LogicalKeyboardKey.arrowRight, false) => 1,
      (LogicalKeyboardKey.arrowLeft, true) => 1,
      (LogicalKeyboardKey.arrowLeft, false) => -1,
      (LogicalKeyboardKey.arrowRight, true) => -1,
      _ => 0,
    };
    if (step == 0) return KeyEventResult.ignored;
    _go(step);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final rtl = DirectionProvider.of(context) == TextDirection.rtl;
    return Semantics(
      container: true,
      label: widget.label,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onKeyEvent: _onKey,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d8,
          children: [
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.iconSm,
              disabled: _page == 1,
              semanticLabel: switch (rtl) {
                true => 'הקודם',
                false => 'Previous',
              },
              onPressed: () => _go(-1),
              child: const InkIcon('arrow-left'),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: Spacing.d64),
              child: Text(
                '$_page / ${widget.pages}',
                textAlign: TextAlign.center,
                style: theme.typography
                    .interface(cssSize: 14)
                    .copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ),
            Button(
              variant: ButtonVariant.outline,
              size: ButtonSize.iconSm,
              disabled: _page == widget.pages,
              semanticLabel: switch (rtl) {
                true => 'הבא',
                false => 'Next',
              },
              onPressed: () => _go(1),
              child: const InkIcon('arrow-right'),
            ),
          ],
        ),
      ),
    );
  }
}
