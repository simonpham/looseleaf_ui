import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// An inbox with nothing in it: a taped card with a refresh button and
/// All, Unread and Starred tabs, each with its own empty state.
///
/// Mirrors upstream `src/blocks/empty-inbox/page.tsx`.
class EmptyInboxBlock extends StatefulWidget {
  const EmptyInboxBlock({super.key, this.onCompose, this.onRefresh});

  final VoidCallback? onCompose;
  final VoidCallback? onRefresh;

  @override
  State<EmptyInboxBlock> createState() => _EmptyInboxBlockState();
}

class _EmptyInboxBlockState extends State<EmptyInboxBlock> {
  int _checks = 0;

  static const double _maxWidth = 672;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d28,
        vertical: Spacing.d56,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _maxWidth),
          child: Card(
            tape: PaperTape.top,
            tapeKind: TapeKind.washiDots,
            seed: 'empty-inbox',
            children: [
              CardHeader(
                children: [
                  const CardTitle(Text('Inbox')),
                  Semantics(
                    liveRegion: true,
                    child: CardDescription(
                      Text(switch (_checks) {
                        0 => 'Checked just now',
                        _ => 'Checked again. Still nothing new.',
                      }),
                    ),
                  ),
                  CardAction(
                    child: Button(
                      variant: ButtonVariant.ghost,
                      size: ButtonSize.iconSm,
                      semanticLabel: 'Check for new mail',
                      onPressed: () {
                        setState(() => _checks += 1);
                        widget.onRefresh?.call();
                      },
                      child: const InkIcon('rotate-cw'),
                    ),
                  ),
                ],
              ),
              CardContent(
                child: Tabs(
                  defaultValue: 'all',
                  children: [
                    const TabsList(
                      variant: TabsVariant.line,
                      children: [
                        TabsTrigger(value: 'all', child: Text('All mail')),
                        TabsTrigger(value: 'unread', child: Text('Unread')),
                        TabsTrigger(value: 'starred', child: Text('Starred')),
                      ],
                    ),
                    TabsContent(
                      value: 'all',
                      child: Empty(
                        children: [
                          EmptyHeader(
                            children: [
                              EmptyMedia(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: Spacing.d4,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: Spacing.d8,
                                        ),
                                        child: ExcludeSemantics(
                                          child: Circled(
                                            tone: MarkPen.red,
                                            weight: MarkWeight.brush,
                                            seed: 'inbox-zero',
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: Spacing.d4,
                                                  ),
                                              child: Text(
                                                '0',
                                                style: theme.typography.face(
                                                  KevinSansFace.script,
                                                  cssSize: 48,
                                                  cssLineHeight: 1,
                                                  fontWeight: FontWeight.w700,
                                                  color: theme.colors.ink,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Mascot(
                                        pose: 'celebrate',
                                        size: 112,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          top: Spacing.d32,
                                        ),
                                        child: Sticker(
                                          'done',
                                          size: 50,
                                          rotate: 9,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const EmptyTitle(child: Text('Inbox zero')),
                              const EmptyDescription(
                                child: Text(
                                  'You have read everything. Go stretch, or put the kettle on.',
                                ),
                              ),
                            ],
                          ),
                          EmptyContent(
                            children: [
                              Wrap(
                                spacing: Spacing.d12,
                                runSpacing: Spacing.d12,
                                alignment: WrapAlignment.center,
                                children: [
                                  Button(
                                    onPressed: widget.onCompose ?? () {},
                                    leading: const InkIcon('pencil'),
                                    child: const Text('Write a message'),
                                  ),
                                  Button(
                                    variant: ButtonVariant.ghost,
                                    onPressed: () {},
                                    child: const Text('Visit the archive'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const TabsContent(
                      value: 'unread',
                      child: Empty(
                        children: [
                          EmptyHeader(
                            children: [
                              EmptyMedia(pose: 'sleep', size: 124),
                              EmptyTitle(child: Text('All quiet')),
                              EmptyDescription(
                                child: Text(
                                  'Nothing unread. Enjoy it while it lasts.',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const TabsContent(
                      value: 'starred',
                      child: Empty(
                        children: [
                          EmptyHeader(
                            children: [
                              EmptyMedia(pose: 'peek', size: 124),
                              EmptyTitle(child: Text('Nothing starred yet')),
                              EmptyDescription(
                                child: Text(
                                  'Star a message to keep it close. It will wait for you here.',
                                ),
                              ),
                            ],
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
      ),
    );
  }
}
