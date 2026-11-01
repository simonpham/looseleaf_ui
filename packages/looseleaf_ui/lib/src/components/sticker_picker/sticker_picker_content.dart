import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/mascot/mascot.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/sticker_picker/sticker_picker.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

typedef _Cell = ({int s, int i, StickerPickerItem e, String key});

/// What a [StickerPicker] pops up: a search field, batch filters (All,
/// then each batch), the stickers in [columns] columns at [size] px by
/// section, a mascot when nothing matches, and the active sticker's name
/// and batch underneath.
///
/// Typing filters by label, name, batch and tags. Up and down move through
/// the grid from the field, left and right too once the caret is at the
/// end of the text, Home and End jump with an empty field; Enter chooses
/// the active sticker. [side] and [align] place the popover (below, from
/// the start, by default).
///
/// Mirrors `StickerPickerContent` in upstream
/// `src/components/ui/sticker-picker.tsx`.
class StickerPickerContent extends StatefulWidget {
  const StickerPickerContent({
    super.key,
    this.columns = 5,
    this.size = 44,
    this.placeholder = 'Search stickers',
    this.side = OverlaySide.bottom,
    this.align = OverlayAlign.start,
    this.seed,
  });

  /// Stickers per row.
  final int columns;

  /// The stickers' size in pixels.
  final double size;

  /// The search field's placeholder.
  final String placeholder;

  /// Which side of the trigger it pops up on.
  final OverlaySide side;

  /// How it lines up with the trigger.
  final OverlayAlign align;

  /// Pins the hand of the popover's paper.
  final String? seed;

  /// Upstream's `max-h-64`, `min-h-24`.
  static const double listMaxHeight = Spacing.d256;
  static const double listMinHeight = Spacing.d96;

  @override
  State<StickerPickerContent> createState() => _StickerPickerContentState();
}

