import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PeelCornerVoucherExample extends StatefulWidget {
  const PeelCornerVoucherExample({super.key});

  @override
  State<PeelCornerVoucherExample> createState() =>
      _PeelCornerVoucherExampleState();
}

class _PeelCornerVoucherExampleState extends State<PeelCornerVoucherExample> {
  static const _width = Spacing.d320;
  static const _height = 208.0;

  bool _open = false;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(const ClipboardData(text: 'FREE-10'));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d12,
      children: [
        SizedBox(
          width: _width,
          child: PeelCorner(
            peeled: _open,
            onPeeledChange: (open) => setState(() => _open = open),
            label: 'Reveal the voucher code',
            children: [
              PeelCornerPage(
                height: _height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    Text(
                      'Loyalty voucher',
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 30,
                        cssLineHeight: 1,
                      ),
                    ),
                    Text(
                      'Thank you for ten coffees. This one is on us.',
                      style: theme.typography.interface(cssSize: 14),
                    ),
                  ],
                ),
              ),
              PeelCornerUnder(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: Spacing.d4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    spacing: Spacing.d8,
                    children: [
                      Text(
                        'FREE-10',
                        style: theme.typography.face(
                          KevinSansFace.script,
                          cssSize: 36,
                          cssLineHeight: 1,
                        ),
                      ),
                      Button(
                        size: ButtonSize.xs,
                        variant: ButtonVariant.outline,
                        onPressed: () => unawaited(_copy()),
                        child: Text(switch (_copied) {
                          true => 'Copied',
                          false => 'Copy code',
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Button(
          variant: ButtonVariant.link,
          size: ButtonSize.sm,
          onPressed: () => setState(() => _open = !_open),
          child: Text(switch (_open) {
            true => 'Close the corner',
            false => 'Or open it from here',
          }),
        ),
      ],
    );
  }
}
