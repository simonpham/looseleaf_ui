import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/models/models.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A part's props: name, type, default and description per row.
///
/// Mirrors `ApiTable` in upstream `src/docs/kit/ApiTable.tsx`.
class PropsTable extends StatelessWidget {
  const PropsTable({super.key, required this.props});

  final List<PropDoc> props;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final code = theme.typography.mono(
      cssSize: 12.5,
      color: theme.colors.inkSoft,
    );
    final muted = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 15,
      cssLineHeight: 1.4,
      color: theme.colors.inkSoft,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, prop) in props.indexed) ...[
          if (index > 0) const Separator(variant: SeparatorVariant.dotted),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.d12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d4,
              children: [
                Wrap(
                  spacing: Spacing.d12,
                  runSpacing: Spacing.d4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      prop.name,
                      style: theme.typography.face(
                        KevinSansFace.hand,
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                    Text(prop.type, style: code),
                    if (prop.defaultValue case final value?)
                      Text(
                        '= $value',
                        style: code.copyWith(color: theme.colors.inkMuted),
                      ),
                  ],
                ),
                Text(prop.description, style: muted),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