class _StickerPickerContentState extends State<StickerPickerContent> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _input = FocusNode(debugLabel: 'sticker search');
  String _category = 'all';
  String? _activeKey;
  int _shown = 2;
  Timer? _more;
  int? _said;
  List<StickerPickerSection> _sections = const [];
  List<_Cell> _flat = const [];

  int get _columns => math.max(1, widget.columns);

  @override
  void dispose() {
    _more?.cancel();
    _query.dispose();
    _input.dispose();
    super.dispose();
  }

  List<String> get _words => [
    for (final word in _query.text.trim().toLowerCase().split(RegExp(r'\s+')))
      if (word.isNotEmpty) word,
  ];

  List<(String, String)> _categories(List<StickerPickerItem> catalog) {
    final seen = <String, String>{};
    for (final e in catalog) {
      seen.putIfAbsent(e.category, () => e.categoryLabel);
    }
    return [for (final MapEntry(:key, :value) in seen.entries) (key, value)];
  }

  List<StickerPickerSection> _everything(
    StickerPickerScope picker,
    List<(String, String)> categories,
  ) {
    final words = _words;
    final catalog = picker.catalog;
    if (words.isNotEmpty || _category != 'all') {
      final found = [
        for (final e in catalog)
          if ((_category == 'all' || e.category == _category) &&
              StickerPickerSection.matches(e, words))
            e,
      ];
      if (found.isEmpty) return const [];
      final label = switch (words.isEmpty) {
        false => '${found.length} found',
        true =>
          [
                for (final (key, label) in categories)
                  if (key == _category) label,
              ].firstOrNull ??
              '',
      };
      return [StickerPickerSection(key: 'found', label: label, items: found)];
    }
    final byName = {for (final e in catalog) e.name: e};
    final recent = [
      for (final name in picker.recent) ?byName[name],
    ];
    return [
      if (recent.isNotEmpty)
        StickerPickerSection(key: 'recent', label: 'Recent', items: recent),
      for (final (key, label) in categories)
        StickerPickerSection(
          key: key,
          label: label,
          items: [
            for (final e in catalog)
              if (e.category == key) e,
          ],
        ),
    ];
  }

  _Cell? get _current {
    for (final cell in _flat) {
      if (cell.key == _activeKey) return cell;
    }
    return _flat.firstOrNull;
  }

  void _goTo((int, int)? target) {
    if (target == null) return;
    final (s, i) = target;
    for (final cell in _flat) {
      if (cell.s == s && cell.i == i) {
        setState(() => _activeKey = cell.key);
        return;
      }
    }
  }

  KeyEventResult _keys(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    final current = _current;
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (current == null || _query.value.composing.isValid) {
        return KeyEventResult.ignored;
      }
      StickerPickerScope.of(context).choose(current.e);
      return KeyEventResult.handled;
    }
    if (current == null) return KeyEventResult.ignored;
    final at = (current.s, current.i);
    final text = _query.text;
    final selection = _query.selection;
    switch (key) {
      case LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.arrowDown:
        _goTo(StickerPickerSection.neighbour(_sections, at, key, _columns));
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowLeft || LogicalKeyboardKey.arrowRight:
        final rtl = Directionality.of(context) == TextDirection.rtl;
        final forward = (key == LogicalKeyboardKey.arrowRight) != rtl;
        final caretFree =
            text.isEmpty ||
            switch (forward) {
              true => selection.start == text.length,
              false => selection.end == 0,
            };
        if (!caretFree) return KeyEventResult.ignored;
        _goTo(
          StickerPickerSection.neighbour(
            _sections,
            at,
            switch (forward) {
              true => LogicalKeyboardKey.arrowRight,
              false => LogicalKeyboardKey.arrowLeft,
            },
            _columns,
          ),
        );
        return KeyEventResult.handled;
      case LogicalKeyboardKey.home || LogicalKeyboardKey.end when text.isEmpty:
        final cell = switch (key == LogicalKeyboardKey.home) {
          true => _flat.firstOrNull,
          false => _flat.lastOrNull,
        };
        if (cell != null) setState(() => _activeKey = cell.key);
        return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _progress(bool progressive, int total) {
    if (!progressive || _shown >= total || (_more?.isActive ?? false)) return;
    _more = Timer(const Duration(milliseconds: 24), () {
      if (mounted) setState(() => _shown++);
    });
  }

  void _announce(int total) {
    if (_said == total) return;
    _said = total;
    final message = switch (total) {
      0 => 'No stickers found.',
      1 => '1 sticker.',
      _ => '$total stickers.',
    };
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        SemanticsService.sendAnnouncement(
          View.of(context),
          message,
          Directionality.of(context),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final picker = StickerPickerScope.of(context);
    final theme = LooseleafTheme.of(context);
    final categories = _categories(picker.catalog);
    final everything = _everything(picker, categories);
    final progressive = _words.isEmpty && _category == 'all';
    _progress(progressive, everything.length);
    _sections = switch (progressive) {
      true => everything.take(_shown).toList(),
      false => everything,
    };
    _flat = [
      for (final (s, section) in _sections.indexed)
        for (final (i, e) in section.items.indexed)
          (s: s, i: i, e: e, key: '${section.key}:${e.name}'),
    ];
    _announce(everything.fold(0, (n, s) => n + s.items.length));
    final current = _current;
    final muted = theme.colors.inkMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _keys,
          child: Input(
            controller: _query,
            focusNode: _input,
            autofocus: true,
            placeholder: widget.placeholder,
            semanticLabel: 'Search stickers',
            onChanged: (_) => setState(() => _activeKey = null),
          ),
        ),
        if (categories.length > 1) _filters(categories),
        if (_flat.isNotEmpty) _list(picker, current),
        if (_flat.isEmpty) _empty(theme),
        Padding(
          padding: const EdgeInsets.only(top: Spacing.d8),
          child: ExcludeSemantics(
            child: CustomPaint(
              painter: _DashedRule(
                theme.colors.pencilMark.withValues(alpha: 0.6),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: Spacing.d6),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: Spacing.d24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    spacing: Spacing.d8,
                    children: [
                      Expanded(
                        child: Text(
                          current?.e.label ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.typography.face(
                            KevinSansFace.script,
                            cssSize: 20,
                            cssLineHeight: 1,
                            color: theme.colors.ink,
                          ),
                        ),
                      ),
                      Text(
                        current?.e.categoryLabel ?? '',
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 12,
                          cssLineHeight: 16 / 12,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _filters(List<(String, String)> categories) => Padding(
    padding: const EdgeInsets.only(top: Spacing.d8),
    child: Semantics(
      container: true,
      explicitChildNodes: true,
      label: 'Categories',
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final opaque = LooseleafTheme.of(context).colors.ink;
          final fade = 1 - Spacing.d28 / math.max(bounds.width, Spacing.d28);
          return LinearGradient(
            begin: switch (rtl) {
              true => Alignment.centerRight,
              false => Alignment.centerLeft,
            },
            end: switch (rtl) {
              true => Alignment.centerLeft,
              false => Alignment.centerRight,
            },
            colors: [opaque, opaque, opaque.withValues(alpha: 0)],
            stops: [0, fade, 1],
          ).createShader(bounds);
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: Spacing.d4),
          child: Row(
            spacing: Spacing.d4,
            children: [
              for (final (key, label) in [('all', 'All'), ...categories])
                StickerPickerCategory(
                  label: label,
                  pressed: _category == key,
                  onPressed: () {
                    setState(() {
                      _category = key;
                      _activeKey = null;
                    });
                    _input.requestFocus();
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _list(StickerPickerScope picker, _Cell? current) {
    final theme = LooseleafTheme.of(context);
    final columns = _columns;
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d8),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: 'Stickers',
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: StickerPickerContent.listMinHeight,
            maxHeight: StickerPickerContent.listMaxHeight,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.only(end: Spacing.d4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d6,
              children: [
                for (final section in _sections)
                  Semantics(
                    container: true,
                    explicitChildNodes: true,
                    label: section.label,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ExcludeSemantics(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              Spacing.d4,
                              Spacing.d4,
                              Spacing.d4,
                              Spacing.d2,
                            ),
                            child: Text(
                              section.label,
                              style: theme.typography.face(
                                KevinSansFace.script,
                                cssSize: 18,
                                cssLineHeight: 1,
                                color: theme.colors.inkMuted,
                              ),
                            ),
                          ),
                        ),
                        for (
                          var row = 0;
                          row * columns < section.items.length;
                          row++
                        )
                          Padding(
                            padding: const EdgeInsets.only(top: Spacing.d2),
                            child: Row(
                              spacing: Spacing.d2,
                              children: [
                                for (var c = 0; c < columns; c++)
                                  Expanded(
                                    child: _option(
                                      picker,
                                      section,
                                      row * columns + c,
                                      current,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _option(
    StickerPickerScope picker,
    StickerPickerSection section,
    int index,
    _Cell? current,
  ) {
    if (index >= section.items.length) return const SizedBox.shrink();
    final entry = section.items[index];
    final key = '${section.key}:${entry.name}';
    return StickerPickerOption(
      key: ValueKey(key),
      entry: entry,
      size: widget.size,
      active: current?.key == key,
      selected: picker.value == entry.name,
      scope: section.key,
      onActivate: () => setState(() => _activeKey = key),
      onChoose: () => picker.choose(entry),
    );
  }

  Widget _empty(LooseleafThemeData theme) {
    final query = _query.text.trim();
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.d8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: StickerPickerContent.listMinHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d8,
            vertical: Spacing.d20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: Spacing.d4,
            children: [
              const Mascot(pose: 'search', size: Spacing.d64),
              Text(
                switch (query.isEmpty) {
                  true => 'No stickers to choose from.',
                  false => 'Nothing looks like “$query”.',
                },
                textAlign: TextAlign.center,
                style: theme.typography.face(
                  KevinSansFace.script,
                  cssSize: 20,
                  cssLineHeight: 1.25,
                  color: theme.colors.inkMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRule extends CustomPainter {
  const _DashedRule(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += Spacing.d6) {
      canvas.drawLine(
        Offset(x, 0.5),
        Offset(math.min(x + Spacing.d3, size.width), 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRule oldDelegate) => oldDelegate.color != color;
}
