import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';

/// What a [SignaturePad] shares with its parts.
///
/// Mirrors `SignaturePadContext` in upstream
/// `src/components/ui/signature-pad.tsx`.
class SignaturePadScope extends InheritedWidget {
  const SignaturePadScope({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.typed,
    required this.strokes,
    required this.value,
    required this.clear,
    required this.width,
    required this.height,
    required this.disabled,
    required this.readOnly,
    required this.invalid,
    required this.message,
    required this.typedFallback,
    required this.seed,
    required this.typedController,
    required this.typedFocusNode,
    required super.child,
  });

  final SignatureMode mode;

  /// Switches between drawing and typing.
  final ValueChanged<SignatureMode> onModeChanged;

  /// The typed name.
  final String typed;
  final List<SketchStroke> strokes;

  /// The signature as a `data:` URL; empty when unsigned.
  final String value;

  /// Empties the current mode's signature.
  final VoidCallback clear;

  final double width;
  final double height;
  final bool disabled;
  final bool readOnly;

  /// Red baseline and the [message] under the pad.
  final bool invalid;
  final String message;

  /// Offers typing the name instead of drawing it.
  final bool typedFallback;

  /// The pad's seed, for its ink.
  final String seed;

  /// The typed-name field's text and focus.
  final TextEditingController typedController;
  final FocusNode typedFocusNode;

  /// Whether a signature is given.
  bool get signed => value.isNotEmpty;

  /// The nearest pad. Throws outside a [SignaturePad], like upstream's
  /// `useSignaturePad`.
  static SignaturePadScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<SignaturePadScope>();
    if (scope == null) {
      throw FlutterError(
        'SignaturePad parts must be used inside a SignaturePad.',
      );
    }
    return scope;
  }

  @override
  bool updateShouldNotify(SignaturePadScope oldWidget) => true;
}
