import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// After a failed submit, every field that needs a look; tapping one
/// focuses it.
class Checkout01ErrorSummary extends StatelessWidget {
  const Checkout01ErrorSummary({
    super.key,
    required this.form,
    required this.onFocus,
  });

  final FormController form;
  final ValueChanged<String> onFocus;

  @override
  Widget build(BuildContext context) {
    final errors = form.errors;
    final names = [
      for (final name in checkoutFieldLabels.keys)
        if (errors.containsKey(name)) name,
    ];
    if (!form.isSubmitted || names.isEmpty) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    return Alert(
      variant: AlertTone.destructive,
      icon: const InkIcon('circle-alert'),
      children: [
        AlertTitle(
          Text(switch (names.length) {
            1 => 'One thing needs a look',
            final count => '$count things need a look',
          }),
        ),
        AlertDescription(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d4,
            children: [
              for (final name in names)
                Semantics(
                  button: true,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onFocus(name),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Text(
                        '${checkoutFieldLabels[name]}: ${errors[name]}',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.wavy,
                          decorationColor: theme.colors.red,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
