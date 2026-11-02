import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _months = ['Sep', 'Oct', 'Nov'];

class FolderControlledExample extends StatefulWidget {
  const FolderControlledExample({super.key});

  @override
  State<FolderControlledExample> createState() =>
      _FolderControlledExampleState();
}

class _FolderControlledExampleState extends State<FolderControlledExample> {
  static const _maxWidth = 576.0;

  String _value = 'Sep';

  void _next() => setState(
    () => _value = _months[(_months.indexOf(_value) + 1) % _months.length],
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: Spacing.d24,
          children: [
            Folder(
              value: _value,
              onValueChange: (value) => setState(() => _value = value),
              children: [
                FolderTabs(
                  semanticLabel: 'Months',
                  children: [
                    for (final month in _months)
                      FolderTab(value: month, child: Text(month)),
                  ],
                ),
                for (final month in _months)
                  FolderContent(
                    value: month,
                    seed: month,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: Spacing.d8,
                      children: [
                        Text(
                          month,
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 30,
                            cssLineHeight: 1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text('Notes for $month.'),
                      ],
                    ),
                  ),
              ],
            ),
            Button(
              variant: ButtonVariant.secondary,
              onPressed: _next,
              child: const Text('Next month'),
            ),
          ],
        ),
      ),
    );
  }
}
