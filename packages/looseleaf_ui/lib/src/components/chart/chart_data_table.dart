import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/chart/chart.dart';

/// What a chart gives screen readers besides its summary: its data as a
/// table (a caption, then one row per category with its column headings)
/// and, when it is interactive, a polite live region announcing the
/// keyboard cursor. Nothing of it is painted.
///
/// Mirrors `ChartData`, `ChartTable` and `ChartLive` in upstream
/// `src/components/ui/chart.tsx`.
class ChartDataTable extends StatelessWidget {
  const ChartDataTable({
    super.key,
    required this.caption,
    this.table,
    this.announce,
  });

  /// The table's caption, the chart's name.
  final String caption;

  /// The data.
  final TableModel? table;

  /// The cursor whose lines are announced; null when the chart is a
  /// picture.
  final ChartController? announce;

  @override
  Widget build(BuildContext context) {
    final controller = announce;
    return SizedBox.shrink(
      child: Stack(
        children: [
          if (table case final data?) _table(data),
          if (controller != null)
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => Semantics(
                container: true,
                liveRegion: true,
                label: controller.announce,
                child: const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _table(TableModel data) {
    final clipped = data.clipped;
    return Semantics(
      container: true,
      label: caption,
      child: Column(
        children: [
          for (final row in data.rows)
            Semantics(
              container: true,
              label: [
                for (final (index, cell) in row.indexed)
                  switch (index) {
                    0 => cell,
                    _ => '${data.head.elementAtOrNull(index) ?? ''} $cell',
                  },
              ].join(', '),
              child: const SizedBox.shrink(),
            ),
          if (clipped != null)
            Semantics(
              container: true,
              label:
                  'Showing the first ${clipped.shown} of ${clipped.total} rows.',
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
