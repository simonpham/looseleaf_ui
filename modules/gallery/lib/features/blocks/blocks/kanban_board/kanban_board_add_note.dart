import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/kanban_board/kanban_board.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "Add a note" under a column, opening into a small form: what needs
/// doing and which pad it goes on. Escape or Cancel folds it away.
class KanbanBoardAddNote extends StatefulWidget {
  const KanbanBoardAddNote({
    super.key,
    required this.column,
    required this.onAdd,
  });

  /// The column's title, for screen readers.
  final String column;

  final void Function(String title, KanbanLabel label) onAdd;

  @override
  State<KanbanBoardAddNote> createState() => _KanbanBoardAddNoteState();
}

class _KanbanBoardAddNoteState extends State<KanbanBoardAddNote> {
  final _title = TextEditingController();
  final _opener = FocusNode(debugLabel: 'Add a note');
  bool _open = false;
  bool _error = false;
  KanbanLabel _label = KanbanLabel.studio;

  @override
  void dispose() {
    _title.dispose();
    _opener.dispose();
    super.dispose();
  }

  void _close() {
    setState(() {
      _open = false;
      _error = false;
    });
    _title.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _opener.requestFocus();
    });
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _error = true);
      return;
    }
    widget.onAdd(title, _label);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    if (!_open) {
      return Align(
        alignment: AlignmentDirectional.centerStart,
        child: Button(
          variant: ButtonVariant.ghost,
          focusNode: _opener,
          semanticLabel: 'Add a note to ${widget.column}',
          onPressed: () => setState(() => _open = true),
          leading: const InkIcon('plus'),
          child: const Text('Add a note'),
        ),
      );
    }
    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): _close},
      child: Semantics(
        container: true,
        label: 'New note in ${widget.column}',
        child: Padding(
          padding: const EdgeInsets.all(Spacing.d4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d6,
                children: [
                  const Label(child: Text('What needs doing?')),
                  Input(
                    controller: _title,
                    autofocus: true,
                    invalid: _error,
                    semanticLabel: 'What needs doing?',
                    onChanged: (_) {
                      if (_error) setState(() => _error = false);
                    },
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_error)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        'Write a few words on the note first.',
                        style: theme.typography.interface(
                          cssSize: 14,
                          color: theme.colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d6,
                children: [
                  const Label(child: Text('Which pad?')),
                  Select(
                    value: _label.title,
                    onChanged: (title) => setState(
                      () => _label = KanbanLabel.values.firstWhere(
                        (label) => label.title == title,
                      ),
                    ),
                    content: SelectContent(
                      children: [
                        for (final label in KanbanLabel.values)
                          SelectItem(
                            value: label.title,
                            child: Text(label.title),
                          ),
                      ],
                    ),
                    child: const SelectTrigger(
                      size: SelectSize.sm,
                      semanticLabel: 'Which pad?',
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: Spacing.d8,
                children: [
                  Button(
                    variant: ButtonVariant.outline,
                    size: ButtonSize.sm,
                    onPressed: _close,
                    child: const Text('Cancel'),
                  ),
                  Button(
                    size: ButtonSize.sm,
                    onPressed: _submit,
                    child: const Text('Stick it up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
