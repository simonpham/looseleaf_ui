import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PopoverShareLinkExample extends StatefulWidget {
  const PopoverShareLinkExample({super.key});

  @override
  State<PopoverShareLinkExample> createState() =>
      _PopoverShareLinkExampleState();
}

class _PopoverShareLinkExampleState extends State<PopoverShareLinkExample> {
  static const _width = 320.0;

  static const _link = 'https://kevintngo.github.io/looseleaf/n/field-notes';

  final _controller = TextEditingController(text: _link);
  final _focusNode = FocusNode();
  var _copied = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_selectOnFocus);
  }

  void _selectOnFocus() {
    if (!_focusNode.hasFocus) return;
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  Future<void> _copy() async {
    await Clipboard.setData(const ClipboardData(text: _link));
    if (!mounted) return;
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(
      const Duration(milliseconds: 1800),
      () => setState(() => _copied = false),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focusNode
      ..removeListener(_selectOnFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Popover(
    onOpenChange: (_) => setState(() => _copied = false),
    content: PopoverContent(
      width: _width,
      arrow: true,
      tape: PaperTape.top,
      seed: 'share',
      align: OverlayAlign.start,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          const PopoverHeader(
            children: [
              PopoverTitle(Text('Share this notebook')),
              PopoverDescription(Text('Anyone with the link can read it.')),
            ],
          ),
          Row(
            spacing: Spacing.d8,
            children: [
              Expanded(
                child: Input(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: true,
                  semanticLabel: 'Link',
                ),
              ),
              Semantics(
                liveRegion: true,
                child: Button(
                  variant: ButtonVariant.secondary,
                  onPressed: () => unawaited(_copy()),
                  child: Text(switch (_copied) {
                    true => 'Copied',
                    false => 'Copy',
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    child: PopoverTrigger.builder(
      builder: (context, popover) => Button(
        onPressed: popover.toggle,
        leading: const InkIcon('copy'),
        child: const Text('Share'),
      ),
    ),
  );
}
