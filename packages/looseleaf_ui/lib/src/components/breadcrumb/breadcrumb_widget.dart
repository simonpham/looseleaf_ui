import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';

/// Where you are: a trail of links to the pages above this one. Put a
/// [BreadcrumbList] in it.
///
/// ```dart
/// Breadcrumb(
///   child: BreadcrumbList(children: [
///     BreadcrumbItem(children: [BreadcrumbLink(onPressed: home, child: Text('Home'))]),
///     BreadcrumbSeparator(),
///     BreadcrumbItem(children: [BreadcrumbPage(child: Text('Breadcrumb'))]),
///   ]),
/// )
/// ```
///
/// Mirrors `Breadcrumb` in upstream `src/components/ui/breadcrumb.tsx`.
class Breadcrumb extends StatelessWidget {
  const Breadcrumb({super.key, required this.child, this.label = 'breadcrumb'});

  final Widget child;

  /// The landmark's accessible name.
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    role: SemanticsRole.navigation,
    label: label,
    child: child,
  );
}
