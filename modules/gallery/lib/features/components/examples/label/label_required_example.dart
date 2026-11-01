import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class LabelRequiredExample extends StatefulWidget {
  const LabelRequiredExample({super.key});

  @override
  State<LabelRequiredExample> createState() => _LabelRequiredExampleState();
}

class _LabelRequiredExampleState extends State<LabelRequiredExample> {
  final _nameFocus = FocusNode();
  final _noteFocus = FocusNode();

  @override
  void dispose() {
    _nameFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d96 * 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: [
              Label(
                focusNode: _nameFocus,
                required: true,
                child: const Text('Full name'),
              ),
              Input(focusNode: _nameFocus, placeholder: 'Ada Lovelace'),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d8,
            children: [
              Label(
                focusNode: _noteFocus,
                child: Text.rich(
                  TextSpan(
                    text: 'Note ',
                    children: [
                      TextSpan(
                        text: '(optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: theme.colors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Textarea(focusNode: _noteFocus),
            ],
          ),
        ],
      ),
    );
  }
}
