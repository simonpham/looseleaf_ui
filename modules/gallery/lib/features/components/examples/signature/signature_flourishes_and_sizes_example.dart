import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SignatureFlourishesAndSizesExample extends StatelessWidget {
  const SignatureFlourishesAndSizesExample({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d24,
    children: [
      _Group(
        kicker: 'Flourish',
        children: [
          Signature(child: Text('Grace Hopper')),
          Signature(
            flourish: SignatureFlourish.underline,
            child: Text('Grace Hopper'),
          ),
          Signature(
            flourish: SignatureFlourish.none,
            child: Text('Grace Hopper'),
          ),
        ],
      ),
      _Group(
        kicker: 'Size',
        children: [
          Signature(size: SignatureSize.sm, child: Text('Grace Hopper')),
          Signature(child: Text('Grace Hopper')),
          Signature(size: SignatureSize.lg, child: Text('Grace Hopper')),
        ],
      ),
      _Group(
        kicker: 'Pen',
        children: [
          Signature(child: Text('Katherine J.')),
          Signature(tone: MarkPen.ink, child: Text('Katherine J.')),
          Signature(
            tone: MarkPen.red,
            weight: MarkWeight.brush,
            child: Text('M. Curie'),
          ),
        ],
      ),
    ],
  );
}

class _Group extends StatelessWidget {
  const _Group({required this.kicker, required this.children});

  final String kicker;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: Spacing.d4,
      children: [
        Text(
          kicker,
          style: theme.typography.face(
            KevinSansFace.type,
            cssSize: 12,
            color: theme.colors.inkMuted,
          ),
        ),
        Wrap(
          spacing: Spacing.d40,
          runSpacing: Spacing.d12,
          crossAxisAlignment: WrapCrossAlignment.end,
          children: children,
        ),
      ],
    );
  }
}
