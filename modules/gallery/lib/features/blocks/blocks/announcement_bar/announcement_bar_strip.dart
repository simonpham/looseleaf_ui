import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A kraft strip across the top of the page, taped at both corners: a
/// "New" flag, the [message], a link and a dismiss button.
///
/// Mirrors upstream
/// `src/blocks/announcement-bar/components/announcement-bar-strip.tsx`.
class AnnouncementBarStrip extends StatelessWidget {
  const AnnouncementBarStrip({
    super.key,
    required this.message,
    this.label = 'New',
    this.linkLabel = 'Read the notes',
    this.onLinkPressed,
    this.onDismiss,
    this.focusNode,
  });

  /// What is new.
  final String message;

  /// The flag's word.
  final String label;

  /// The link's text.
  final String linkLabel;

  /// Called when the link is pressed.
  final VoidCallback? onLinkPressed;

  /// Called by the dismiss button; no button when null.
  final VoidCallback? onDismiss;

  /// Takes focus for the strip as a whole.
  final FocusNode? focusNode;

  static const double _tapeLength = 52;
  static const double _tapeHeight = 18;
  static const double _tapeAngle = 32;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final turn = switch (rtl) {
      true => -1.0,
      false => 1.0,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.d16,
        Spacing.d24,
        Spacing.d16,
        0,
      ),
      child: Focus(
        focusNode: focusNode,
        skipTraversal: true,
        child: Semantics(
          container: true,
          label: 'Announcement',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Paper(
                stock: StockName.kraft,
                tilt: false,
                shadow: PaperShadow.slip,
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.d48,
                  vertical: Spacing.d10,
                ),
                child: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: Spacing.d12,
                    runSpacing: Spacing.d4,
                    children: [
                      Ribbon(
                        variant: RibbonVariant.flag,
                        tone: RibbonTone.hi,
                        size: RibbonSize.sm,
                        child: Text(label),
                      ),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 15,
                          cssLineHeight: 24 / 15,
                          color: theme.colors.ink,
                        ),
                      ),
                      Button(
                        variant: ButtonVariant.link,
                        size: ButtonSize.sm,
                        onPressed: onLinkPressed ?? () {},
                        trailing: InkIcon(
                          'arrow-right',
                          flip: switch (rtl) {
                            true => IconFlip.x,
                            false => IconFlip.none,
                          },
                        ),
                        child: Text(linkLabel),
                      ),
                    ],
                  ),
                ),
              ),
              PositionedDirectional(
                top: -Spacing.d10,
                start: -Spacing.d12,
                child: Tape(
                  kind: TapeKind.washiStripes,
                  color: Accent.tangerine,
                  length: _tapeLength,
                  height: _tapeHeight,
                  angle: -_tapeAngle * turn,
                ),
              ),
              PositionedDirectional(
                top: -Spacing.d10,
                end: -Spacing.d12,
                child: Tape(
                  kind: TapeKind.washiStripes,
                  color: Accent.tangerine,
                  length: _tapeLength,
                  height: _tapeHeight,
                  angle: _tapeAngle * turn,
                ),
              ),
              if (onDismiss case final dismiss?)
                PositionedDirectional(
                  top: 0,
                  bottom: 0,
                  end: Spacing.d8,
                  child: Center(
                    child: Button(
                      variant: ButtonVariant.ghost,
                      size: ButtonSize.iconSm,
                      semanticLabel: 'Dismiss announcement',
                      onPressed: dismiss,
                      child: const InkIcon('x'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
