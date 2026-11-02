import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/empty/empty_header.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The actions of an [Empty]: small text, centered at most 384 wide with
/// 16 between them.
///
/// Mirrors `EmptyContent` in upstream `src/components/ui/empty.tsx`.
class EmptyContent extends StatelessWidget {
  const EmptyContent({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: EmptyHeader.maxWidth),
    child: DefaultTextStyle.merge(
      style:
          LooseleafTheme.of(
            context,
          ).typography.face(
            KevinSansFace.hand,
            cssSize: 14,
            cssLineHeight: 20 / 14,
          ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d16,
        children: children,
      ),
    ),
  );
}
