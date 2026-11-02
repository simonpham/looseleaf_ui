import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class RatingReviewExample extends StatefulWidget {
  const RatingReviewExample({super.key});

  @override
  State<RatingReviewExample> createState() => _RatingReviewExampleState();
}

class _RatingReviewExampleState extends State<RatingReviewExample> {
  final _textFocus = FocusNode();
  double _stars = 0;
  bool _missing = false;
  String _sent = '';

  @override
  void dispose() {
    _textFocus.dispose();
    super.dispose();
  }

  void _post() => setState(() {
    _missing = _stars == 0;
    if (_missing) {
      _sent = '';
      return;
    }
    _sent = 'Thanks: ${Rating.format(_stars)} stars';
  });

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: Spacing.d384),
      child: Card(
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('Field Notes, No. 3')),
              CardDescription(
                Row(
                  spacing: Spacing.d8,
                  children: [
                    Rating(
                      readOnly: true,
                      value: 4.5,
                      allowHalf: true,
                      size: RatingSize.sm,
                    ),
                    Flexible(child: Text('4.5 from 212 readers')),
                  ],
                ),
              ),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d12,
              children: [
                const Label(child: Text('Your rating')),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Rating(
                    value: _stars,
                    allowHalf: true,
                    invalid: _missing,
                    semanticLabel: 'Your rating',
                    onChanged: (stars) => setState(() => _stars = stars),
                  ),
                ),
                Label(focusNode: _textFocus, child: const Text('A few words')),
                Textarea(
                  focusNode: _textFocus,
                  placeholder: 'The paper takes ink beautifully...',
                ),
              ],
            ),
          ),
          CardFooter(
            spacing: Spacing.d12,
            children: [
              Button(onPressed: _post, child: const Text('Post review')),
              Flexible(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _sent,
                    style: theme.typography.interface(
                      cssSize: 14,
                      color: theme.colors.inkMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
