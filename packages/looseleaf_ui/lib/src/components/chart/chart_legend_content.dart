import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The default legend body: one entry per series the chart registered,
/// with the very swatch the drawing uses. Entries are toggle buttons that
/// switch a series off (struck through with a wavy line) and on.
///
/// Mirrors `ChartLegendContent` in upstream `src/components/ui/chart.tsx`.
class ChartLegendContent extends StatelessWidget {
  const ChartLegendContent({
    super.key,
    this.hideIcon = false,
    this.verticalAlign = ChartLegendAlign.bottom,
    this.keys,
    this.toggle = true,
  });

  /// Leaves out the config icon or swatch.
  final bool hideIcon;

  /// Which side of the chart it sits on: that side gets no padding.
  final ChartLegendAlign verticalAlign;

  /// Only these entries, in this order.
  final List<String>? keys;

  /// Entries are buttons that switch series off and on.
  final bool toggle;

  @override
  Widget build(BuildContext context) {
    final scope = ChartScope.of(context);
    final only = keys;
    final registered = switch (scope.legend.isEmpty) {
      false => scope.legend,
      true => [
        for (final (slot, key) in scope.keys.indexed)
          _fallback(scope, key, slot),
      ],
    };
    final entries = [
      for (final entry in registered)
        if (only == null || only.contains(entry.key)) entry,
    ];
    final ordered = switch (only) {
      null => entries,
      final order => [
        for (final key in order) ...entries.where((e) => e.key == key),
      ],
    };
    if (ordered.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: switch (verticalAlign) {
        ChartLegendAlign.top => const EdgeInsets.only(bottom: Spacing.d12),
        ChartLegendAlign.bottom => const EdgeInsets.only(top: Spacing.d12),
      },
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: Spacing.d12,
        runSpacing: Spacing.d2,
        children: [for (final entry in ordered) _entry(context, scope, entry)],
      ),
    );
  }

  ChartLegendEntry _fallback(ChartScope scope, String key, int slot) {
    final config = scope.config[key];
    final look = seriesLook(
      XYKind.bar,
      slot,
      scope.keys.length,
      scope.patterns.look,
      pattern: config?.pattern,
      marker: config?.marker,
      dash: config?.dash,
    );
    return ChartLegendEntry(
      key: key,
      slot: slot,
      pattern: look.pattern,
      marker: look.marker,
      dash: look.dash,
      kind: XYKind.bar,
    );
  }

  Widget _entry(BuildContext context, ChartScope scope, ChartLegendEntry e) {
    final theme = LooseleafTheme.of(context);
    final off = scope.hidden.contains(e.key);
    final icon = scope.config[e.key]?.icon;
    final line = e.kind == XYKind.line;
    final name = ChartKeys.label(scope.config, e.key);
    final body = ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: Spacing.d24,
        minWidth: Spacing.d24,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.d6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: Spacing.d6,
          children: [
            if (!hideIcon)
              switch (icon) {
                final own? => IconTheme.merge(
                  data: IconThemeData(
                    size: Spacing.d12,
                    color: theme.colors.inkMuted,
                  ),
                  child: own,
                ),
                null => ChartSwatch(
                  palette: e.slot,
                  pattern: e.pattern,
                  marker: switch (line) {
                    true => e.marker,
                    false => null,
                  },
                  line: line,
                ),
              },
            Text(
              name,
              style: theme.typography
                  .face(KevinSansFace.hand, cssSize: 14, cssLineHeight: 20 / 14)
                  .copyWith(
                    color: switch (off) {
                      true => theme.colors.inkMuted,
                      false => theme.colors.ink,
                    },
                    decoration: switch (off) {
                      true => TextDecoration.lineThrough,
                      false => TextDecoration.none,
                    },
                    decorationStyle: TextDecorationStyle.wavy,
                    decorationThickness: 1,
                  ),
            ),
          ],
        ),
      ),
    );
    if (!toggle) return body;
    return Semantics(
      container: true,
      button: true,
      toggled: !off,
      child: InkInteraction(
        onActivate: () => scope.toggle(e.key),
        builder: (context, states) => Opacity(
          opacity: switch (off) {
            true => 0.7,
            false => 1,
          },
          child: body,
        ),
      ),
    );
  }
}
