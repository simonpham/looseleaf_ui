import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NapkinTableCardExample extends StatefulWidget {
  const NapkinTableCardExample({super.key});

  @override
  State<NapkinTableCardExample> createState() => _NapkinTableCardExampleState();
}

class _NapkinTableCardExampleState extends State<NapkinTableCardExample> {
  final _note = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      container: true,
      label: 'Note for the kitchen',
      child: Napkin(
        seed: 'table',
        width: 320,
        minHeight: 288,
        children: switch (_sent) {
          true => [
            const NapkinTitle(Text('Sent!')),
            NapkinContent(
              Text(switch (_note.text) {
                '' => '(nothing, but thank you)',
                final note => note,
              }),
            ),
          ],
          false => [
            const NapkinTitle(Text('For the kitchen')),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Spacing.d12),
              child: Textarea(
                controller: _note,
                semanticLabel: 'Your note',
                placeholder: 'allergies, birthdays, the very small pie...',
              ),
            ),
            NapkinFooter(
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Button(
                  size: ButtonSize.sm,
                  onPressed: () => setState(() => _sent = true),
                  child: const Text('Send it'),
                ),
              ),
            ),
          ],
        },
      ),
    ),
  );
}
