/// One prop of a component part, upstream `PropDoc` (`src/docs/types.ts`).
class PropDoc {
  const PropDoc({
    required this.name,
    required this.type,
    this.defaultValue,
    required this.description,
    this.required = false,
  });

  final String name;
  final String type;

  /// The default, as upstream writes it; null when there is none.
  final String? defaultValue;
  final String description;

  /// Whether the prop must be given.
  final bool required;
}
