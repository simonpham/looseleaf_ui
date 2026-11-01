import 'dart:math' as math;

import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Data from the upstream chart docs examples.
abstract final class ChartSamples {
  static const List<ChartRow> sales = [
    {'day': 'Mon', 'sales': 12},
    {'day': 'Tue', 'sales': 19},
    {'day': 'Wed', 'sales': 8},
    {'day': 'Thu', 'sales': 24},
    {'day': 'Fri', 'sales': 16},
    {'day': 'Sat', 'sales': 21},
    {'day': 'Sun', 'sales': 14},
  ];

  static const List<ChartRow> visitors = [
    {'month': 'Jan', 'desktop': 186, 'mobile': 80, 'tablet': 40},
    {'month': 'Feb', 'desktop': 305, 'mobile': 200, 'tablet': 66},
    {'month': 'Mar', 'desktop': 237, 'mobile': 120, 'tablet': 90},
    {'month': 'Apr', 'desktop': 73, 'mobile': 190, 'tablet': 84},
    {'month': 'May', 'desktop': 209, 'mobile': 130, 'tablet': 72},
    {'month': 'Jun', 'desktop': 214, 'mobile': 140, 'tablet': 110},
  ];

  static const ChartConfig devices = {
    'desktop': ChartSeriesConfig(label: 'Desktop'),
    'mobile': ChartSeriesConfig(label: 'Mobile'),
    'tablet': ChartSeriesConfig(label: 'Tablet'),
  };

  static const List<ChartRow> browsers = [
    {'browser': 'chrome', 'visitors': 275},
    {'browser': 'safari', 'visitors': 200},
    {'browser': 'firefox', 'visitors': 187},
    {'browser': 'edge', 'visitors': 173},
    {'browser': 'other', 'visitors': 90},
  ];

  static const ChartConfig browserConfig = {
    'chrome': ChartSeriesConfig(label: 'Chrome'),
    'safari': ChartSeriesConfig(label: 'Safari'),
    'firefox': ChartSeriesConfig(label: 'Firefox'),
    'edge': ChartSeriesConfig(label: 'Edge'),
    'other': ChartSeriesConfig(label: 'Other'),
  };

  static const List<ChartRow> rings = [
    {'name': 'move', 'value': 78},
    {'name': 'exercise', 'value': 52},
    {'name': 'stand', 'value': 91},
  ];

  static const ChartConfig ringConfig = {
    'move': ChartSeriesConfig(label: 'Move'),
    'exercise': ChartSeriesConfig(label: 'Exercise'),
    'stand': ChartSeriesConfig(label: 'Stand'),
  };

  static const List<ChartRow> cups = [
    {'drink': 'Tea', 'cups': 23},
    {'drink': 'Coffee', 'cups': 14},
    {'drink': 'Cocoa', 'cups': 8},
    {'drink': 'Water', 'cups': 31},
  ];

  static List<ChartRow> get pages => [
    for (var i = 0; i < 180; i++)
      {
        'date': DateTime.utc(2026, 1, 1 + i).toIso8601String().substring(0, 10),
        'value': switch (_wave(i) > 0.6) {
          true => (_wave(i) * 2).round(),
          false => 0,
        },
      },
  ];

  static double _wave(int i) =>
      math.sin(i / 9) + math.sin(i / 3.3) + ((i * 7) % 5) / 2;

  static const List<String> hours = ['9am', '11am', '1pm', '3pm', '5pm'];
  static const List<String> week = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

  static List<ChartRow> get busy => [
    for (final (r, day) in week.indexed)
      for (final (c, hour) in hours.indexed)
        {'day': day, 'hour': hour, 'orders': ((r + 1) * (c + 2) * 3) % 17},
  ];

  static const List<ChartRow> points = [
    {'height': 150, 'weight': 52},
    {'height': 158, 'weight': 61},
    {'height': 163, 'weight': 58},
    {'height': 170, 'weight': 70},
    {'height': 176, 'weight': 74},
    {'height': 181, 'weight': 82},
    {'height': 188, 'weight': 85},
  ];

  static const List<double> trend = [4, 6, 5, 8, 7, 9, 12, 10, 13, 15];
}
