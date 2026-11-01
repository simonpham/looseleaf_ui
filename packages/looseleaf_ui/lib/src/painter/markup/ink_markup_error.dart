/// Thrown when ink markup uses an element, attribute or value the painter
/// does not support, so unsupported markup fails loudly instead of drawing
/// something wrong.
class InkMarkupError extends Error {
  InkMarkupError(this.message);

  final String message;

  @override
  String toString() => 'InkMarkupError: $message';
}
