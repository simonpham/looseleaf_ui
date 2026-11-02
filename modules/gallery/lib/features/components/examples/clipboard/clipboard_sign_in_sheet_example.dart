import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class ClipboardSignInSheetExample extends StatefulWidget {
  const ClipboardSignInSheetExample({super.key});

  @override
  State<ClipboardSignInSheetExample> createState() =>
      _ClipboardSignInSheetExampleState();
}

class _ClipboardSignInSheetExampleState
    extends State<ClipboardSignInSheetExample> {
  final _visitors = ['Ada Lovelace', 'Grace Hopper'];
  final _name = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _sign() {
    final name = _name.text.trim();
    setState(() {
      if (name.isNotEmpty) _visitors.add(name);
      _name.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Center(
      child: Clipboard(
        tone: Accent.teal,
        seed: 'sign',
        tiltDegrees: -0.8,
        children: [
          ClipboardPaper(
            seed: 'sign-p',
            child: Semantics(
              container: true,
              label: 'Visitors sign-in sheet',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: Spacing.d28,
                    child: Text(
                      'Visitors',
                      style: theme.typography
                          .face(KevinSansFace.script, cssSize: 28)
                          .copyWith(fontWeight: FontWeight.bold, height: 1),
                    ),
                  ),
                  for (final (index, visitor) in _visitors.indexed)
                    SizedBox(
                      height: Spacing.d28,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(
                          start: Spacing.d20,
                        ),
                        child: Text('${index + 1}. $visitor'),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: Spacing.d8,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            spacing: Spacing.d4,
                            children: [
                              Label(
                                focusNode: _nameFocus,
                                child: const Text('Your name'),
                              ),
                              Input(
                                controller: _name,
                                focusNode: _nameFocus,
                                placeholder: 'Sign here',
                                onSubmitted: (_) => _sign(),
                              ),
                            ],
                          ),
                        ),
                        Button(onPressed: _sign, child: const Text('Sign')),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
