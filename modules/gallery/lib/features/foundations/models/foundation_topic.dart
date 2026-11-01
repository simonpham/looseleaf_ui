/// A paint token shown as a swatch: its `--ll-` name without the prefix.
typedef Swatch = ({String token, String label});

/// A Kevin Sans face shown as a sample.
typedef FontSample = ({String token, String label, String role});

/// Another foundations topic worth reading next.
typedef SeeAlso = ({String label, String slug});

/// One foundations page, upstream `FoundationTopic` (`src/docs/core/foundations.ts`).
class FoundationTopic {
  const FoundationTopic({
    required this.slug,
    required this.title,
    required this.summary,
    required this.facts,
    this.swatches = const [],
    this.fonts = const [],
    this.see = const [],
  });

  final String slug;
  final String title;
  final String summary;

  /// The page's paragraphs.
  final List<String> facts;
  final List<Swatch> swatches;
  final List<FontSample> fonts;
  final List<SeeAlso> see;
}
