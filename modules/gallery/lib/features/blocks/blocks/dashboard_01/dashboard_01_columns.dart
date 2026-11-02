/// The table's hideable columns, and the page width each needs to show.
enum Dashboard01Column {
  header('Header', 0),
  type('Section type', 896),
  status('Status', 0),
  target('Target', 672),
  limit('Limit', 672),
  reviewer('Reviewer', 768);

  const Dashboard01Column(this.label, this.showsFrom);

  final String label;

  /// The page width this column needs (upstream's `@2xl/main` and up).
  final double showsFrom;
}
