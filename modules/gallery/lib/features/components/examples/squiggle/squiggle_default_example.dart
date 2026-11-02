import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class SquiggleDefaultExample extends StatelessWidget {
  const SquiggleDefaultExample({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d448),
      child: DefaultTextStyle.merge(
        style: theme.typography.interface(cssSize: 17).copyWith(height: 1.6),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d12,
          children: [
            Text('The morning was slow and gray and smelled of toast.'),
            Squiggle(),
            Text('By noon the whole street had come out to look at the sky.'),
          ],
        ),
      ),
    );
  }
}
