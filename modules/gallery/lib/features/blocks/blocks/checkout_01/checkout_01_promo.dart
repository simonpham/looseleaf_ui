import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The promo code box, or the applied code with a way to remove it.
class Checkout01Promo extends StatefulWidget {
  const Checkout01Promo({super.key, required this.code, required this.onCode});

  final String? code;
  final ValueChanged<String?> onCode;

  @override
  State<Checkout01Promo> createState() => _Checkout01PromoState();
}

class _Checkout01PromoState extends State<Checkout01Promo> {
  final _draft = TextEditingController();
  final _input = FocusNode();
  final _remove = FocusNode();
  String _error = '';

  @override
  void didUpdateWidget(Checkout01Promo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code == widget.code) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      switch (widget.code) {
        case null:
          _input.requestFocus();
        case _:
          _remove.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _draft.dispose();
    _input.dispose();
    _remove.dispose();
    super.dispose();
  }

  void _apply() {
    final code = _draft.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = 'Type a code first.');
      return;
    }
    if (!checkoutPromos.containsKey(code)) {
      setState(
        () => _error = 'That code is not on our list. Check the spelling.',
      );
      return;
    }
    setState(() => _error = '');
    _draft.clear();
    widget.onCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final code = widget.code;
    return Semantics(
      container: true,
      label: 'Promo code',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          Label(focusNode: _input, child: const Text('Promo code')),
          if (code != null)
            Wrap(
              spacing: Spacing.d12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: code,
                        style: theme.typography
                            .stamp(cssSize: 14)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text: ' applied: ${checkoutPromos[code]?.label}.',
                      ),
                    ],
                  ),
                  style: theme.typography.interface(
                    cssSize: 14,
                    color: theme.colors.ink,
                  ),
                ),
                Button(
                  variant: ButtonVariant.link,
                  size: ButtonSize.sm,
                  focusNode: _remove,
                  onPressed: () => widget.onCode(null),
                  child: const Text('Remove'),
                ),
              ],
            ),
          if (code == null) ...[
            Row(
              spacing: Spacing.d8,
              children: [
                Expanded(
                  child: Input(
                    controller: _draft,
                    focusNode: _input,
                    placeholder: 'PAPER10',
                    invalid: _error.isNotEmpty,
                    onChanged: (_) => setState(() => _error = ''),
                    onSubmitted: (_) => _apply(),
                  ),
                ),
                Button(
                  variant: ButtonVariant.outline,
                  onPressed: _apply,
                  child: const Text('Apply'),
                ),
              ],
            ),
            if (_error.isNotEmpty) FieldError(child: Text(_error)),
          ],
        ],
      ),
    );
  }
}
