import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/error_404/error_404.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A 404 page on a taped sheet: a pinned napkin with the digits, Stubby
/// shrugging, a search box ("/" jumps to it), and ways home.
///
/// Mirrors upstream `src/blocks/error-404/page.tsx`.
class Error404Block extends StatefulWidget {
  const Error404Block({super.key, this.onSearch, this.onGoBack});

  final ValueChanged<String>? onSearch;
  final VoidCallback? onGoBack;

  @override
  State<Error404Block> createState() => _Error404BlockState();
}

class _Error404BlockState extends State<Error404Block> {
  static const double _maxWidth = 768;
  static const double _textWidth = 448;
  static const double _wideFrom = 576;
  static const double _kbdFrom = 640;

  final _query = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_onKey);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _query.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent || event.character != '/') return false;
    final keyboard = HardwareKeyboard.instance;
    if (keyboard.isMetaPressed ||
        keyboard.isControlPressed ||
        keyboard.isAltPressed) {
      return false;
    }
    final typing = primaryFocus?.context?.widget is EditableText;
    if (typing) return false;
    _searchFocus.requestFocus();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final showKbd = MediaQuery.sizeOf(context).width >= _kbdFrom;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= _wideFrom;
        return Padding(
          padding: switch (wide) {
            true => const EdgeInsets.symmetric(
              horizontal: Spacing.d32,
              vertical: Spacing.d56,
            ),
            false => const EdgeInsets.symmetric(
              horizontal: Spacing.d32,
              vertical: Spacing.d40,
            ),
          },
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxWidth),
              child: Paper(
                tilt: false,
                tape: PaperTape.both,
                seed: 'error-404',
                padding: EdgeInsets.symmetric(
                  horizontal: switch (wide) {
                    true => Spacing.d48,
                    false => Spacing.d24,
                  },
                  vertical: Spacing.d48,
                ),
                child: Column(
                  children: [
                    Error404Scene(wide: wide),
                    const SizedBox(height: Spacing.d40),
                    Text(
                      'Error 404 · Page not found',
                      textAlign: TextAlign.center,
                      style: theme.typography.stamp(
                        cssSize: 14,
                        color: theme.colors.pencilText,
                      ),
                    ),
                    const SizedBox(height: Spacing.d12),
                    const Lettering(
                      'This page wandered off',
                      size: LetteringSize.md,
                      wobble: 0.4,
                      seed: 'error-404-title',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.d16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _textWidth),
                      child: Text(
                        'We looked under the desk, behind the stapler and in '
                        'the recycling. Nothing. The link may be old, or '
                        'mistyped.',
                        textAlign: TextAlign.center,
                        style: theme.typography.face(
                          KevinSansFace.hand,
                          cssSize: 18,
                          cssLineHeight: 28 / 18,
                          color: theme.colors.inkSoft,
                        ),
                      ),
                    ),
                    const SizedBox(height: Spacing.d32),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _textWidth),
                      child: InputGroup(
                        focusNode: _searchFocus,
                        semanticLabel: 'Search the site',
                        children: [
                          const InputGroupAddon(child: InkIcon('search')),
                          InputGroupInput(
                            controller: _query,
                            placeholder: 'Try searching for pages…',
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) =>
                                widget.onSearch?.call(value.trim()),
                          ),
                          if (showKbd)
                            const InputGroupAddon(
                              align: InputGroupAlign.inlineEnd,
                              child: ExcludeSemantics(
                                child: Kbd(child: Text('/')),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.d24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: Spacing.d16,
                      runSpacing: Spacing.d12,
                      children: [
                        Button(
                          size: ButtonSize.lg,
                          onPressed: () {},
                          leading: const InkIcon('house'),
                          child: const Text('Take me home'),
                        ),
                        Button(
                          size: ButtonSize.lg,
                          variant: ButtonVariant.outline,
                          onPressed: widget.onGoBack ?? () {},
                          leading: InkIcon(
                            'arrow-left',
                            flip: switch (Directionality.of(context)) {
                              TextDirection.rtl => IconFlip.x,
                              TextDirection.ltr => IconFlip.none,
                            },
                          ),
                          child: const Text('Go back'),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.d32),
                    DefaultTextStyle.merge(
                      style: theme.typography.face(
                        KevinSansFace.hand,
                        cssSize: 15,
                        color: theme.colors.inkMuted,
                      ),
                      child: const Text.rich(
                        textAlign: TextAlign.center,
                        TextSpan(
                          children: [
                            TextSpan(text: 'Still lost? '),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: Error404Link(
                                'Tell us what you were looking for',
                              ),
                            ),
                            TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
