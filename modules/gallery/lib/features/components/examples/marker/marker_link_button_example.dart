import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/examples/marker/marker.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerLinkButtonExample extends StatefulWidget {
  const MarkerLinkButtonExample({super.key});

  @override
  State<MarkerLinkButtonExample> createState() =>
      _MarkerLinkButtonExampleState();
}

class _MarkerLinkButtonExampleState extends State<MarkerLinkButtonExample> {
  final _toasts = ToastController();

  @override
  void dispose() {
    _toasts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Toaster(
    controller: _toasts,
    child: MarkerColumn(
      children: [
        Marker(
          semanticLabel: 'View the pull request',
          onPressed: () {},
          children: const [
            MarkerIcon(child: InkIcon('git-branch')),
            MarkerContent(child: Text('View the pull request')),
          ],
        ),
        Marker(
          semanticLabel: 'Revert this change',
          onPressed: () => Sonner(_toasts)('You clicked the revert button'),
          children: const [
            MarkerIcon(child: InkIcon('undo-2')),
            MarkerContent(child: Text('Revert this change')),
          ],
        ),
      ],
    ),
  );
}
