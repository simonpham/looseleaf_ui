import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DialogPaperAndPropsExample extends StatelessWidget {
  const DialogPaperAndPropsExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    spacing: Spacing.d12,
    runSpacing: Spacing.d12,
    alignment: WrapAlignment.center,
    children: [
      _Note(
        label: 'Kraft, taped',
        title: 'Handle with care',
        body: 'Kraft stock, one strip of clear tape across the top edge.',
        stock: StockName.kraft,
        tape: PaperTape.top,
        tapeKind: TapeKind.clear,
        seed: 'kraft',
      ),
      _Note(
        label: 'Torn page',
        title: 'Torn from a pad',
        body: 'A pad sheet torn top and bottom, held with a paper clip. The edge is drawn when the dialog opens.',
        stock: StockName.pad,
        edge: EdgeSpec(top: EdgeKind.torn, bottom: EdgeKind.torn),
        fastener: FastenerKind.clip,
        seed: 'torn',
      ),
      _Note(
        label: 'Pinned',
        title: 'Sticky business',
        body: 'A sticky note with a push-pin through it, turned a degree and a half.',
        stock: StockName.stickyYellow,
        fastener: FastenerKind.pin,
        tiltDegrees: 1.4,
        seed: 'sticky',
      ),
    ],
  );
}

class _Note extends StatelessWidget {
  const _Note({
    required this.label,
    required this.title,
    required this.body,
    required this.stock,
    required this.seed,
    this.edge,
    this.tape,
    this.tapeKind = TapeKind.masking,
    this.fastener,
    this.tiltDegrees,
  });

  final String label;
  final String title;
  final String body;
  final StockName stock;
  final String seed;
  final EdgeSpec? edge;
  final PaperTape? tape;
  final TapeKind tapeKind;
  final FastenerKind? fastener;
  final double? tiltDegrees;

  @override
  Widget build(BuildContext context) => Dialog(
    content: DialogContent(
      stock: stock,
      edge: edge,
      tape: tape,
      tapeKind: tapeKind,
      fastener: fastener,
      tiltDegrees: tiltDegrees,
      seed: seed,
      maxWidth: 384,
      children: [
        DialogHeader(
          children: [DialogTitle(Text(title)), DialogDescription(Text(body))],
        ),
        DialogFooter(
          children: [
            DialogClose(
              builder: (context, close) =>
                  Button(onPressed: close, child: const Text('Got it')),
            ),
          ],
        ),
      ],
    ),
    child: DialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        onPressed: dialog.show,
        child: Text(label),
      ),
    ),
  );
}
