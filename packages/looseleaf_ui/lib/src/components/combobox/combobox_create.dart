import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_controller.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_row.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds the create row's text from the typed [text].
typedef ComboboxCreateBuilder =
    Widget Function(
      BuildContext context,
      String text,
    );

/// A blue "Create “…”" row shown when the typed text matches no item;
/// choosing it calls [onCreate] and takes the text as the value.
///
/// Mirrors `ComboboxCreate` in upstream `src/components/ui/combobox.tsx`.
class ComboboxCreate extends StatefulWidget {
  const ComboboxCreate({super.key, this.onCreate, this.builder});

  /// Called with the typed text, so the app can add it to its items.
  final ValueChanged<String>? onCreate;

  /// The row's text; `Create "text"` when null.
  final ComboboxCreateBuilder? builder;

  @override
  State<ComboboxCreate> createState() => _ComboboxCreateState();
}

class _ComboboxCreateState extends State<ComboboxCreate> {
  static const String _key = '\u0000create';
  ComboboxController? _controller;
  ComboboxEntry? _entry;

  void _create(ComboboxController controller) {
    final text = controller.query.trim();
    widget.onCreate?.call(text);
    controller.select(text);
  }

  @override
  void dispose() {
    if (_entry case final entry?) _controller?.unregister(entry);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final text = controller.query.trim();
    final shown =
        text.isNotEmpty &&
        !controller.hasItem(text) &&
        (controller.fieldMode != ComboboxFieldMode.single || controller.dirty);
    if (!identical(controller, _controller)) {
      if (_entry case final entry?) _controller?.unregister(entry);
      _controller = controller;
      _entry = controller.register(
        value: _key,
        label: '',
        keywords: const [],
        disabled: false,
        group: null,
        pinned: shown,
      );
    }
    _entry
      ?..pinned = shown
      ..context = context
      ..onSelect = () => _create(controller);
    if (!shown) return const SizedBox.shrink();
    final colors = LooseleafTheme.of(context).colors;
    return Semantics(
      container: true,
      button: true,
      onTap: () => _create(controller),
      child: ComboboxRow(
        active: controller.active == _key,
        color: colors.inkYou,
        leading: InkIcon('plus', size: 16, color: colors.inkYou),
        onHover: () => controller.highlight(_key),
        onTap: () => _create(controller),
        child: widget.builder?.call(context, text) ?? Text('Create "$text"'),
      ),
    );
  }
}
