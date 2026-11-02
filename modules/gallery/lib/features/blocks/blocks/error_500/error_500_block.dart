import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/error_500/error_500.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A 500 page on a taped sheet: Stubby and a sorry note, an incident slip
/// to copy for support, and a retry button.
///
/// Mirrors upstream `src/blocks/error-500/page.tsx`.
class Error500Block extends StatelessWidget {
  const Error500Block({
    super.key,
    this.reference = '7F3A-91C2',
    this.request = '/notebooks/48',
    this.time = '09:41 UTC',
    this.onRetry,
  });

  final String reference;
  final String request;
  final String time;
  final VoidCallback? onRetry;

  static const double _maxWidth = 768;
  static const double _textWidth = 448;
  static const double _wideFrom = 576;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideFrom;
        return Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Spacing.d32,
            vertical: switch (wide) {
              true => Spacing.d56,
              false => Spacing.d40,
            },
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Paper(
                tilt: false,
                tape: PaperTape.both,
                tapeKind: TapeKind.washiStripes,
                seed: 'error-500',
                padding: EdgeInsets.symmetric(
                  horizontal: switch (wide) {
                    true => Spacing.d48,
                    false => Spacing.d24,
                  },
                  vertical: Spacing.d48,
                ),
                child: Column(
                  children: [
                    const Error500Scene(),
                    const SizedBox(height: Spacing.d40),
                    Text(
                      'Error 500 · Server error',
                      textAlign: TextAlign.center,
                      style: theme.typography.stamp(
                        cssSize: 14,
                        color: theme.colors.pencilText,
                      ),
                    ),
                    const SizedBox(height: Spacing.d12),
                    const Lettering(
                      'Something broke on our side',
                      size: LetteringSize.md,
                      tone: LetteringTone.tomato,
                      wobble: 0.4,
                      seed: 'error-500-title',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.d16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _textWidth),
                      child: Text(
                        'It is not you, and nothing you wrote is lost. We have '
                        'been told, and somebody is already sharpening a '
                        'pencil.',
                        textAlign: TextAlign.center,
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 18,
                          cssLineHeight: 28 / 18,
                          color: theme.colors.inkSoft,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.d32),
                    Error500Slip(
                      reference: reference,
                      request: request,
                      time: time,
                    ),
                    const SizedBox(height: Spacing.d20),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: Spacing.d16,
                      runSpacing: Spacing.d12,
                      children: [
                        Button(
                          size: ButtonSize.lg,
                          onPressed: onRetry ?? () {},
                          leading: const InkIcon('rotate-cw'),
                          child: const Text('Try again'),
                        ),
                        Button(
                          size: ButtonSize.lg,
                          variant: ButtonVariant.outline,
                          onPressed: () {},
                          child: const Text('Go home'),
                        ),
                        Button(
                          size: ButtonSize.lg,
                          variant: ButtonVariant.link,
                          onPressed: () {},
                          trailing: InkIcon(
                            'arrow-up-right',
                            flip: switch (Directionality.of(context)) {
                              TextDirection.rtl => IconFlip.x,
                              TextDirection.ltr => IconFlip.none,
                            },
                          ),
                          child: const Text('Check the status page'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
