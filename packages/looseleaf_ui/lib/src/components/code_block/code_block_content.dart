import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The lines of a [CodeBlock] in IBM Plex Mono at 13.5 / 1.7 (13 / 1.6
/// when calm), always left to right. Long lines scroll sideways unless the
/// block wraps; the body is a tab stop whose arrow keys scroll it, with a
/// blue felt ring on keyboard focus.
///
/// Give it [code] (and [language]) to show other code than the block's.
///
/// Mirrors `CodeBlockContent` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockContent extends StatefulWidget {
  const CodeBlockContent({
    super.key,
    this.code,
    this.language,
    this.focusNode,
    this.forcedStates = const {},
  });

  /// Shown instead of the block's code.
  final String? code;

  /// The language of [code]; the block's when null.
  final String? language;

  final FocusNode? focusNode;

  /// States shown whatever the input (`focused` draws the ring).
  final Set<InkState> forcedStates;

  @override
  State<CodeBlockContent> createState() => _CodeBlockContentState();
}

class _CodeBlockContentState extends State<CodeBlockContent> {
  static const double _arrowStep = Spacing.d40;

  final ScrollController _scroll = ScrollController();
  bool _focusVisible = false;

  late final Map<Type, Action<Intent>> _actions = {
    ScrollIntent: CallbackAction<ScrollIntent>(onInvoke: _onScroll),
  };

  static const Map<ShortcutActivator, Intent> _shortcuts = {
    SingleActivator(LogicalKeyboardKey.arrowLeft): ScrollIntent(
      direction: AxisDirection.left,
    ),
    SingleActivator(LogicalKeyboardKey.arrowRight): ScrollIntent(
      direction: AxisDirection.right,
    ),
  };

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Object? _onScroll(ScrollIntent intent) {
    if (!_scroll.hasClients) return null;
    final position = _scroll.position;
    final step = switch (intent.direction) {
      AxisDirection.left => -_arrowStep,
      _ => _arrowStep,
    };
    final target = (position.pixels + step).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    position.jumpTo(target);
    return null;
  }

  void _onFocusHighlight(bool visible) {
    if (_focusVisible == visible) return;
    setState(() => _focusVisible = visible);
  }

  CodeBlockModel _model(CodeBlockScope scope) {
    final code = widget.code;
    if (code == null) return scope.model;
    return CodeBlockModel.build(
      code,
      switch (widget.language) {
        final String name => CodeLang.parse(name),
        null => scope.model.language,
      },
      diff: scope.model.diff,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final scope = CodeBlockScope.of(context);
    final model = _model(scope);
    final calm = theme.density == LooseleafDensity.calm;
    final style = theme.typography.mono(
      cssSize: switch (calm) {
        true => 13,
        false => 13.5,
      },
      cssLineHeight: switch (calm) {
        true => 1.6,
        false => 1.7,
      },
      color: theme.colors.ink,
    );
    final lines = Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.d16,
        Spacing.d12,
        Spacing.d16,
        Spacing.d16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, line) in model.lines.indexed)
            CodeBlockLineView(line: line, index: i, diff: model.diff),
        ],
      ),
    );
    return InkSurface(
      source: RecipeInkSource(
        codeBodyRecipe,
        const NoParams(),
        json: const NoParams().toJson(),
      ),
      seed: '${scope.seed}|body',
      still: true,
      states: {
        ...widget.forcedStates,
        if (_focusVisible) InkState.focused,
      },
      child: Semantics(
        container: true,
        child: FocusableActionDetector(
          focusNode: widget.focusNode,
          shortcuts: _shortcuts,
          actions: _actions,
          onShowFocusHighlight: _onFocusHighlight,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: style,
              child: switch (scope.wrap) {
                true => lines,
                false => _scrolling(lines),
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _scrolling(Widget lines) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      if (!width.isFinite) return lines;
      return SingleChildScrollView(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: width),
          child: lines,
        ),
      );
    },
  );
}
