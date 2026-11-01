/// How settled a component is, upstream `ComponentDoc.status`.
enum ComponentStatus {
  stable('Stable'),
  isNew('New'),
  experimental('Experimental');

  const ComponentStatus(this.label);

  /// The chip text.
  final String label;
}
