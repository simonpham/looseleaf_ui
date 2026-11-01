import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The shop at the top of a receipt, centred, 2 px apart: the first child
/// is the name at 16 px bold, the rest (address, date) at the receipt's
/// size.
///
/// Mirrors `ReceiptHeader` in upstream `src/components/ui/receipt.tsx`.
class ReceiptHeader extends StatelessWidget {
  const ReceiptHeader({super.key, required this.children});

  /// The name, then the address and date, usually [Text]s.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      textAlign: TextAlign.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d2,
        children: [
          for (final (index, child) in children.indexed)
            switch (index) {
              0 => Semantics(
                header: true,
                child: DefaultTextStyle.merge(
                  style: theme.typography.face(
                    KevinSansFace.type,
                    cssSize: 16,
                    cssLineHeight: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                  child: child,
                ),
              ),
              _ => child,
            },
        ],
      ),
    );
  }
}
