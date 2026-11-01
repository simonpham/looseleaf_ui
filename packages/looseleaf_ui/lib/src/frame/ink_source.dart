import 'package:looseleaf_ui/src/frame/ink_frame_request.dart';
import 'package:looseleaf_ui/src/frame/ink_markup.dart';

/// Something that draws ink markup for a box: a recipe with its params.
///
/// The ink engine's recipes implement this through an adapter; tests and
/// custom drawings can use [InkSource.callback].
abstract class InkSource {
  const InkSource();

  /// Wraps a drawing function.
  const factory InkSource.callback({
    required String id,
    required InkMarkup Function(InkFrameRequest request) draw,
    String paramsKey,
    Set<String> lazyLayers,
  }) = _CallbackInkSource;

  /// Identifies the drawing, like upstream `recipe.id@recipe.rev`.
  String get id;

  /// A stable string of the params, part of the cache key.
  String get paramsKey;

  /// Layers drawn only once requested (upstream `recipe.lazy`).
  Set<String> get lazyLayers;

  /// Draws markup for [request]. With [InkFrameRequest.lazyOnly], only the
  /// requested lazy layers are needed.
  InkMarkup draw(InkFrameRequest request);
}

class _CallbackInkSource extends InkSource {
  const _CallbackInkSource({
    required this.id,
    required InkMarkup Function(InkFrameRequest request) draw,
    this.paramsKey = '',
    this.lazyLayers = const {},
  }) : _draw = draw;

  @override
  final String id;

  @override
  final String paramsKey;

  @override
  final Set<String> lazyLayers;

  final InkMarkup Function(InkFrameRequest request) _draw;

  @override
  InkMarkup draw(InkFrameRequest request) => _draw(request);
}
