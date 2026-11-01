import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet a [Dialog] drops in: a [Paper] (plain paper by default, any
/// stock, edge, tilt, tape or fastener) up to 512 px wide with 24 px
/// padding (20 compact, 16 calm), its [children] stacked 16 px apart, and
/// the doodled × ([DialogCloseMark]) in the top corner.
///
/// Phone-sized windows (under 640 px) lay it flat, as wide as the window
/// allows, without tape.
///
/// Mirrors `DialogContent` in upstream `src/components/ui/dialog.tsx`.
class DialogContent extends StatefulWidget {
  const DialogContent({
    super.key,
    required this.children,
    this.showCloseButton = true,
    this.stock = StockName.paper,
    this.edge,
    this.tilt = true,
    this.tiltDegrees,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.fastenerTone,
    this.rules = RuleName.none,
    this.shadow = PaperShadow.stock,
    this.seed,
    this.padding,
    this.gap = DialogMetrics.gap,
    this.maxWidth = DialogMetrics.maxWidth,
    this.semanticLabel,
    this.decor = const [],
  });

  /// The header, body, fields and footer, top to bottom.
  final List<Widget> children;

  /// The doodled × in the top corner.
  final bool showCloseButton;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// False lays the sheet flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded when null.
  final double? tiltDegrees;

  /// Tape strips; none when null.
  final PaperTape? tape;

  /// The tape the strips are cut from.
  final TapeKind tapeKind;

  /// A clip, pin, staple or binder clip; none when null.
  final FastenerKind? fastener;

  /// The fastener's colour.
  final Accent? fastenerTone;

  /// The printed rules; none by default.
  final RuleName rules;

  /// The shadow; the stock's by default.
  final PaperShadow shadow;

  /// Pins the sheet and the close mark.
  final String? seed;

  /// The padding; 24 / 20 / 16 by density when null.
  final EdgeInsetsGeometry? padding;

  /// The gap between [children].
  final double gap;

  /// The widest the sheet gets (upstream's `max-w-*`).
  final double maxWidth;

  /// Names the dialog for screen readers when it has no [DialogTitle].
  final String? semanticLabel;

  /// Props stacked over the sheet's corners, outside the padding (an alert
  /// dialog's hazard tape).
  final List<Widget> decor;

  @override
  State<DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<DialogContent> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final seed = inkSeed(widget.seed);
    final phone = DialogMetrics.phone(context);
    final sheet = Paper(
      stock: widget.stock,
      edge: widget.edge,
      tilt: widget.tilt && !phone,
      tiltDegrees: switch (phone) {
        true => 0,
        false => widget.tiltDegrees,
      },
      rules: widget.rules,
      tape: switch (phone) {
        true => null,
        false => widget.tape,
      },
      tapeKind: widget.tapeKind,
      fastener: widget.fastener,
      fastenerTone: widget.fastenerTone,
      shadow: widget.shadow,
      seed: seed,
      padding:
          widget.padding ?? EdgeInsets.all(DialogMetrics.padding.of(context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: widget.gap,
        children: widget.children,
      ),
    );
    final theme = LooseleafTheme.of(context);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: widget.semanticLabel != null,
      label: widget.semanticLabel,
      child: DialogContentScope(
        closeMark: widget.showCloseButton,
        phone: phone,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: switch (phone) {
              true => double.infinity,
              false => widget.maxWidth,
            },
          ),
          child: SizedBox(
            width: double.infinity,
            child: DefaultTextStyle.merge(
              style: theme.typography.interface(color: theme.colors.ink),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  sheet,
                  if (!phone) ...widget.decor,
                  if (widget.showCloseButton)
                    PositionedDirectional(
                      top: DialogMetrics.closeInset,
                      end: DialogMetrics.closeInset,
                      child: DialogCloseMark(seed: '$seed|x'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
