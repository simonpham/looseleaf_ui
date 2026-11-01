import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';
import 'package:looseleaf_ui/src/components/sketchpad/sketchpad.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// What lies on the signing paper under the ink: the baseline with its
/// sign-here cross (red when invalid), the typed name set in lettering,
/// a value given from outside as an image, and the "Sign here" or "Type
/// your name below" hint while it is empty.
///
/// Mirrors `Guides` in upstream `src/components/ui/signature-pad.tsx`.
class SignaturePadGuides extends StatelessWidget {
  const SignaturePadGuides({super.key});

  /// The hint's start inset, upstream `start-[12%]`.
  static const double hintStart = 0.12;

  /// How far the hint sits above the baseline, upstream `2.4rem`.
  static const double hintRise = 38.4;

  static final Map<String, InkDocument> _typedCache = {};

  static InkDocument? _typed(SignaturePadScope scope) {
    if (scope.mode != SignatureMode.type) return null;
    final svg = typedSignature(
      scope.typed,
      scope.width,
      scope.height,
      scope.seed,
    ).svg;
    if (svg.isEmpty) return null;
    if (_typedCache.length > 16) _typedCache.clear();
    return _typedCache[svg] ??= InkDocument.parse(svg);
  }

  @override
  Widget build(BuildContext context) {
    final scope = SignaturePadScope.of(context);
    final theme = LooseleafTheme.of(context);
    final params = SignatureBaselineParams(invalid: scope.invalid);
    final typed = _typed(scope);
    final hasTyped = scope.typed.trim().isNotEmpty;
    final empty = scope.strokes.isEmpty && !hasTyped && !scope.signed;
    final showImage = scope.signed && scope.strokes.isEmpty && !hasTyped;
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          return Stack(
            fit: StackFit.expand,
            children: [
              InkSurface(
                source: RecipeInkSource(
                  signatureBaselineRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: '${scope.seed}|line',
                still: true,
                child: const SizedBox.expand(),
              ),
              if (typed != null)
                CustomPaint(
                  painter: _TypedPainter(
                    document: typed,
                    width: scope.width,
                    height: scope.height,
                    theme: theme,
                  ),
                ),
              if (showImage) SignatureImage(value: scope.value),
              if (empty)
                PositionedDirectional(
                  start: constraints.maxWidth * hintStart,
                  top: height * signatureBaselineAt - hintRise,
                  child: ExcludeSemantics(
                    child: Text(
                      switch (scope.mode) {
                        SignatureMode.type => 'Type your name below',
                        SignatureMode.draw => 'Sign here',
                      },
                      style: theme.typography.face(
                        KevinSansFace.script,
                        cssSize: 24,
                        cssLineHeight: 1,
                        color: theme.colors.pencilText,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TypedPainter extends CustomPainter {
  _TypedPainter({
    required this.document,
    required this.width,
    required this.height,
    required this.theme,
  }) : super(repaint: InkTextures.instance);

  final InkDocument document;
  final double width;
  final double height;
  final LooseleafThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / width, size.height / height);
    SketchInk.paint(canvas, document, InkPaintContext(theme: theme));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TypedPainter oldDelegate) =>
      !identical(oldDelegate.document, document) ||
      oldDelegate.width != width ||
      oldDelegate.height != height ||
      oldDelegate.theme != theme;
}
