import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The x on an attached file: takes it off and puts the caret back in the
/// composer.
///
/// Mirrors `RemoveFile` in upstream
/// `src/blocks/chat-app/components/chat-app-thread.tsx`.
class ChatAppRemoveFile extends StatelessWidget {
  const ChatAppRemoveFile({
    super.key,
    required this.name,
    required this.onRemove,
  });

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    return AttachmentAction(
      semanticLabel: 'Remove $name',
      onPressed: () {
        onRemove();
        model.focus();
      },
      child: const InkIcon('x'),
    );
  }
}
