import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

enum _CopyState { idle, copied, failed }

/// An incident slip for support: status, time, request and a circled
/// reference with its barcode, and a button that copies the reference.
///
/// Mirrors upstream `src/blocks/error-500/components/error-500-slip.tsx`.
class Error500Slip extends StatefulWidget {
  const Error500Slip({
    super.key,
    required this.reference,
    required this.request,
    required this.time,
  });

  final String reference;
  final String request;
  final String time;

  @override
  State<Error500Slip> createState() => _Error500SlipState();
}

class _Error500SlipState extends State<Error500Slip> {
  static const _resetAfter = Duration(milliseconds: 2600);
  static final _notCode = RegExp('[^0-9a-z]', caseSensitive: false);

  _CopyState _copy = _CopyState.idle;
  Timer? _reset;

  @override
  void dispose() {
    _reset?.cancel();
    super.dispose();
  }

  Future<void> _copyReference() async {
    final next = await Clipboard.setData(
      ClipboardData(text: widget.reference),
    ).then((_) => _CopyState.copied, onError: (_) => _CopyState.failed);
    if (!mounted) return;
    _reset?.cancel();
    _reset = Timer(_resetAfter, () {
      if (mounted) setState(() => _copy = _CopyState.idle);
    });
    setState(() => _copy = next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final copied = _copy == _CopyState.copied;
    return Column(
      spacing: Spacing.d12,
      children: [
        Receipt(
          seed: 'error-500-slip',
          semanticLabel: 'Details for support',
          children: [
            const ReceiptHeader(
              children: [Text('Incident slip'), Text('keep this for support')],
            ),
            ReceiptLines(
              children: [
                const ReceiptLine(price: Text('500'), child: Text('Status')),
                ReceiptLine(
                  price: Text(widget.time),
                  child: const Text('Time'),
                ),
                ReceiptLine(
                  price: Text(widget.request),
                  child: const Text('Asked for'),
                ),
              ],
            ),
            ReceiptTotal(
              label: const Text('Ref'),
              circled: ReceiptPen.redfelt,
              seed: 'error-500-ref',
              child: Text(widget.reference),
            ),
            ReceiptBarcode(
              value: widget.reference.replaceAll(_notCode, '').toUpperCase(),
            ),
            const ReceiptFooter(Text('We are on it.')),
          ],
        ),
        Button(
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          onPressed: () => unawaited(_copyReference()),
          leading: InkIcon(switch (copied) {
            true => 'check',
            false => 'copy',
          }),
          child: Text(switch (copied) {
            true => 'Copied',
            false => 'Copy reference',
          }),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: Spacing.d20),
          child: Semantics(
            liveRegion: true,
            child: Text(
              switch (_copy) {
                _CopyState.copied => 'Reference ${widget.reference} copied.',
                _CopyState.failed =>
                  'Could not copy. Select the reference on the slip instead.',
                _CopyState.idle => '',
              },
              textAlign: TextAlign.center,
              style: theme.typography.face(
                KevinSansFace.hand,
                cssSize: 14,
                color: theme.colors.inkMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
