import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _tasks = [
  'Ink the outline',
  'Wash the sky',
  'Hatch the shade',
  'Sign it',
];

class FolderProjectFilesExample extends StatefulWidget {
  const FolderProjectFilesExample({super.key});

  @override
  State<FolderProjectFilesExample> createState() =>
      _FolderProjectFilesExampleState();
}

class _FolderProjectFilesExampleState extends State<FolderProjectFilesExample> {
  final _done = {_tasks[0], _tasks[1]};

  void _toggle(String task, bool done) => setState(() {
    if (done) {
      _done.add(task);
      return;
    }
    _done.remove(task);
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final heading = theme.typography.face(
      KevinSansFace.script,
      cssSize: 30,
      cssLineHeight: 1,
      fontWeight: FontWeight.w700,
    );
    return Center(
      child: Folder(
        defaultValue: 'tasks',
        children: [
          const FolderTabs(
            semanticLabel: 'Project files',
            children: [
              FolderTab(value: 'tasks', child: Text('Tasks')),
              FolderTab(value: 'notes', child: Text('Notes')),
              FolderTab(value: 'files', child: Text('Files')),
            ],
          ),
          FolderContent(
            value: 'tasks',
            seed: 'tasks',
            fastener: FastenerKind.clip,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: Spacing.d12),
                    child: Text('Tasks', style: heading),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d8,
                  children: [
                    for (final task in _tasks)
                      Checkbox(
                        value: _done.contains(task),
                        onChanged: (done) => _toggle(task, done),
                        label: Text(task),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.d20),
                  child: Button(
                    size: ButtonSize.sm,
                    onPressed: () {},
                    child: const Text('Add a task'),
                  ),
                ),
              ],
            ),
          ),
          FolderContent(
            value: 'notes',
            seed: 'notes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                Text('Notes', style: heading),
                const Text(
                  'Nothing here yet. The best notes are in the margins.',
                ),
              ],
            ),
          ),
          FolderContent(
            value: 'files',
            seed: 'files',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: Spacing.d8,
              children: [
                Text('Files', style: heading),
                const Text('outline.pdf, sky.png, shade-study.png'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
