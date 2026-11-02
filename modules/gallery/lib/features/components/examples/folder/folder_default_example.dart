import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FolderDefaultExample extends StatelessWidget {
  const FolderDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Folder(
      defaultValue: 'inbox',
      children: [
        FolderTabs(
          semanticLabel: 'Mail',
          children: [
            FolderTab(value: 'inbox', child: Text('Inbox')),
            FolderTab(value: 'drafts', child: Text('Drafts')),
            FolderTab(value: 'sent', child: Text('Sent')),
            FolderTab(value: 'archive', disabled: true, child: Text('Archive')),
          ],
        ),
        FolderContent(
          value: 'inbox',
          seed: 'in',
          child: _Panel(
            title: 'Inbox',
            text: 'Three letters are waiting: one from Ada, and a parcel notice that has been waiting longer.',
          ),
        ),
        FolderContent(
          value: 'drafts',
          seed: 'dr',
          child: _Panel(
            title: 'Drafts',
            text: 'Two drafts, both begun, neither finished.',
          ),
        ),
        FolderContent(
          value: 'sent',
          seed: 'se',
          child: _Panel(title: 'Sent', text: 'Nothing yet this week.'),
        ),
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d8,
      children: [
        Text(
          title,
          style: theme.typography.face(
            KevinSansFace.script,
            cssSize: 30,
            cssLineHeight: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(text),
      ],
    );
  }
}
