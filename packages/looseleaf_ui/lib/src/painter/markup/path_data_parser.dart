import 'dart:ui';

import 'package:looseleaf_ui/src/painter/markup/ink_markup_error.dart';
import 'package:looseleaf_ui/src/painter/markup/number_scanner.dart';

/// Parses SVG path data (`d`) into a [Path]: every command of SVG 1.1 in
/// absolute and relative form (M L H V C S Q T A Z), with implicit repeats.
abstract final class PathDataParser {
  static Path parse(String data) {
    final path = Path();
    final scan = NumberScanner(data);
    var command = 0;
    var current = Offset.zero;
    var start = Offset.zero;
    Offset? lastCubic;
    Offset? lastQuad;
    while (!scan.done) {
      final unit = data.codeUnitAt(scan.at);
      final isCommand = _isCommand(unit);
      if (!isCommand && command == 0) {
        throw InkMarkupError('path data must start with a command: "$data"');
      }
      if (isCommand) {
        command = unit;
        scan.at++;
      }
      final relative = command >= 0x61;
      final base = switch (relative) {
        true => current,
        false => Offset.zero,
      };
      Offset point() {
        final x = scan.number();
        return base + Offset(x, scan.number());
      }

      switch (command | 0x20) {
        case 0x6D:
          current = point();
          start = current;
          path.moveTo(current.dx, current.dy);
          command = switch (relative) {
            true => 0x6C,
            false => 0x4C,
          };
          lastCubic = null;
          lastQuad = null;
        case 0x6C:
          current = point();
          path.lineTo(current.dx, current.dy);
          lastCubic = null;
          lastQuad = null;
        case 0x68:
          current = Offset(scan.number() + base.dx, current.dy);
          path.lineTo(current.dx, current.dy);
          lastCubic = null;
          lastQuad = null;
        case 0x76:
          current = Offset(current.dx, scan.number() + base.dy);
          path.lineTo(current.dx, current.dy);
          lastCubic = null;
          lastQuad = null;
        case 0x63:
          final c1 = point();
          final c2 = point();
          current = point();
          path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, current.dx, current.dy);
          lastCubic = c2;
          lastQuad = null;
        case 0x73:
          final c1 = _reflect(current, lastCubic);
          final c2 = point();
          final end = point();
          path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
          current = end;
          lastCubic = c2;
          lastQuad = null;
        case 0x71:
          final control = point();
          current = point();
          path.quadraticBezierTo(
            control.dx,
            control.dy,
            current.dx,
            current.dy,
          );
          lastQuad = control;
          lastCubic = null;
        case 0x74:
          final control = _reflect(current, lastQuad);
          current = point();
          path.quadraticBezierTo(
            control.dx,
            control.dy,
            current.dx,
            current.dy,
          );
          lastQuad = control;
          lastCubic = null;
        case 0x61:
          final rx = scan.number().abs();
          final ry = scan.number().abs();
          final rotation = scan.number();
          final largeArc = scan.flag();
          final sweep = scan.flag();
          current = point();
          path.arcToPoint(
            current,
            radius: Radius.elliptical(rx, ry),
            rotation: rotation,
            largeArc: largeArc,
            clockwise: sweep,
          );
          lastCubic = null;
          lastQuad = null;
        case 0x7A:
          path.close();
          current = start;
          lastCubic = null;
          lastQuad = null;
          if (scan.atNumber) {
            throw InkMarkupError('numbers after Z in "$data"');
          }
        default:
          throw InkMarkupError('unknown path command in "$data"');
      }
    }
    return path;
  }

  static Offset _reflect(Offset current, Offset? control) {
    if (control == null) return current;
    return current * 2 - control;
  }

  static bool _isCommand(int unit) => switch (unit | 0x20) {
    0x6D || 0x6C || 0x68 || 0x76 || 0x63 || 0x73 || 0x71 || 0x74 => true,
    0x61 || 0x7A => true,
    _ => false,
  };
}
