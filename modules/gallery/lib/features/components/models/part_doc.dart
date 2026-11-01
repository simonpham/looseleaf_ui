import 'package:gallery/features/components/models/prop_doc.dart';

/// One part of a component (`Card`, `CardHeader`, …), upstream `PartDoc`.
class PartDoc {
  const PartDoc({required this.name, this.description, this.props = const []});

  final String name;
  final String? description;

  /// The part's own props; React-only ones (`asChild`, `className`) are left out.
  final List<PropDoc> props;
}
