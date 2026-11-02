import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/otp_01/otp_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A verification-code card on the desk, with a pinned note that gives
/// away the demo code.
///
/// Mirrors upstream `src/blocks/otp-01/page.tsx`.
class Otp01Block extends StatelessWidget {
  const Otp01Block({super.key});

  static const double _maxWidth = 384;
  static const double _wideFrom = 576;
  static const double _noteWidth = 208;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Padding(
        padding: EdgeInsets.all(switch (constraints.maxWidth >= _wideFrom) {
          true => Spacing.d40,
          false => Spacing.d24,
        }),
        child: Column(
          spacing: Spacing.d32,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: const Otp01Form(),
            ),
            StickyNote(
              fastener: FastenerKind.pin,
              tiltDegrees: 2,
              width: _noteWidth,
              minHeight: 0,
              seed: 'otp-01-note',
              children: [
                Text(
                  'psst: the demo code is $otp01DemoCode',
                  style: theme.typography.face(
                    KevinSansFace.script,
                    cssSize: 20,
                    cssLineHeight: 28 / 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
