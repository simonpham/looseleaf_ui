import 'package:flutter/widgets.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _positions = [
  (position: ToasterPosition.topLeft, label: 'top-left'),
  (position: ToasterPosition.topCenter, label: 'top-center'),
  (position: ToasterPosition.topRight, label: 'top-right'),
  (position: ToasterPosition.bottomLeft, label: 'bottom-left'),
  (position: ToasterPosition.bottomCenter, label: 'bottom-center'),
  (position: ToasterPosition.bottomRight, label: 'bottom-right'),
];

class SonnerPositionsAndFastenersExample extends StatefulWidget {
  const SonnerPositionsAndFastenersExample({super.key});

  @override
  State<SonnerPositionsAndFastenersExample> createState() =>
      _SonnerPositionsAndFastenersExampleState();
}

class _SonnerPositionsAndFastenersExampleState
    extends State<SonnerPositionsAndFastenersExample> {
  final _toasts = ToastController();
  late final _toast = Sonner(_toasts);
  final _portal = OverlayPortalController();

  var _position = ToasterPosition.bottomRight;
  var _decoration = ToastDecoration.tape;

  String get _positionLabel =>
      _positions.firstWhere((entry) => entry.position == _position).label;

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  void dispose() {
    _toasts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RootOverlayPortal(
    controller: _portal,
    overlayChildBuilder: (context) => Toaster(
      controller: _toasts,
      position: _position,
      decoration: _decoration,
      child: const SizedBox.expand(),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d16,
      children: [
        Semantics(
          container: true,
          label: 'Position',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: Spacing.d12,
            runSpacing: Spacing.d12,
            children: [
              for (final entry in _positions)
                Button(
                  size: ButtonSize.sm,
                  variant: switch (entry.position == _position) {
                    true => ButtonVariant.secondary,
                    false => ButtonVariant.outline,
                  },
                  onPressed: () => setState(() => _position = entry.position),
                  child: Text(entry.label),
                ),
            ],
          ),
        ),
        Semantics(
          container: true,
          label: 'Decoration',
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: Spacing.d12,
            runSpacing: Spacing.d12,
            children: [
              for (final decoration in ToastDecoration.values)
                Button(
                  size: ButtonSize.sm,
                  variant: switch (decoration == _decoration) {
                    true => ButtonVariant.secondary,
                    false => ButtonVariant.outline,
                  },
                  onPressed: () => setState(() => _decoration = decoration),
                  child: Text(decoration.name),
                ),
            ],
          ),
        ),
        Button(
          onPressed: () => _toast.success(
            'Copied to clipboard',
            description: '$_positionLabel, ${_decoration.name}',
          ),
          child: const Text('Toast'),
        ),
      ],
    ),
  );
}
