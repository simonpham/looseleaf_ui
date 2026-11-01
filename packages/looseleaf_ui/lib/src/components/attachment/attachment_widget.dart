import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_actions.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_content.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_media.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_metrics.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_scope.dart';
import 'package:looseleaf_ui/src/components/attachment/attachment_trigger.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/tape/tape.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A file in a chat or a form, on paper: a slip with a file icon, its name
/// and a size, and buttons to remove or retry; or, [vertical], a photo
/// print taped to the wall.
///
/// [state] sets the look: [AttachmentState.done] is a clipped slip,
/// `uploading` and `processing` show an [AttachmentProgress] and breathe,
/// `error` is red pencil, `idle` a dashed slot waiting for a file. Put an
/// [AttachmentTrigger] among the [children] to make the whole slip
/// pressable. A horizontal slip fits its content (at least 160 px, at most
/// the row); give it a width from outside to fill a column.
///
/// ```dart
/// Attachment(
///   seed: 'notes',
///   children: [
///     const AttachmentMedia(child: InkIcon('file-text')),
///     const AttachmentContent(children: [
///       AttachmentTitle(child: Text('field-notes.pdf')),
///       AttachmentDescription(child: Text('2.4 MB · pdf')),
///     ]),
///     AttachmentActions(children: [
///       AttachmentAction(
///         semanticLabel: 'Remove field-notes.pdf',
///         onPressed: remove,
///         child: const InkIcon('x'),
///       ),
///     ]),
///   ],
/// )
/// ```
///
/// Mirrors `Attachment` in upstream `src/components/ui/attachment.tsx`.
class Attachment extends StatefulWidget {
  const Attachment({
    super.key,
    required this.children,
    this.state = AttachmentState.done,
    this.size = AttachmentSize.regular,
    this.orientation = AttachmentOrientation.horizontal,
    this.seed,
    this.forcedStates = const {},
  });

  /// [AttachmentMedia], [AttachmentContent], [AttachmentActions] and an
  /// optional [AttachmentTrigger], in that order.
  final List<Widget> children;

  final AttachmentState state;
  final AttachmentSize size;

  /// A horizontal slip or a vertical print.
  final AttachmentOrientation orientation;

  /// Pins the hand, the sheet, the clip and the tape.
  final String? seed;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Attachment> createState() => _AttachmentState();
}

class _AttachmentState extends State<Attachment> with InkSeed {
  bool _focusWithin = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addHighlightModeListener(_highlightChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(_highlightChanged);
    super.dispose();
  }

  void _highlightChanged(FocusHighlightMode mode) {
    if (!_focusWithin) return;
    setState(() {});
  }

  bool get _vertical => widget.orientation == AttachmentOrientation.vertical;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final trigger = widget.children.whereType<AttachmentTrigger>().firstOrNull;
    final hasActions = widget.children.any((c) => c is AttachmentActions);
    final clipped =
        widget.state == AttachmentState.done &&
        !_vertical &&
        widget.size == AttachmentSize.regular;
    final calm = PaperInk.calm(theme);
    final params = AttachmentParams(
      state: widget.state,
      orientation: widget.orientation,
      interactive: true,
    );
    final style = theme.typography.face(
      KevinSansFace.hand,
      cssSize: AttachmentMetrics.textSize(widget.size),
      cssLineHeight: AttachmentMetrics.lineHeight,
      color: theme.colors.ink,
    );

    Widget card(Set<InkState> states) => Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.state != AttachmentState.idle)
          Positioned.fill(
            child: PaperBackground(
              seed: '$seed|sheet',
              stock: switch (_vertical) {
                true => StockName.photo,
                false => StockName.slip,
              },
              rules: RuleName.none,
              tilt: _vertical,
            ),
          ),
        InkSurface(
          source: RecipeInkSource(
            attachmentRecipe,
            params,
            json: params.toJson(),
          ),
          seed: seed,
          states: {
            ...states,
            if (_focusWithin && _keyboard) InkState.focused,
          },
          still: true,
          eagerLayers: switch (trigger) {
            null => const {},
            _ => const {'hover'},
          },
          child: DefaultTextStyle.merge(
            style: style,
            child: _layout(clipped && !hasActions),
          ),
        ),
        if (widget.state == AttachmentState.done && _vertical && !calm)
          Positioned(
            top: AttachmentMetrics.tapeTop,
            left: 0,
            right: 0,
            child: Center(
              child: Tape(
                kind: TapeKind.masking,
                length: AttachmentMetrics.tapeLength,
                height: AttachmentMetrics.tapeHeight,
                seed: '$seed|tape',
              ),
            ),
          ),
        if (clipped && !calm)
          PositionedDirectional(
            top: AttachmentMetrics.clipTop,
            end: AttachmentMetrics.clipEnd,
            child: PaperFastener(
              kind: FastenerKind.clip,
              size: AttachmentMetrics.clipSize,
              seed: '$seed|clip',
            ),
          ),
        if (_vertical)
          for (final actions in widget.children.whereType<AttachmentActions>())
            PositionedDirectional(
              top: AttachmentMetrics.printActionsInset,
              end: AttachmentMetrics.printActionsInset,
              child: actions,
            ),
      ],
    );

    final scoped = AttachmentScope(
      state: widget.state,
      orientation: widget.orientation,
      size: widget.size,
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (focused) => setState(() => _focusWithin = focused),
        child: switch (trigger) {
          null => card(widget.forcedStates),
          final pressable => Semantics(
            container: true,
            explicitChildNodes: true,
            button: true,
            enabled: true,
            label: pressable.semanticLabel,
            child: InkInteraction(
              onActivate: pressable.onPressed,
              states: widget.forcedStates,
              focusNode: pressable.focusNode,
              autofocus: pressable.autofocus,
              builder: (context, states) => card(states),
            ),
          ),
        },
      ),
    );
    if (_vertical) return scoped;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: AttachmentMetrics.minWidth),
      child: IntrinsicWidth(child: scoped),
    );
  }

  bool get _keyboard =>
      FocusManager.instance.highlightMode == FocusHighlightMode.traditional;

  Widget _layout(bool clipRoom) {
    final hasContent = widget.children.any((c) => c is AttachmentContent);
    final hasMedia = widget.children.any((c) => c is AttachmentMedia);
    final padding = switch ((hasContent, hasMedia)) {
      (true, _) => AttachmentMetrics.contentPadding(widget.size),
      (false, true) => AttachmentMetrics.mediaPadding(widget.size),
      (false, false) => switch (_vertical) {
        true => const EdgeInsets.only(bottom: AttachmentMetrics.printBottom),
        false => EdgeInsets.zero,
      },
    };
    final gap = AttachmentMetrics.gap(widget.size);
    final flow = [
      for (final child in widget.children)
        if (child is! AttachmentTrigger &&
            !(_vertical && child is AttachmentActions))
          child,
    ];
    if (_vertical) {
      return SizedBox(
        width: switch (hasContent) {
          true => AttachmentMetrics.captionedPrintWidth,
          false => AttachmentMetrics.printWidth,
        },
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: gap,
            children: flow,
          ),
        ),
      );
    }
    return Padding(
      padding: padding,
      child: Row(
        spacing: gap,
        children: [
          for (final child in flow)
            switch (child) {
              AttachmentContent() => Expanded(
                child: switch (clipRoom) {
                  true => Padding(
                    padding: const EdgeInsetsDirectional.only(
                      end: AttachmentMetrics.clipRoom,
                    ),
                    child: child,
                  ),
                  false => child,
                },
              ),
              _ => child,
            },
        ],
      ),
    );
  }
}
