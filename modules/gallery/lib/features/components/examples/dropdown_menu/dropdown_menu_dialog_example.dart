import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class DropdownMenuDialogExample extends StatefulWidget {
  const DropdownMenuDialogExample({super.key});

  @override
  State<DropdownMenuDialogExample> createState() =>
      _DropdownMenuDialogExampleState();
}

class _DropdownMenuDialogExampleState extends State<DropdownMenuDialogExample> {
  static const _dialogWidth = 425.0;

  bool _showNewDialog = false;
  bool _showShareDialog = false;

  @override
  Widget build(BuildContext context) => Dialog(
    open: _showNewDialog,
    onOpenChange: (open) => setState(() => _showNewDialog = open),
    content: DialogContent(
      maxWidth: _dialogWidth,
      children: [
        const DialogHeader(
          children: [
            DialogTitle(Text('Create New File')),
            DialogDescription(
              Text(
                "Provide a name for your new file. Click create when you're done.",
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(bottom: Spacing.d12),
          child: FieldGroup(
            children: [
              Field(
                children: [
                  FieldLabel(child: Text('File Name')),
                  Input(placeholder: 'document.txt'),
                ],
              ),
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
            Button(onPressed: () {}, child: const Text('Create')),
          ],
        ),
      ],
    ),
    child: Dialog(
      open: _showShareDialog,
      onOpenChange: (open) => setState(() => _showShareDialog = open),
      content: DialogContent(
        maxWidth: _dialogWidth,
        children: [
          const DialogHeader(
            children: [
              DialogTitle(Text('Share File')),
              DialogDescription(
                Text('Anyone with the link will be able to view this file.'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.d12),
            child: FieldGroup(
              children: [
                Field(
                  children: [
                    Label(child: Text('Email Address')),
                    Input(
                      keyboardType: TextInputType.emailAddress,
                      placeholder: 'ada@looseleaf.example',
                    ),
                  ],
                ),
                Field(
                  children: [
                    FieldLabel(child: Text('Message (Optional)')),
                    Textarea(placeholder: 'Check out this file'),
                  ],
                ),
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
              Button(onPressed: () {}, child: const Text('Send Invite')),
            ],
          ),
        ],
      ),
      child: DropdownMenu(
        modal: false,
        content: DropdownMenuContent(
          minWidth: Spacing.d160,
          align: OverlayAlign.end,
          children: [
            const DropdownMenuLabel(child: Text('File Actions')),
            DropdownMenuGroup(
              children: [
                DropdownMenuItem(
                  onSelect: () => setState(() => _showNewDialog = true),
                  child: const Text('New File...'),
                ),
                DropdownMenuItem(
                  onSelect: () => setState(() => _showShareDialog = true),
                  child: const Text('Share...'),
                ),
                const DropdownMenuItem(
                  disabled: true,
                  child: Text('Download'),
                ),
              ],
            ),
          ],
        ),
        child: DropdownMenuTrigger.builder(
          builder: (context, menu) => Button(
            variant: ButtonVariant.outline,
            size: ButtonSize.iconSm,
            semanticLabel: 'Open menu',
            onPressed: menu.toggle,
            child: const InkIcon('ellipsis'),
          ),
        ),
      ),
    ),
  );
}
