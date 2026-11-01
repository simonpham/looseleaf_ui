/// One element of parsed markup: its tag, attributes in source order, child
/// elements and text content.
class MarkupElement {
  MarkupElement(this.name, this.attributes);

  final String name;
  final Map<String, String> attributes;
  final List<MarkupElement> children = [];
  final StringBuffer text = StringBuffer();
}
