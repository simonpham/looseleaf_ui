import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _seats = [
  (
    name: 'Ada Lovelace',
    email: 'ada@looseleaf.dev',
    role: 'Owner',
    status: AvatarStatus.online,
    price: 25,
  ),
  (
    name: 'Jo Okafor',
    email: 'jo@looseleaf.dev',
    role: 'Admin',
    status: AvatarStatus.busy,
    price: 25,
  ),
  (
    name: 'Mika Kobayashi',
    email: 'mika@looseleaf.dev',
    role: 'Member',
    status: AvatarStatus.away,
    price: 12,
  ),
  (
    name: 'Sam Reyes',
    email: 'sam@looseleaf.dev',
    role: 'Member',
    status: AvatarStatus.offline,
    price: 12,
  ),
];

class TableTeamExample extends StatelessWidget {
  const TableTeamExample({super.key});

  static const _maxWidth = 768.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final muted = theme.typography.interface(
      cssSize: 14,
      color: theme.colors.inkMuted,
    );
    const figures = TextStyle(fontFeatures: [FontFeature.tabularFigures()]);
    final total = _seats.fold(0, (sum, seat) => sum + seat.price);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Card(
          seed: 'team-billing',
          children: [
            CardHeader(
              children: [
                const CardTitle(Text('Seats')),
                const CardDescription(
                  Text(
                    'Everyone who can open the notebook, and what they cost this month.',
                  ),
                ),
                CardAction(
                  child: Button(
                    size: ButtonSize.sm,
                    leading: const InkIcon('plus'),
                    onPressed: () {},
                    child: const Text('Add a seat'),
                  ),
                ),
              ],
            ),
            CardContent(
              child: InkTable(
                columnWidths: const {
                  0: FlexColumnWidth(),
                  1: IntrinsicColumnWidth(),
                  2: IntrinsicColumnWidth(),
                  3: FixedColumnWidth(Spacing.d56),
                },
                header: TableHeader(
                  rows: [
                    InkTableRow(
                      cells: [
                        const TableHead(child: Text('Person')),
                        const TableHead(child: Text('Role')),
                        const TableHead(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text('Per month'),
                          ),
                        ),
                        TableHead(
                          child: Semantics(
                            label: 'Actions',
                            child: const SizedBox.shrink(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                body: TableBody(
                  rows: [
                    for (final (index, seat) in _seats.indexed)
                      InkTableRow(
                        selected: index == 1,
                        cells: [
                          InkTableCell(
                            child: Row(
                              spacing: Spacing.d12,
                              children: [
                                Avatar(
                                  children: [
                                    AvatarFallback(name: seat.name),
                                    AvatarBadge(
                                      status: seat.status,
                                      semanticLabel: seat.status.name,
                                    ),
                                  ],
                                ),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        seat.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          height: 1.25,
                                        ),
                                      ),
                                      Text(seat.email, style: muted),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkTableCell(child: Text(seat.role)),
                          InkTableCell(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                '\$${seat.price.toStringAsFixed(2)}',
                                style: figures,
                              ),
                            ),
                          ),
                          InkTableCell(
                            child: Button(
                              variant: ButtonVariant.ghost,
                              size: ButtonSize.iconSm,
                              semanticLabel: 'More for ${seat.name}',
                              onPressed: () {},
                              child: const InkIcon('ellipsis'),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                footer: TableFooter(
                  rows: [
                    InkTableRow(
                      cells: [
                        const InkTableCell(child: Text('Total')),
                        const InkTableCell(child: SizedBox.shrink()),
                        InkTableCell(
                          child: Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: figures,
                            ),
                          ),
                        ),
                        const InkTableCell(child: SizedBox.shrink()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            CardFooter(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Billed on the first of the month.',
                    style: muted,
                  ),
                ),
                Button(
                  variant: ButtonVariant.link,
                  size: ButtonSize.sm,
                  onPressed: () {},
                  child: const Text('View invoices'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
