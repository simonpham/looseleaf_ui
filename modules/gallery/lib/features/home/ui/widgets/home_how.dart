import 'package:flutter/widgets.dart';
import 'package:gallery/features/home/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// "How it works": three steps beside three code slips (under them on
/// narrow screens): the dependency, the theme and a widget.
///
/// Mirrors `How` in upstream `src/docs/content/home/how.tsx`.
class HomeHow extends StatelessWidget {
  const HomeHow({super.key, required this.onGuide});

  /// Opens the getting started guide.
  final VoidCallback onGuide;

  /// From this width the steps and the code sit side by side (upstream
  /// `@3xl`).
  static const double sideBySideFrom = 768;

  static const String _pubspec = '''dependencies:
  looseleaf_ui: ^0.1.0''';

  static const String _main = '''import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() => runApp(const NotebookApp());

class NotebookApp extends StatelessWidget {
  const NotebookApp({super.key});

  @override
  Widget build(BuildContext context) {
    const theme = LooseleafThemeData();
    return LooseleafTheme(
      data: theme,
      child: WidgetsApp(
        color: theme.colors.marker,
        builder: (context, _) => const Desk(child: Home()),
      ),
    );
  }
}''';

  static const String _usage = '''import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class Save extends StatelessWidget {
  const Save({super.key});

  @override
  Widget build(BuildContext context) =>
      Button(onPressed: () {}, child: const Text('Save'));
}''';

  @override
  Widget build(BuildContext context) {
    final steps = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d24,
      children: [
        const HowStep(
          number: 1,
          title: 'Add looseleaf_ui to pubspec.yaml',
          text: 'One line under dependencies, once per project.',
        ),
        const HowStep(
          number: 2,
          title: 'Wrap your app in LooseleafTheme',
          text: 'It hands every widget below it the colors, the fonts and the density.',
        ),
        const HowStep(
          number: 3,
          title: 'Use the widgets',
          text: 'Same parts and props as shadcn/ui, as plain Flutter widgets.',
        ),
        Button(
          variant: ButtonVariant.link,
          seed: 'how-guide',
          onPressed: onGuide,
          trailing: const InkIcon('arrow-right'),
          child: const Text('Read the installation guide'),
        ),
      ],
    );
    const code = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d40,
      children: [
        CodeBlock(
          code: _pubspec,
          language: 'text',
          filename: 'pubspec.yaml',
          seed: 'how-pubspec',
          tape: PaperTape.corner,
        ),
        CodeBlock(
          code: _main,
          language: 'ts',
          filename: 'main.dart',
          seed: 'how-main',
        ),
        CodeBlock(
          code: _usage,
          language: 'ts',
          filename: 'save.dart',
          seed: 'how-usage',
          tape: PaperTape.corner,
        ),
      ],
    );
    return DeskSection(
      title: 'How it works',
      lede: 'One package, one theme, and the widgets you already know from shadcn/ui.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < sideBySideFrom) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d40,
              children: [steps, code],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d48,
            children: [
              Expanded(flex: 9, child: steps),
              const Expanded(flex: 11, child: code),
            ],
          );
        },
      ),
    );
  }
}
