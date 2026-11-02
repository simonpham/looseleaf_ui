import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A tool call on a tilted note: what ran and how it went.
///
/// Mirrors `ToolNote` in upstream
/// `src/blocks/chat-app/components/chat-app-thread.tsx`.
class ChatAppToolNote extends StatelessWidget {
  const ChatAppToolNote({super.key, required this.title, required this.result});

  final String title;
  final String result;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Bubble(
      shape: BubbleShape.note,
      variant: BubbleVariant.muted,
      children: [
        BubbleContent(
          paper: const BubblePaper(tiltDegrees: -0.7, curl: false),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d16,
            vertical: Spacing.d8,
          ),
          child: DefaultTextStyle.merge(
            style: theme.typography.face(
              KevinSansFace.type,
              cssSize: 14,
              cssLineHeight: 1.375,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.d8,
              children: [
                const InkIcon('terminal', size: Spacing.d14),
                Flexible(child: Text(title)),
                Text(
                  result,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: theme.colors.green,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
