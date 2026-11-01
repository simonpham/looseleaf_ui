import 'package:flutter/foundation.dart';
import 'package:gallery/features/components/catalog/catalog.dart';
import 'package:gallery/features/components/models/models.dart';

/// The query typed into the components index filter and what it matches.
class ComponentFilterViewModel extends ChangeNotifier {
  String _query = '';

  String get query => _query;

  /// The trimmed, lower-cased query; empty when there is none.
  String get needle => _query.trim().toLowerCase();

  /// The ported components whose title, slug, category or description
  /// contain the query, title matches first.
  List<ComponentDoc> get matches {
    final text = needle;
    if (text.isEmpty) return const [];
    bool inTitle(ComponentDoc doc) =>
        doc.title.toLowerCase().contains(text) || doc.slug.contains(text);
    final hits = ComponentCatalog.components.where(
      (doc) =>
          inTitle(doc) ||
          doc.category.label.toLowerCase().contains(text) ||
          doc.description.toLowerCase().contains(text),
    );
    return [...hits.where(inTitle), ...hits.where((doc) => !inTitle(doc))];
  }

  void setQuery(String query) {
    if (query == _query) return;
    _query = query;
    notifyListeners();
  }
}
