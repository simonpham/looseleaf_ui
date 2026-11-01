import 'package:gallery/features/getting_started/models/guide_step.dart';

/// The getting started guide, upstream `src/docs/content/getting-started.tsx`
/// told for Flutter.
const List<GuideStep> guideSteps = [
  GuideStep(
    title: 'Requirements',
    paragraphs: [
      'Dart 3.13 or newer and Flutter 3.47 or newer. Nothing else: no Material, no Cupertino, no platform plugins.',
      'Every widget works on every platform Flutter draws on: iOS, Android, macOS, Windows, Linux and the web.',
    ],
  ),
  GuideStep(
    title: 'Add the package',
    description:
        'One dependency brings the widgets, the ink engine and the fonts.',
    code: [
      (
        title: 'pubspec.yaml',
        code: 'dependencies:\n  looseleaf_ui: ^0.1.0',
      ),
      (title: 'Terminal', code: 'flutter pub get'),
    ],
  ),
  GuideStep(
    title: 'Wrap your app',
    description: 'LooseleafTheme gives every widget below it the paint tokens, Kevin Sans, density, tier and motion.',
    paragraphs: [
      'Put it above your WidgetsApp (or MaterialApp, if you keep one). Decode the paper and grain textures once at startup: painting works before they are ready, the tooth just shows up a frame later.',
    ],
    code: [
      (
        title: 'main.dart',
        code: '''import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(InkTextures.instance.load());
  runApp(const NotebookApp());
}

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
}''',
      ),
    ],
  ),
  GuideStep(
    title: 'Use a widget',
    description:
        'Same parts and props as shadcn/ui, with Flutter names for callbacks.',
    paragraphs: [
      'onClick is onPressed, checked is value, onCheckedChange is onChanged. Every widget takes a seed: the same seed always draws the same hand.',
    ],
    code: [
      (
        title: 'save_button.dart',
        code: '''import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) => Button(
    onPressed: onSave,
    leading: const InkIcon('check'),
    child: const Text('Save changes'),
  );
}''',
      ),
    ],
  ),
  GuideStep(
    title: 'Fonts',
    description: 'Kevin Sans in three tuned roles, and IBM Plex Mono for code.',
    paragraphs: [
      'The package bundles both. theme.typography.face(KevinSansFace.hand) is the interface text, KevinSansFace.script is for titles, notes and numbers, KevinSansFace.type is for stamps, kickers and receipts, and mono() is code.',
    ],
    code: [
      (
        title: 'title.dart',
        code: '''final theme = LooseleafTheme.of(context);

Text(
  'Field notes',
  style: theme.typography.face(
    KevinSansFace.script,
    cssSize: 32,
    fontWeight: FontWeight.w700,
    color: theme.colors.inkYou,
  ),
)''',
      ),
    ],
  ),
  GuideStep(
    title: 'Tokens',
    description:
        'Every color is a paint token, so theming never touches widget code.',
    paragraphs: [
      'Read colors from LooseleafTheme.of(context).colors and sizes from Spacing. A theme is a LooseleafColors with the tokens you want changed.',
    ],
    code: [
      (
        title: 'Using the palette',
        code: '''final colors = LooseleafTheme.of(context).colors;

Padding(
  padding: const EdgeInsets.all(Spacing.d16),
  child: Text('Due Friday', style: TextStyle(color: colors.red)),
)''',
      ),
      (
        title: 'Overriding a token',
        code: '''LooseleafTheme(
  data: LooseleafThemeData(
    colors: const LooseleafColors().copyWith(marker: const Color(0xFF3F7CC0)),
  ),
  child: app,
)''',
      ),
    ],
  ),
  GuideStep(
    title: 'Density, tier and motion',
    description: 'The dials on the drawing layer, all on LooseleafThemeData.',
    paragraphs: [
      'density: comfortable (40 px targets), compact (32 px) or calm (28 px, hairline pencil, no wobble). tier: lo draws fewer points, hi richer strokes. motion: system follows the platform setting, reduced turns every animation off. textDirection flips the whole drawing for right-to-left.',
      'Try them all from the settings button in the top bar of this gallery.',
    ],
    code: [
      (
        title: 'dense_screen.dart',
        code: '''LooseleafTheme(
  data: LooseleafTheme.of(context).copyWith(
    density: LooseleafDensity.calm,
  ),
  child: const OrdersTable(),
)''',
      ),
    ],
  ),
  GuideStep(
    title: 'The desk',
    description: 'Paper looks best on something.',
    paragraphs: [
      'Desk paints the linen and the lamp vignette, with optional things lying about. Sheets (Card, Paper, PaperPage) cast their short umber shadows onto it.',
    ],
    code: [
      (
        title: 'root.dart',
        code: '''Desk(
  objects: const [DeskObject.coffee, DeskObject.clips],
  padding: const EdgeInsets.all(Spacing.d48),
  child: Card(children: [...]),
)''',
      ),
    ],
  ),
];
