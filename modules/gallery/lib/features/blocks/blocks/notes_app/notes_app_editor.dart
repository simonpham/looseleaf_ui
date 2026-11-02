import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/notes_app/notes_app.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Whether the open page is read as written or edited.
enum NotesAppMode { page, write }

/// The open page: a toolbar slip (Page or Write, the four marks, tear it
/// out) over a spiral notebook with the title, the body, a tally of reads
/// and the word count.
///
/// Mirrors `NotesAppEditor` in upstream
/// `src/blocks/notes-app/components/notes-app-editor.tsx`.
class NotesAppEditor extends StatefulWidget {
  const NotesAppEditor({
    super.key,
    required this.note,
    required this.notebookName,
    required this.mode,
    required this.onModeChange,
    required this.onChange,
    required this.onDelete,
    required this.onBack,
    required this.wide,
  });

  final NotesAppNote note;
  final String notebookName;
  final NotesAppMode mode;
  final ValueChanged<NotesAppMode> onModeChange;

  /// Called with the changed note.
  final ValueChanged<NotesAppNote> onChange;
  final VoidCallback onDelete;
  final VoidCallback onBack;

  /// Shows the shelf beside the page, so there is no way back to draw.
  final bool wide;

  @override
  State<NotesAppEditor> createState() => _NotesAppEditorState();
}

class _NotesAppEditorState extends State<NotesAppEditor> {
  late final _title = TextEditingController(text: widget.note.title);
  late final _body = TextEditingController(text: widget.note.body);
  final _titleFocus = FocusNode();
  final _bodyFocus = FocusNode();

  static const _marks = [
    NotesAppMark.highlight,
    NotesAppMark.underline,
    NotesAppMark.circle,
    NotesAppMark.strike,
  ];
  static const double _pageMinHeight = 480;
  static const double _bodyMinHeight = 280;

