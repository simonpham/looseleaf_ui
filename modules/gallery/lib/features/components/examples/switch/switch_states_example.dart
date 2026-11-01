import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SwitchStatesExample extends StatelessWidget {
  const SwitchStatesExample({super.key});

  static const _sizes = [
    ('default', SwitchSize.regular),
    ('sm', SwitchSize.sm),
  ];

  static const _columns = [
    'off',
    'on',
    'invalid',
    'invalid on',
    'disabled',
    'disabled on',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            defaultColumnWidth: const MaxColumnWidth(
              FixedColumnWidth(Spacing.d80),
              IntrinsicColumnWidth(),
            ),
            columnWidths: const {
              0: MaxColumnWidth(
                FixedColumnWidth(Spacing.d56),
                IntrinsicColumnWidth(),
              ),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              TableRow(
                children: [
                  const SizedBox.shrink(),
                  for (final column in _columns)
                    _Cell(
                      ExcludeSemantics(
                        child: Text(
                          column,
                          softWrap: false,
                          style: theme.typography.interface(
                            cssSize: 13,
                            color: theme.colors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              for (final (name, size) in _sizes)
                TableRow(
                  children: [
                    _Cell(Text(name, softWrap: false, style: muted)),
                    _Cell(_LooseSwitch(size: size, name: '$name off')),
                    _Cell(
                      _LooseSwitch(size: size, name: '$name on', initial: true),
                    ),
                    _Cell(
                      _LooseSwitch(
                        size: size,
                        name: '$name invalid',
                        invalid: true,
                      ),
                    ),
                    _Cell(
                      _LooseSwitch(
                        size: size,
                        name: '$name invalid on',
                        initial: true,
                        invalid: true,
                      ),
                    ),
                    _Cell(
                      Switch(
                        value: false,
                        size: size,
                        disabled: true,
                        semanticLabel: '$name disabled',
                      ),
                    ),
                    _Cell(
                      Switch(
                        value: true,
                        size: size,
                        disabled: true,
                        semanticLabel: '$name disabled on',
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        const Switch(
          value: true,
          disabled: true,
          label: Text('Locked by your administrator'),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(
      end: Spacing.d12,
      bottom: Spacing.d14,
    ),
    child: Align(alignment: AlignmentDirectional.centerStart, child: child),
  );
}

class _LooseSwitch extends StatefulWidget {
  const _LooseSwitch({
    required this.size,
    required this.name,
    this.initial = false,
    this.invalid = false,
  });

  final SwitchSize size;
  final String name;
  final bool initial;
  final bool invalid;

  @override
  State<_LooseSwitch> createState() => _LooseSwitchState();
}

class _LooseSwitchState extends State<_LooseSwitch> {
  late bool _on = widget.initial;

  @override
  Widget build(BuildContext context) => Switch(
    value: _on,
    onChanged: (value) => setState(() => _on = value),
    size: widget.size,
    invalid: widget.invalid,
    semanticLabel: widget.name,
  );
}
