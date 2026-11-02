import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The paper the preview is drawn on.
enum AppearancePaper {
  plain('Plain', StockName.paper, RuleName.none),
  ruled('Ruled', StockName.paper, RuleName.ruled),
  graph('Graph', StockName.graph, null),
  dots('Dots', StockName.dotGrid, null),
  kraft('Kraft', StockName.kraft, RuleName.none);

  const AppearancePaper(this.label, this.stock, this.rules);

  final String label;
  final StockName stock;

  /// The printed rules; the stock's own when null.
  final RuleName? rules;
}

/// One choice in a radio list: its value, name and help line.
typedef AppearanceChoice<T> = ({
  T value,
  String name,
  String help,
  bool ready,
});

/// Everything the appearance settings choose.
@immutable
class Appearance {
  const Appearance({
    this.theme = 'notebook',
    this.density = LooseleafDensity.comfortable,
    this.motion = LooseleafMotion.system,
    this.fine = false,
    this.paper = AppearancePaper.ruled,
    this.direction = TextDirection.ltr,
  });

  final String theme;
  final LooseleafDensity density;
  final LooseleafMotion motion;
  final bool fine;
  final AppearancePaper paper;
  final TextDirection direction;

  Appearance copyWith({
    String? theme,
    LooseleafDensity? density,
    LooseleafMotion? motion,
    bool? fine,
    AppearancePaper? paper,
    TextDirection? direction,
  }) => Appearance(
    theme: theme ?? this.theme,
    density: density ?? this.density,
    motion: motion ?? this.motion,
    fine: fine ?? this.fine,
    paper: paper ?? this.paper,
    direction: direction ?? this.direction,
  );

  /// The theme data a provider gets for these choices.
  LooseleafThemeData apply(LooseleafThemeData base) => base.copyWith(
    density: density,
    motion: motion,
    tier: switch (fine) {
      true => LooseleafTier.hi,
      false => LooseleafTier.lo,
    },
    textDirection: direction,
  );

  /// What to give your own [LooseleafTheme] for these choices.
  String get snippet {
    final fields = [
      if (density != LooseleafDensity.comfortable)
        'density: LooseleafDensity.${density.name}',
      if (motion != LooseleafMotion.system)
        'motion: LooseleafMotion.${motion.name}',
      if (fine) 'tier: LooseleafTier.hi',
      if (direction != TextDirection.ltr)
        'textDirection: TextDirection.${direction.name}',
    ];
    final data = switch (fields) {
      [] => 'const LooseleafThemeData()',
      _ => 'const LooseleafThemeData(\n    ${fields.join(',\n    ')},\n  )',
    };
    return "import 'package:looseleaf_ui/looseleaf_ui.dart';\n\n"
        'LooseleafTheme(\n  data: $data,\n  child: const App(),\n)';
  }

  @override
  bool operator ==(Object other) =>
      other is Appearance &&
      other.theme == theme &&
      other.density == density &&
      other.motion == motion &&
      other.fine == fine &&
      other.paper == paper &&
      other.direction == direction;

  @override
  int get hashCode =>
      Object.hash(theme, density, motion, fine, paper, direction);
}

const List<AppearanceChoice<String>> appearanceThemes = [
  (
    value: 'notebook',
    name: 'Notebook',
    help: 'Cream paper, felt tip, terracotta marker.',
    ready: true,
  ),
  (
    value: 'forest',
    name: 'Forest',
    help: 'Sage felt, kraft slips, petrol-teal ink.',
    ready: false,
  ),
  (
    value: 'zine',
    name: 'Zine',
    help: 'Lilac mat, louder stickers, heavier pens.',
    ready: false,
  ),
];

const List<AppearanceChoice<LooseleafDensity>> appearanceDensities = [
  (
    value: LooseleafDensity.comfortable,
    name: 'Comfortable',
    help: 'Roomy controls, the full hand-drawn wobble.',
    ready: true,
  ),
  (
    value: LooseleafDensity.compact,
    name: 'Compact',
    help: 'Tighter controls for people who like to see more.',
    ready: true,
  ),
  (
    value: LooseleafDensity.calm,
    name: 'Calm',
    help: 'Hairline pencil, no wobble, no tilt. For tables and long forms.',
    ready: true,
  ),
];

const List<AppearanceChoice<LooseleafMotion>> appearanceMotions = [
  (
    value: LooseleafMotion.system,
    name: 'Follow my device',
    help:
        'Ink is written on, paper settles. Off when your device asks for less motion.',
    ready: true,
  ),
  (
    value: LooseleafMotion.reduced,
    name: 'Keep it still',
    help: 'Everything just appears, finished.',
    ready: true,
  ),
];