  @override
  void initState() {
    super.initState();
    final blank = widget.note.title.isEmpty && widget.note.body.isEmpty;
    if (widget.mode == NotesAppMode.write && blank) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _titleFocus.requestFocus(),
      );
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _titleFocus.dispose();
    _bodyFocus.dispose();
    super.dispose();
  }

  void _mark(NotesAppMark mark) {
    if (widget.mode != NotesAppMode.write) {
      widget.onModeChange(NotesAppMode.write);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _bodyFocus.requestFocus(),
      );
      return;
    }
    final selection = _body.selection;
    final next = switch (selection.isValid) {
      true => notesAppToggleMark(
        _body.text,
        selection.start,
        selection.end,
        mark,
      ),
      false => null,
    };
    _bodyFocus.requestFocus();
    if (next == null) return;
    _body.value = TextEditingValue(
      text: next.text,
      selection: TextSelection(baseOffset: next.start, extentOffset: next.end),
    );
    widget.onChange(widget.note.copyWith(body: next.text));
  }

  Widget _toolbar(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final note = widget.note;
    return Paper(
      stock: StockName.slip,
      tiltDegrees: -0.2,
      seed: 'notes-toolbar',
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d12,
        vertical: Spacing.d8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d8,
        children: [
          Row(
            spacing: Spacing.d12,
            children: [
              Expanded(
                child: Wrap(
                  spacing: Spacing.d12,
                  runSpacing: Spacing.d8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!widget.wide)
                      Button(
                        variant: ButtonVariant.ghost,
                        size: ButtonSize.iconSm,
                        semanticLabel: 'Back to notes',
                        onPressed: widget.onBack,
                        child: InkIcon(
                          'arrow-left',
                          flip: switch (Directionality.of(context)) {
                            TextDirection.rtl => IconFlip.x,
                            TextDirection.ltr => IconFlip.none,
                          },
                        ),
                      ),
                    ToggleGroup<NotesAppMode>(
                      type: ToggleGroupType.single,
                      size: ToggleSize.sm,
                      variant: ToggleVariant.outline,
                      semanticLabel: 'View',
                      value: {widget.mode},
                      onChanged: (picked) {
                        if (picked.singleOrNull case final mode?) {
                          widget.onModeChange(mode);
                        }
                      },
                      children: const [
                        ToggleGroupItem(
                          value: NotesAppMode.page,
                          child: Text('Page'),
                        ),
                        ToggleGroupItem(
                          value: NotesAppMode.write,
                          child: Text('Write'),
                        ),
                      ],
                    ),
                    ButtonGroup(
                      semanticLabel: 'Marks',
                      children: [
                        for (final mark in _marks)
                          Tooltip(
                            delay: const Duration(milliseconds: 300),
                            content: TooltipContent(
                              seed: 'tip-${mark.name}',
                              child: Text(mark.label),
                            ),
                            child: Button(
                              variant: ButtonVariant.outline,
                              size: ButtonSize.sm,
                              semanticLabel: mark.label,
                              onPressed: () => _mark(mark),
                              child: Annotate(
                                type: mark.type,
                                color: mark.color,
                                kind: mark.kind,
                                seed: 'tool-${mark.name}',
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Spacing.d4,
                                  ),
                                  child: Text('Aa'),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              AlertDialog(
                content: AlertDialogContent(
                  tone: AlertDialogTone.danger,
                  seed: 'tear-out',
                  children: [
                    AlertDialogHeader(
                      children: [
                        const AlertDialogMedia(
                          tone: AlertMediaTone.danger,
                          child: InkIcon('trash'),
                        ),
                        const AlertDialogTitle(Text('Tear this page out?')),
                        AlertDialogDescription(
                          Text(
                            '“${switch (note.title.isEmpty) {
                              true => 'Untitled',
                              false => note.title,
                            }}” goes in the bin with everything written on it.',
                          ),
                        ),
                      ],
                    ),
                    AlertDialogFooter(
                      children: [
                        const AlertDialogCancel(child: Text('Keep it')),
                        AlertDialogAction(
                          variant: ButtonVariant.destructive,
                          onPressed: widget.onDelete,
                          child: const Text('Tear it out'),
                        ),
                      ],
                    ),
                  ],
                ),
                child: AlertDialogTrigger.builder(
                  builder: (context, dialog) => Button(
                    variant: ButtonVariant.ghost,
                    size: ButtonSize.iconSm,
                    semanticLabel: 'Tear this page out',
                    onPressed: dialog.show,
                    child: const InkIcon('trash'),
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Select some words in Write, then press a mark. Press it again to take it off.',
            style: theme.typography.face(
              KevinSansFace.hand,
              cssSize: 14,
              color: theme.colors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final note = widget.note;
    final writing = widget.mode == NotesAppMode.write;
    final muted = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    final bodyStyle = theme.typography.face(
      KevinSansFace.hand,
      cssSize: 17,
      cssLineHeight: 28 / 17,
      color: theme.colors.inkYou,
    );
    return Semantics(
      container: true,
      label: 'Editor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d12,
        children: [
          _toolbar(context),
          Expanded(
            child: ScrollArea(
              bleed: true,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: Spacing.d12),
                child: Notebook(
                  pages: 2,
                  tiltDegrees: 0.15,
                  minHeight: _pageMinHeight,
                  seed: 'notes-page',
                  children: [
                    NotebookPage(
                      children: [
                        NotebookTitle(switch (writing) {
                          true => DefaultTextStyle.merge(
                            style: TextStyle(color: theme.colors.inkYou),
                            child: InputControl(
                              controller: _title,
                              focusNode: _titleFocus,
                              semanticLabel: 'Title',
                              placeholder: 'Untitled',
                              padding: EdgeInsets.zero,
                              onChanged: (title) =>
                                  widget.onChange(note.copyWith(title: title)),
                            ),
                          ),
                          false => Text(switch (note.title.isEmpty) {
                            true => 'Untitled',
                            false => note.title,
                          }),
                        }),
                        switch (writing) {
                          true => ConstrainedBox(
                            constraints: const BoxConstraints(
                              minHeight: _bodyMinHeight,
                            ),
                            child: DefaultTextStyle.merge(
                              style: bodyStyle,
                              child: TextareaControl(
                                controller: _body,
                                focusNode: _bodyFocus,
                                semanticLabel: 'Note',
                                placeholder: 'Start writing on the first line.',
                                padding: EdgeInsets.zero,
                                onChanged: (body) =>
                                    widget.onChange(note.copyWith(body: body)),
                              ),
                            ),
                          ),
                          false => GestureDetector(
                            onDoubleTap: () =>
                                widget.onModeChange(NotesAppMode.write),
                            child: NotesAppMarked(
                              body: note.body,
                              seed: note.id,
                            ),
                          ),
                        },
                        Padding(
                          padding: const EdgeInsets.only(top: Spacing.d28),
                          child: SizedBox(
                            height: Spacing.d28,
                            child: Row(
                              spacing: Spacing.d12,
                              children: [
                                Text('times I have read it', style: muted),
                                Tally(
                                  count: note.reads,
                                  label: 'Read ${note.reads} times',
                                  seed: '${note.id}-reads',
                                ),
                                Button(
                                  size: ButtonSize.xs,
                                  variant: ButtonVariant.ghost,
                                  semanticLabel: 'Count another read',
                                  onPressed: () => widget.onChange(
                                    note.copyWith(reads: note.reads + 1),
                                  ),
                                  child: const Text('+1'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: Spacing.d28,
                          child: Text(
                            '${notesAppWordCount(note.body)} words · ${widget.notebookName}',
                            style: muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
