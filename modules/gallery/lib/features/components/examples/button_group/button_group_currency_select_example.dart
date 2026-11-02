import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ButtonGroupCurrencySelectExample extends StatefulWidget {
  const ButtonGroupCurrencySelectExample({super.key});

  @override
  State<ButtonGroupCurrencySelectExample> createState() =>
      _ButtonGroupCurrencySelectExampleState();
}

class _ButtonGroupCurrencySelectExampleState
    extends State<ButtonGroupCurrencySelectExample> {
  static const _currencies = [
    (r'$', 'US Dollar'),
    ('€', 'Euro'),
    ('£', 'British Pound'),
  ];
  static const _amountWidth = 160.0;

  final _amount = TextEditingController(text: '10.00');
  var _currency = r'$';
  var _sent = '';

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _send() => setState(() {
    final amount = switch (_amount.text) {
      '' => '0',
      final text => text,
    };
    _sent = 'Sent $_currency$amount';
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d16,
      children: [
        ButtonGroup(
          semanticLabel: 'Send money',
          children: [
            Flexible(
              child: ButtonGroup(
                children: [
                  Select(
                    value: _currency,
                    onChanged: (currency) =>
                        setState(() => _currency = currency),
                    content: SelectContent(
                      children: [
                        for (final (symbol, label) in _currencies)
                          SelectItem(
                            value: symbol,
                            textValue: label,
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: '$symbol '),
                                  TextSpan(
                                    text: label,
                                    style: TextStyle(
                                      color: theme.colors.inkMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    child: const SelectTrigger(semanticLabel: 'Currency'),
                  ),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _amountWidth),
                      child: Input(
                        controller: _amount,
                        placeholder: '10.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        semanticLabel: 'Amount',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ButtonGroup(
              children: [
                Button(
                  variant: ButtonVariant.outline,
                  size: ButtonSize.icon,
                  semanticLabel: 'Send',
                  onPressed: _send,
                  child: const InkIcon('arrow-right'),
                ),
              ],
            ),
          ],
        ),
        Semantics(
          liveRegion: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: Spacing.d24),
            child: Text(
              _sent,
              style: theme.typography.interface(
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
