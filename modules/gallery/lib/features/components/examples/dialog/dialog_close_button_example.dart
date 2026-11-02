import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DialogCloseButtonExample extends StatefulWidget {
  const DialogCloseButtonExample({super.key});

  @override
  State<DialogCloseButtonExample> createState() =>
      _DialogCloseButtonExampleState();
}

class _DialogCloseButtonExampleState extends State<DialogCloseButtonExample> {
  final _link = TextEditingController(
    text: 'https://kevintngo.github.io/looseleaf/docs/installation',
  );

  @override
  void dispose() {
    _link.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    content: DialogContent(
      maxWidth: Spacing.d448,
      children: [
        const DialogHeader(
          children: [
            DialogTitle(Text('Share link')),
            DialogDescription(
              Text('Anyone who has this link will be able to view this.'),
            ),
          ],
        ),
        Input(controller: _link, readOnly: true, semanticLabel: 'Link'),
        DialogFooter(
          alignment: MainAxisAlignment.start,
          children: [
            DialogClose(
              builder: (context, close) => Button(
                variant: ButtonVariant.secondary,
                onPressed: close,
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ],
    ),
    child: DialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        onPressed: dialog.show,
        child: const Text('Share'),
      ),
    ),
  );
}
