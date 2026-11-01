import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonStatesExample extends StatelessWidget {
  const ButtonStatesExample({super.key});

  static const _states = ['rest', 'hover', 'pressed', 'focus', 'disabled'];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              for (final state in _states)
                _Cell(
                  Text(
                    state,
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 18,
                      color: theme.colors.inkYou,
                    ),
                  ),
                ),
            ],
          ),
          for (final variant in ButtonVariant.values)
            TableRow(
              children: [
                for (final forced in const [
                  <InkState>{},
                  {InkState.hovered},
                  {InkState.pressed},
                  {InkState.focused},
                ])
                  _Cell(
                    Button(
                      variant: variant,
                      forcedStates: forced,
                      onPressed: () {},
                      child: Text(variant.id),
                    ),
                  ),
                _Cell(
                  Button(
                    variant: variant,
                    disabled: true,
                    child: Text(variant.id),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      end: Spacing.d20,
      bottom: Spacing.d20,
    ),
    child: Align(alignment: AlignmentDirectional.centerStart, child: child),
  );
}
