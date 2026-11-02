import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `max-w-sm`.
const _maxWidth = Spacing.d384;

class MessageDemoExample extends StatelessWidget {
  const MessageDemoExample({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: const Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.d16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.d24,
        children: [
          Message(
            align: ChatAlign.end,
            children: [
              MessageAvatar(
                child: Avatar(children: [AvatarFallback(child: Text('ME'))]),
              ),
              MessageContent(
                children: [
                  Bubble(
                    children: [
                      BubbleContent(
                        child: Text('Deploying to prod real quick.'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Message(
            children: [
              MessageAvatar(
                child: Avatar(children: [AvatarFallback(child: Text('R'))]),
              ),
              MessageContent(
                children: [
                  Bubble(
                    variant: BubbleVariant.muted,
                    children: [
                      BubbleContent(child: Text("It's 4:55 PM. On a Friday.")),
                    ],
                  ),
                ],
              ),
            ],
          ),
          Message(
            align: ChatAlign.end,
            children: [
              MessageAvatar(
                child: Avatar(children: [AvatarFallback(child: Text('ME'))]),
              ),
              MessageContent(
                children: [
                  Bubble(
                    children: [
                      BubbleContent(child: Text("It's a one-line change.")),
                    ],
                  ),
                  MessageFooter(child: Text('Delivered')),
                ],
              ),
            ],
          ),
          Message(
            children: [
              MessageAvatar(
                child: Avatar(children: [AvatarFallback(child: Text('R'))]),
              ),
              MessageContent(
                children: [
                  BubbleGroup(
                    children: [
                      Bubble(
                        variant: BubbleVariant.muted,
                        children: [
                          BubbleContent(
                            child: Text("It's always a one-line change 😭."),
                          ),
                        ],
                      ),
                      Bubble(
                        variant: BubbleVariant.muted,
                        children: [
                          BubbleContent(
                            child: Text('Alright, let me take a look.'),
                          ),
                          BubbleReactions(
                            child: Text(
                              '👍',
                              semanticsLabel: 'Reactions: thumbs up',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          _Typing(),
        ],
      ),
    ),
  );
}

class _Typing extends StatefulWidget {
  const _Typing();

  @override
  State<_Typing> createState() => _TypingState();
}

class _TypingState extends State<_Typing> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.stop();
      return;
    }
    _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Marker(
      children: [
        MarkerContent(
          child: FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.5).animate(_pulse),
            child: const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Oliver',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  TextSpan(text: ' is typing...'),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
