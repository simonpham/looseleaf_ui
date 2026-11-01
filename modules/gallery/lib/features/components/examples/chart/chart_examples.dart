import 'package:gallery/features/components/examples/chart/chart.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/chart/`.
const chartExamples = <GalleryExample>[
  GalleryExample(
    title: 'Bar chart',
    description: 'Bars colored in with a marker that misses the outline a little, numbers on top, and the best day circled by hand. Hover or press the arrow keys: a highlighter lights the column and a slip of paper names it.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'chart/chart_bar_chart_example.dart',
    builder: ChartBarChartExample.new,
  ),
  GalleryExample(
    title: 'Grouped, stacked, sideways',
    description: 'One dataset, four ways to lay it out. Each series keeps its color and its pencil pattern (hatching, dots, cross-hatching), so the bars stay apart in grayscale. Negative values hang below the line.',
    layout: ExampleLayout.stack,
    source: 'chart/chart_grouped_stacked_horizontal_example.dart',
    builder: ChartGroupedStackedHorizontalExample.new,
  ),
  GalleryExample(
    title: 'Line chart',
    description: 'A felt line per series, with a marker shape and a dash pattern for each so lines survive black-and-white print. The legend switches series off; the tooltip follows the pointer and the arrow keys.',
    layout: ExampleLayout.stack,
    source: 'chart/chart_line_chart_example.dart',
    builder: ChartLineChartExample.new,
  ),
  GalleryExample(
    title: 'Area chart',
    description: 'The space under the line is washed with the series color and shaded in pencil: hatching, dots, cross-hatching. Stacked areas add up; the tooltip lists every layer.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'chart/chart_area_chart_example.dart',
    builder: ChartAreaChartExample.new,
  ),
  GalleryExample(
    title: 'Pie and donut',
    description: "Slices colored in with a marker, separated by felt lines, each with its own pencil pattern. The donut's hole is real text: it shows the total, and the slice under the pointer or the arrow keys.",
    layout: ExampleLayout.stack,
    source: 'chart/chart_pie_and_donut_example.dart',
    builder: ChartPieAndDonutExample.new,
  ),
  GalleryExample(
    title: 'Radar chart',
    description: 'A pencil web with a washed and shaded shape per series. The spokes are the keyboard stops: arrow keys walk from axis to axis and the tooltip reads every series on that spoke.',
    layout: ExampleLayout.stack,
    source: 'chart/chart_radar_chart_example.dart',
    builder: ChartRadarChartExample.new,
  ),
  GalleryExample(
    title: 'Radial bars and gauge',
    description: 'Concentric arcs in pale tracks, one ring per row, and a dial with marker zones and a red felt needle. The gauge is a meter: assistive tech reads its value, minimum and maximum.',
    layout: ExampleLayout.stack,
    source: 'chart/chart_radial_and_gauge_example.dart',
    builder: ChartRadialAndGaugeExample.new,
  ),
  GalleryExample(
    title: 'Sparklines',
    description: 'One felt pull and a red dot at the end, a shaded area, or a row of marker bars. A sparkline is a picture with a spoken summary; set interactive to make it a chart you can hover.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'chart/chart_sparklines_example.dart',
    builder: ChartSparklinesExample.new,
  ),
  GalleryExample(
    title: 'Heat map',
    description: 'A half year of days, each square colored in a shade of one marker; or any grid of your own. Arrow keys walk it in two dimensions: left and right by week, up and down by day.',
    layout: ExampleLayout.stack,
    source: 'chart/chart_heatmap_example.dart',
    builder: ChartHeatmapExample.new,
  ),
];
