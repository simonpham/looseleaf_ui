import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DialogLongContentExample extends StatelessWidget {
  const DialogLongContentExample({super.key});

  static const _clauses = [
    'You may keep this notebook as long as you like, and write in it in any color.',
    'Pages torn out belong to whoever holds them; margins belong to the reader.',
    'Doodles are protected speech. Coffee rings are an acceptable form of signature.',
    'If you find a pencil stub in the binding, it is yours, and it was always yours.',
    'We will never sell your handwriting. We could not read it either.',
    'By turning the page you agree to turn the next one, if there is a next one.',
    'Erasers are provided as a courtesy and may be worn down to nothing without notice.',
    'A drawing of a cat counts as a drawing of any cat, and the cat may object.',
    'Ink that bleeds through belongs to the page behind it.',
    'If the notebook is lost, it is not lost: it is simply somewhere else, being written in.',
  ];

  @override
  Widget build(BuildContext context) => Dialog(
    content: DialogContent(
      seed: 'terms',
      maxWidth: 448,
      children: [
        const DialogHeader(
          children: [
            DialogTitle(Text('Terms of the notebook')),
            DialogDescription(
              Text('Read to the end, or at least to the margin.'),
            ),
          ],
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 224),
          child: DialogBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d12,
              children: [
                for (final (i, clause) in _clauses.indexed)
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${i + 1}. ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: clause),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        DialogFooter(
          children: [
            DialogClose(
              builder: (context, close) => Button(
                variant: ButtonVariant.ghost,
                onPressed: close,
                child: const Text('Decline'),
              ),
            ),
            DialogClose(
              builder: (context, close) =>
                  Button(onPressed: close, child: const Text('I agree')),
            ),
          ],
        ),
      ],
    ),
    child: DialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        onPressed: dialog.show,
        child: const Text('Terms of the notebook'),
      ),
    ),
  );
}
