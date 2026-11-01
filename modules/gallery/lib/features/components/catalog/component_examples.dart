import 'package:gallery/features/components/examples/examples.dart';
import 'package:gallery/features/components/models/models.dart';

/// The examples of every ported component, by upstream slug. A component
/// gets a page in the gallery once it has an entry here.
const Map<String, List<GalleryExample>> componentExamples = {
  'badge': badgeExamples,
  'button': buttonExamples,
  'kbd': kbdExamples,
  'sidebar': sidebarExamples,
  'switch': switchExamples,
};
