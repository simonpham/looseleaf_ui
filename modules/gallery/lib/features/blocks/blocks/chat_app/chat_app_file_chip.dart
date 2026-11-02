import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/chat_app/chat_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A file as a small attachment slip, with optional [actions].
///
/// Mirrors `FileChip` in upstream
/// `src/blocks/chat-app/components/chat-app-thread.tsx`.
class ChatAppFileChip extends StatelessWidget {
  const ChatAppFileChip({super.key, required this.file, this.actions});

  final ChatAppFile file;
  final Widget? actions;

  @override
  Widget build(BuildContext context) => Attachment(
    size: AttachmentSize.sm,
    seed: file.name,
    children: [
      const AttachmentMedia(child: InkIcon('file-text')),
      AttachmentContent(
        children: [
          AttachmentTitle(child: Text(file.name)),
          AttachmentDescription(child: Text(file.size)),
        ],
      ),
      ?actions,
    ],
  );
}
