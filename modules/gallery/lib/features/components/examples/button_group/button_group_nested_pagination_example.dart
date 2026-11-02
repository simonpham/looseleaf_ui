import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupNestedPaginationExample extends StatefulWidget {
  const ButtonGroupNestedPaginationExample({super.key});

  @override
  State<ButtonGroupNestedPaginationExample> createState() =>
      _ButtonGroupNestedPaginationExampleState();
}

class _ButtonGroupNestedPaginationExampleState
    extends State<ButtonGroupNestedPaginationExample> {
  static const _pages = 5;

  var _page = 2;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        ButtonGroup(
          semanticLabel: 'Pagination',
          children: [
            ButtonGroup(
              children: [
                for (var n = 1; n <= _pages; n++)
                  Semantics(
                    selected: n == _page,
                    child: Button(
                      variant: switch (n == _page) {
                        true => ButtonVariant.secondary,
                        false => ButtonVariant.outline,
                      },
                      size: ButtonSize.sm,
                      semanticLabel: 'Page $n',
                      onPressed: () => setState(() => _page = n),
                      child: Text('$n'),
                    ),
                  ),
              ],
            ),
            ButtonGroup(
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.iconSm,
                  semanticLabel: 'Previous page',
                  disabled: _page == 1,
                  onPressed: () => setState(() => _page--),
                  child: const InkIcon('arrow-left'),
                ),
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.iconSm,
                  semanticLabel: 'Next page',
                  disabled: _page == _pages,
                  onPressed: () => setState(() => _page++),
                  child: const InkIcon('arrow-right'),
                ),
              ],
            ),
          ],
        ),
        Semantics(
          liveRegion: true,
          child: Text(
            'Page $_page of $_pages',
            style: theme.typography.interface(
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
