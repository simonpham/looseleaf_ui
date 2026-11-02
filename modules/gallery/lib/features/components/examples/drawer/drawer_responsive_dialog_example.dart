import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `(min-width: 640px)`.
const _desktopFrom = 640.0;

/// `sm:max-w-[425px]`.
const _dialogMaxWidth = 425.0;

const _description =
    "Make changes to your profile here. Click save when you're done.";

class DrawerResponsiveDialogExample extends StatefulWidget {
  const DrawerResponsiveDialogExample({super.key});

  @override
  State<DrawerResponsiveDialogExample> createState() =>
      _DrawerResponsiveDialogExampleState();
}

class _DrawerResponsiveDialogExampleState
    extends State<DrawerResponsiveDialogExample> {
  bool _open = false;

  void _setOpen(bool open) => setState(() => _open = open);

  @override
  Widget build(BuildContext context) {
    final trigger = DialogTrigger.builder(
      builder: (context, dialog) => Button(
        variant: ButtonVariant.outline,
        onPressed: dialog.show,
        child: const Text('Edit profile'),
      ),
    );
    if (MediaQuery.sizeOf(context).width >= _desktopFrom) {
      return Dialog(
        open: _open,
        onOpenChange: _setOpen,
        content: const DialogContent(
          tape: PaperTape.top,
          tapeKind: TapeKind.kraft,
          seed: 'rd',
          maxWidth: _dialogMaxWidth,
          children: [
            DialogHeader(
              children: [
                DialogTitle(Text('Edit profile')),
                DialogDescription(Text(_description)),
              ],
            ),
            _ProfileForm(),
          ],
        ),
        child: trigger,
      );
    }
    return Drawer(
      open: _open,
      onOpenChange: _setOpen,
      content: DrawerContent(
        seed: 'rd',
        children: [
          const DrawerHeader(
            children: [
              DrawerTitle(Text('Edit profile')),
              DrawerDescription(Text(_description)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: Spacing.d16),
            child: _ProfileForm(),
          ),
          DrawerFooter(
            children: [
              DrawerClose(
                builder: (context, close) => Button(
                  variant: ButtonVariant.outline,
                  onPressed: close,
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ],
      ),
      child: trigger,
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm();

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _email = TextEditingController(text: 'ada@analytical.engine');
  final _username = TextEditingController(text: '@ada');

  @override
  void dispose() {
    _email.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d16,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          const Label(child: Text('Email')),
          Input(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            semanticLabel: 'Email',
          ),
        ],
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          const Label(child: Text('Username')),
          Input(controller: _username, semanticLabel: 'Username'),
        ],
      ),
      Button(onPressed: () {}, child: const Text('Save changes')),
    ],
  );
}
