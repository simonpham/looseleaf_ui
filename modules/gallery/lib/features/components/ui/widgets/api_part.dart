import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/models/models.dart';
import 'package:gallery/features/components/ui/widgets/props_table.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One part of the API reference: its name, description and props.
class ApiPart extends StatelessWidget {
  const ApiPart({super.key, required this.part});

  final PartDoc part;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d12,
      children: [
        DocHeading(part.name, level: 3),
        if (part.description case final text?)
          Text(text, style: TextStyle(color: theme.colors.inkSoft)),
        switch (part.props) {
          [] => const DocHint('No props of its own.'),
          final props => PropsTable(props: props),
        },
      ],
    );
  }
}
