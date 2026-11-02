import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class MarkerBordersAndEventsExample extends StatelessWidget {
  const MarkerBordersAndEventsExample({super.key});

  static const _maxWidth = 512.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final heading = theme.typography.interface(cssSize: 15);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.d16,
            0,
            Spacing.d16,
            Spacing.d16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d20,
            children: [
              Marker(
                variant: MarkerVariant.border,
                seed: 'b1',
                children: [
                  MarkerContent(
                    child: Text('Thursday, 12 March', style: heading),
                  ),
                ],
              ),
              const Marker(
                children: [
                  MarkerIcon(child: InkIcon('user-plus')),
                  MarkerContent(child: Text('Lin joined the conversation')),
                ],
              ),
              const Marker(
                children: [
                  MarkerIcon(child: InkIcon('video')),
                  MarkerContent(child: Text('Ada started a call')),
                ],
              ),
              Marker(
                variant: MarkerVariant.border,
                tone: MarkerTone.fresh,
                rule: MarkerStyle.wavy,
                seed: 'b2',
                children: [
                  MarkerContent(child: Text('3 unread', style: heading)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
