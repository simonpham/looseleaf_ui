import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Stands in for the app's file picker: each browse picks the next file.
const _picks = [
  DropzoneFile(name: 'taxi-receipt.jpg', size: 380000, type: 'image/jpeg'),
  DropzoneFile(name: 'hotel.pdf', size: 260000, type: 'application/pdf'),
  DropzoneFile(name: 'lunch.png', size: 190000, type: 'image/png'),
];

class DropzoneRequiredInAFormExample extends StatefulWidget {
  const DropzoneRequiredInAFormExample({super.key});

  @override
  State<DropzoneRequiredInAFormExample> createState() =>
      _DropzoneRequiredInAFormExampleState();
}

class _DropzoneRequiredInAFormExampleState
    extends State<DropzoneRequiredInAFormExample> {
  static const _maxWidth = Spacing.d512;

  final _who = TextEditingController();
  final _whoFocus = FocusNode();
  int _next = 0;
  int _count = 0;
  bool _touched = false;
  String? _result;

  bool get _missing => _touched && _count == 0;

  Future<List<DropzoneFile>?> _browse() async => [
    _picks[_next++ % _picks.length],
  ];

  void _submit() => setState(() {
    _touched = true;
    if (_count == 0) {
      _result = null;
      return;
    }
    final who = switch (_who.text) {
      '' => 'Someone',
      final name => name,
    };
    final receipts = switch (_count) {
      1 => 'receipt',
      _ => 'receipts',
    };
    _result = '$who sent $_count $receipts.';
  });

  @override
  void dispose() {
    _who.dispose();
    _whoFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        seed: 'claim',
        tape: PaperTape.corner,
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Expense claim')),
              CardDescription(Text('Attach at least one receipt.')),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    Label(focusNode: _whoFocus, child: const Text('Your name')),
                    Input(
                      controller: _who,
                      focusNode: _whoFocus,
                      placeholder: 'Ada Lovelace',
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d8,
                  children: [
                    const Label(required: true, child: Text('Receipts')),
                    Dropzone(
                      accept: const ['image/*', '.pdf'],
                      maxFiles: 5,
                      invalid: _missing,
                      onBrowse: _browse,
                      onFilesChange: (files) =>
                          setState(() => _count = files.length),
                    ),
                    if (_missing)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          'Please attach a receipt.',
                          style: theme.typography.interface(
                            cssSize: 14,
                            color: theme.colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          CardFooter(
            divider: true,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _result ?? 'Not sent.',
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
              Button(onPressed: _submit, child: const Text('Send claim')),
            ],
          ),
        ],
      ),
    );
  }
}
