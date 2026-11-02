import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NativeSelectGroupsAndStatesExample extends StatefulWidget {
  const NativeSelectGroupsAndStatesExample({super.key});

  @override
  State<NativeSelectGroupsAndStatesExample> createState() =>
      _NativeSelectGroupsAndStatesExampleState();
}

class _NativeSelectGroupsAndStatesExampleState
    extends State<NativeSelectGroupsAndStatesExample> {
  static const double _twoColumnsFrom = Spacing.d320;

  String _pen = 'felt';
  String _paper = 'a';
  String? _required;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final fields = [
      _Field(
        label: 'With groups',
        child: NativeSelect<String>(
          value: _pen,
          onChanged: (pen) => setState(() => _pen = pen),
          options: const [
            NativeSelectOptGroup(
              label: 'Pens',
              options: [
                NativeSelectOption(value: 'felt', label: 'Felt tip'),
                NativeSelectOption(value: 'gel', label: 'Gel'),
              ],
            ),
            NativeSelectOptGroup(
              label: 'Pencils',
              options: [
                NativeSelectOption(value: 'hb', label: 'HB'),
                NativeSelectOption(value: '2b', label: '2B'),
              ],
            ),
          ],
        ),
      ),
      _Field(
        label: 'Small',
        child: NativeSelect<String>(
          value: _paper,
          size: NativeSelectSize.sm,
          onChanged: (paper) => setState(() => _paper = paper),
          options: const [
            NativeSelectOption(value: 'a', label: 'A5, ruled'),
            NativeSelectOption(value: 'b', label: 'A4, ruled'),
          ],
        ),
      ),
      _Field(
        label: 'Invalid',
        help: Text(
          'This one is required.',
          style: theme.typography.interface(
            cssSize: 14,
            color: theme.colors.red,
          ),
        ),
        child: NativeSelect<String>(
          value: _required,
          invalid: _required == null,
          placeholder: 'Pick one',
          onChanged: (value) => setState(() => _required = value),
          options: const [NativeSelectOption(value: 'x', label: 'Something')],
        ),
      ),
      const _Field(
        label: 'Disabled',
        child: NativeSelect<String>(
          value: 'a',
          disabled: true,
          options: [NativeSelectOption(value: 'a', label: 'Locked')],
        ),
      ),
    ];
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _twoColumnsFrom) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d20,
              children: fields,
            );
          }
          return Column(
            spacing: Spacing.d20,
            children: [
              for (var row = 0; row < fields.length; row += 2)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d24,
                  children: [
                    Expanded(child: fields[row]),
                    Expanded(child: fields[row + 1]),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.help});

  final String label;
  final Widget child;
  final Widget? help;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d8,
    children: [
      Label(child: Text(label)),
      child,
      ?help,
    ],
  );
}
