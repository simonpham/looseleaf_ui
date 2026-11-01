/// The component groups of upstream `CATEGORY_ORDER` (`src/docs/core/catalog.ts`),
/// in that order.
enum ComponentCategory {
  actions('Actions'),
  forms('Forms'),
  feedback('Feedback'),
  overlays('Overlays'),
  navigation('Navigation'),
  layout('Layout'),
  dataDisplay('Data display'),
  charts('Charts'),
  paper('Paper'),
  marks('Marks'),
  stickersDoodles('Stickers & doodles'),
  chat('Chat'),
  interactive('Interactive'),
  typography('Typography'),
  icons('Icons');

  const ComponentCategory(this.label);

  /// The heading shown in the nav and on the components index.
  final String label;
}
