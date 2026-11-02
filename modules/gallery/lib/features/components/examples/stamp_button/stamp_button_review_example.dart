import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class StampButtonReviewExample extends StatefulWidget {
  const StampButtonReviewExample({super.key});

  @override
  State<StampButtonReviewExample> createState() =>
      _StampButtonReviewExampleState();
}

class _StampButtonReviewExampleState extends State<StampButtonReviewExample> {
  final _approve = FocusNode();
  List<StampImpression> _marks = const [];

  @override
  void dispose() {
    _approve.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() => _marks = const []);
    _approve.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final last = _marks.lastOrNull;
    final status = switch (last) {
      null => 'Waiting for review',
      StampImpression(name: 'stamp-approved') => 'Approved',
      _ => 'Rejected',
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d512),
      child: StampSurface(
        value: _marks,
        onValueChanged: (marks) => setState(() => _marks = marks),
        child: Card(
          children: [
            const CardHeader(
              children: [
                CardTitle(Text('Expense report 118')),
                CardDescription(
                  Text(
                    'Maya Chen, felt tips and washi tape for the March workshop.',
                  ),
                ),
              ],
            ),
            CardContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d16,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          r'$ 148.00',
                          style: theme.typography
                              .interface(cssSize: 24, color: theme.colors.ink)
                              .copyWith(
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                        ),
                      ),
                      Semantics(
                        liveRegion: true,
                        child: Badge(
                          variant: switch (last) {
                            null => BadgeVariant.outline,
                            _ => BadgeVariant.primary,
                          },
                          child: Text(status),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d80),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: Spacing.d16,
                      children: [
                        StampButton(
                          stamp: 'stamp-approved',
                          impressionId: 'decision',
                          place: const Offset(0.68, 0.44),
                          focusNode: _approve,
                          child: const Text('Approve'),
                        ),
                        const StampButton(
                          stamp: 'stamp-void',
                          text: 'Rejected',
                          impressionId: 'decision',
                          place: Offset(0.46, 0.5),
                          child: Text('Reject'),
                        ),
                        const Spacer(),
                        Button(
                          variant: ButtonVariant.ghost,
                          disabled: _marks.isEmpty,
                          onPressed: _reset,
                          child: const Text('Reset'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
