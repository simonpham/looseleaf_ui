import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A search box with a magnifier: in the pad's header as a group of its
/// own, or as a plain [bar] for a top strip.
///
/// Mirrors `SearchForm` in upstream
/// `src/blocks/sidebar-shared/sidebar-search-form.tsx`.
class SearchForm extends StatelessWidget {
  const SearchForm({
    super.key,
    this.placeholder = 'Search the guide...',
    this.label = 'Search',
    this.bar = false,
    this.onSubmitted,
  });

  final String placeholder;

  /// The field's accessible name.
  final String label;

  /// The top strip's box instead of the pad's.
  final bool bar;

  /// Called with the query on Enter.
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final box = Semantics(
      container: true,
      label: 'search',
      child: SizedBox(
        height: Spacing.d32,
        child: InputGroup(
          children: [
            const InputGroupAddon(
              child: Opacity(opacity: 0.6, child: InkIcon('search')),
            ),
            InputGroupInput(
              placeholder: placeholder,
              semanticLabel: label,
              onSubmitted: onSubmitted,
            ),
          ],
        ),
      ),
    );
    if (bar) return box;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.d8),
      child: box,
    );
  }
}
