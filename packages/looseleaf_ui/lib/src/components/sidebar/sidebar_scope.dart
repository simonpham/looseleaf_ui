import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';

/// Hands a [SidebarProvider]'s [data] down, with the variant of the docked
/// [Sidebar] for its [SidebarInset].
class SidebarScope extends InheritedWidget {
  const SidebarScope({
    super.key,
    required this.data,
    required this.dockedVariant,
    required super.child,
  });

  /// The shared state.
  final SidebarData data;

  /// The variant the docked [Sidebar] reported, null before it did.
  final ValueNotifier<SidebarVariant?> dockedVariant;

  @override
  bool updateShouldNotify(SidebarScope oldWidget) =>
      oldWidget.data != data || oldWidget.dockedVariant != dockedVariant;
}
