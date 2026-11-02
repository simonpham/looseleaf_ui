import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Turns a signature into its value: an SVG or PNG `data:` URL of the
/// drawn strokes or the typed name, with [pad] units of room around it.
///
/// Mirrors `compose` and `publish` in upstream
/// `src/components/ui/signature-pad.tsx`.
abstract final class SignatureExport {
  /// The room around the signature, upstream's `pad`.
  static const double pad = 6;

  static final RegExp _cssVar = RegExp(r'var\((--ll-[a-z0-9-]+)\)');

  /// The signature as an SVG document, or empty when there is none.
  static String svg(
    SignatureMode mode,
    List<SketchStroke> strokes,
    String text, {
    required double width,
    required double height,
    required String seed,
    LooseleafColors colors = const LooseleafColors(),
  }) {
    if (mode == SignatureMode.draw && strokes.isNotEmpty) {
      return SketchpadExport.svg(
        strokes,
        width: width,
        height: height,
        colors: colors,
        background: false,
        margin: pad,
        title: 'Signature',
      );
    }
    if (mode != SignatureMode.type || text.trim().isEmpty) return '';
    final typed = typedSignature(text, width, height, seed).svg;
    final p = JsMath.numberToString(pad);
    final w = JsMath.numberToString(width + 2 * pad);
    final h = JsMath.numberToString(height + 2 * pad);
    final doc =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="-$p -$p $w $h" '
        'width="$w" height="$h" role="img"><title>Signature</title>$typed</svg>';
    return doc.replaceAllMapped(_cssVar, (match) {
      final name = (match[1] ?? '').replaceFirst('--ll-', '');
      return switch (colors.token(name)) {
        final color? => InkExport.cssColor(color),
        null => match[0] ?? '',
      };
    });
  }

  /// The signature as a `data:` URL in [format], or empty when there is
  /// none. PNGs render at [scale] and fall back to SVG when encoding fails.
  static Future<String> dataUrl(
    SignatureMode mode,
    List<SketchStroke> strokes,
    String text, {
    required double width,
    required double height,
    required String seed,
    SignatureFormat format = SignatureFormat.svg,
    LooseleafThemeData theme = const LooseleafThemeData(),
    double scale = 2,
  }) async {
    final doc = svg(
      mode,
      strokes,
      text,
      width: width,
      height: height,
      seed: seed,
      colors: theme.colors,
    );
    if (doc.isEmpty) return '';
    final svgUrl = svgDataUrl(doc);
    if (format == SignatureFormat.svg) return svgUrl;
    final bytes = switch (mode) {
      SignatureMode.draw => await SketchpadExport.png(
        strokes,
        width: width,
        height: height,
        theme: theme,
        background: false,
        margin: pad,
        scale: scale,
      ),
      SignatureMode.type => await _typedPng(
        text,
        width: width,
        height: height,
        seed: seed,
        theme: theme,
        scale: scale,
      ),
    };
    if (bytes == null) return svgUrl;
    return 'data:image/png;base64,${base64Encode(bytes)}';
  }

  static Future<Uint8List?> _typedPng(
    String text, {
    required double width,
    required double height,
    required String seed,
    required LooseleafThemeData theme,
    required double scale,
  }) async {
    final document = InkDocument.parse(
      typedSignature(text, width, height, seed).svg,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(scale)
      ..translate(pad, pad);
    SketchInk.paint(canvas, document, InkPaintContext(theme: theme));
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      ((width + 2 * pad) * scale).round(),
      ((height + 2 * pad) * scale).round(),
    );
    picture.dispose();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }
}
