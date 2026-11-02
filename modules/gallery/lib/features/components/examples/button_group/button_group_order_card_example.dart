import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupOrderCardExample extends StatefulWidget {
  const ButtonGroupOrderCardExample({super.key});

  @override
  State<ButtonGroupOrderCardExample> createState() =>
      _ButtonGroupOrderCardExampleState();
}

class _ButtonGroupOrderCardExampleState
    extends State<ButtonGroupOrderCardExample> {
  static const _sizes = ['Small', 'Loaf', 'Big'];
  static const _maxWidth = Spacing.d384;

  var _qty = 2;
  var _size = 'Loaf';

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'order',
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Sourdough')),
                CardDescription(Text('Baked this morning, gone by noon.')),
              ],
            ),
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d16,
                children: [
                  ButtonGroup(
                    semanticLabel: 'Size',
                    children: [
                      for (final size in _sizes)
                        Semantics(
                          toggled: size == _size,
                          child: Button(
                            variant: switch (size == _size) {
                              true => ButtonVariant.secondary,
                              false => ButtonVariant.outline,
                            },
                            onPressed: () => setState(() => _size = size),
                            child: Text(size),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    spacing: Spacing.d12,
                    children: [
                      ButtonGroup(
                        semanticLabel: 'Quantity',
                        children: [
                          Button(
                            variant: ButtonVariant.outline,
                            size: ButtonSize.icon,
                            semanticLabel: 'One fewer',
                            disabled: _qty <= 1,
                            onPressed: () => setState(() => _qty--),
                            child: const InkIcon('minus'),
                          ),
                          Semantics(
                            liveRegion: true,
                            child: ButtonGroupText(
                              alignment: MainAxisAlignment.center,
                              minWidth: Spacing.d48,
                              child: Text('$_qty'),
                            ),
                          ),
                          Button(
                            variant: ButtonVariant.outline,
                            size: ButtonSize.icon,
                            semanticLabel: 'One more',
                            disabled: _qty >= 6,
                            onPressed: () => setState(() => _qty++),
                            child: const InkIcon('plus'),
                          ),
                        ],
                      ),
                      Text(
                        '$_qty × ${_size.toLowerCase()}',
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CardFooter(
              divider: true,
              children: [
                Expanded(
                  child: Button(
                    onPressed: () {},
                    child: Text('Add $_qty to the basket'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
