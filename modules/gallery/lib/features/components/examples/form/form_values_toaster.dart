import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Lays a toaster for [controller] over the whole window, like the
/// `<Toaster id>` each upstream form example mounts, and toasts the values
/// a form submitted.
class FormValuesToaster extends StatefulWidget {
  const FormValuesToaster({
    super.key,
    required this.controller,
    required this.child,
  });

  final ToastController controller;
  final Widget child;

  /// Toasts [values] as indented JSON.
  static void show(ToastController controller, Map<String, Object?> values) =>
      Sonner(controller)(
        'You submitted the following values:',
        description: const JsonEncoder.withIndent('  ').convert(values),
      );

  @override
  State<FormValuesToaster> createState() => _FormValuesToasterState();
}

class _FormValuesToasterState extends State<FormValuesToaster> {
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  Widget build(BuildContext context) => OverlayPortal(
    controller: _portal,
    overlayLocation: OverlayChildLocation.rootOverlay,
    overlayChildBuilder: (context) => Toaster(
      controller: widget.controller,
      child: const SizedBox.expand(),
    ),
    child: widget.child,
  );
}
