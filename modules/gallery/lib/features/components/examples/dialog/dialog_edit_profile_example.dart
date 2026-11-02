import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DialogEditProfileExample extends StatelessWidget {
  const DialogEditProfileExample({super.key});

  @override
  Widget build(BuildContext context) => Dialog(
    content: DialogContent(
      tape: PaperTape.both,
      tapeKind: TapeKind.washiDots,
      seed: 'edit-profile',
      maxWidth: 425,
      children: [
        const DialogHeader(
          children: [
            DialogTitle(Text('Edit profile')),
            DialogDescription(
              Text(
                "Make changes to your profile here. Click save when you're done.",
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: Spacing.d8),
          child: Column(
            spacing: Spacing.d16,
            children: [
              _Field(label: 'Name', initial: 'Pedro Duarte'),
              _Field(label: 'Username', initial: '@peduarte'),
            ],
          ),
        ),
        DialogFooter(
          children: [
            DialogClose(
              builder: (context, close) => Button(
                variant: ButtonVariant.outline,
                onPressed: close,
                child: const Text('Cancel'),
              ),
            ),
            Button(onPressed: () {}, child: const Text('Save changes')),
          ],
        ),
      ],
    ),
    child: DialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        onPressed: dialog.show,
        child: const Text('Edit profile'),
      ),
    ),
  );
}

class _Field extends StatefulWidget {
  const _Field({required this.label, required this.initial});

  final String label;
  final String initial;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  late final _text = TextEditingController(text: widget.initial);
  final _focus = FocusNode();

  @override
  void dispose() {
    _text.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
    spacing: Spacing.d16,
    children: [
      Expanded(
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Label(focusNode: _focus, child: Text(widget.label)),
        ),
      ),
      Expanded(
        flex: 3,
        child: Input(
          controller: _text,
          focusNode: _focus,
          semanticLabel: widget.label,
        ),
      ),
    ],
  );
}
