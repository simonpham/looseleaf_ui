import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_billing/settings_billing.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// The current plan as a kraft ticket, the plans as choice cards, what a
/// change would cost, and the button that makes it.
class SettingsBillingPlan extends StatefulWidget {
  const SettingsBillingPlan({
    super.key,
    required this.current,
    required this.onChanged,
    this.scheduled,
  });

  final BillingPlan current;
  final BillingPlan? scheduled;
  final ValueChanged<BillingPlan> onChanged;

  @override
  State<SettingsBillingPlan> createState() => _SettingsBillingPlanState();
}

class _SettingsBillingPlanState extends State<SettingsBillingPlan> {
  static const double _ticketWidth = 448;
  static const double _acrossFrom = 648;

  late BillingPlan _picked = widget.current;
  var _done = '';

  String _over(BillingPlan target) => [
    for (final usage in BillingUsage.values)
      if (usage.used > target.limitOf(usage))
        '${usage.label.toLowerCase()} (${usage.usedText} of ${target.limitOf(usage)}${usage.unit})',
  ].join(', ');

  void _switch(BillingChange change) {
    final target = _picked;
    widget.onChanged(target);
    setState(
      () => _done = switch (change.kind) {
        BillingChangeKind.upgrade => 'You are on ${target.name} now.',
        _ => 'Done. ${target.name} starts on $billingRenews.',
      },
    );
  }

  Widget _card(BillingPlan plan, LooseleafThemeData theme) => FieldLabel(
    checked: _picked == plan,
    onPressed: () => setState(() {
      _picked = plan;
      _done = '';
    }),
    child: Field(
      orientation: FieldOrientation.horizontal,
      children: [
        FieldContent(
          children: [
            FieldTitle(
              Wrap(
                spacing: Spacing.d8,
                runSpacing: Spacing.d4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(plan.name),
                  if (plan == widget.current)
                    const Badge(
                      size: BadgeSize.sm,
                      variant: BadgeVariant.secondary,
                      child: Text('Current'),
                    ),
                ],
              ),
            ),
            FieldDescription(
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: switch (plan.cents) {
                        0 => 'Free',
                        final cents => '${billingMoney(cents)} a month',
                      },
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: theme.colors.ink,
                      ),
                    ),
                    TextSpan(text: '\n${plan.blurb}'),
                  ],
                ),
              ),
            ),
          ],
        ),
        InkRadioGroupItem(value: plan),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final current = widget.current;
    final target = _picked;
    final change = billingPlanChange(current, target);
    final over = _over(target);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d24,
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Ticket(
            maxWidth: _ticketWidth,
            seed: 'plan-ticket',
            semanticLabel: 'Your plan: ${current.name}',
            children: [
              TicketBody(
                children: [
                  TicketTitle(Text('${current.name} plan')),
                  TicketDescription(
                    Text(
                      '${billingMoney(current.cents)} a month · renews $billingRenews',
                    ),
                  ),
                  const TicketNumber(Text('No. 0042')),
                ],
              ),
              TicketStub(
                children: [
                  Text(
                    'Admit',
                    style: theme.typography.face(
                      KevinSansFace.type,
                      cssSize: 12,
                      color: theme.colors.ink,
                    ),
                  ),
                  Text(
                    '1',
                    style: theme.typography.face(
                      KevinSansFace.script,
                      cssSize: 36,
                      cssLineHeight: 1,
                      fontWeight: FontWeight.w700,
                      color: theme.colors.ink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.scheduled case final next?)
          Wrap(
            spacing: Spacing.d12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Moving to '),
                    TextSpan(
                      text: next.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const TextSpan(text: ' on $billingRenews.'),
                  ],
                ),
                style: theme.typography.interface(
                  cssSize: 14,
                  color: theme.colors.ink,
                ),
              ),
              Button(
                variant: ButtonVariant.link,
                size: ButtonSize.sm,
                onPressed: () {
                  widget.onChanged(current);
                  setState(() {
                    _picked = current;
                    _done = 'Staying on ${current.name}.';
                  });
                },
                child: Text('Keep ${current.name}'),
              ),
            ],
          ),
        LayoutBuilder(
          builder: (context, constraints) => InkRadioGroup<BillingPlan>(
            value: _picked,
            semanticLabel: 'Plan',
            onChanged: (plan) => setState(() {
              _picked = plan;
              _done = '';
            }),
            children: switch (constraints.maxWidth >= _acrossFrom) {
              true => [
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d12,
                    children: [
                      for (final plan in BillingPlan.values)
                        Expanded(child: _card(plan, theme)),
                    ],
                  ),
                ),
              ],
              false => [
                for (final plan in BillingPlan.values)
                  SizedBox(width: double.infinity, child: _card(plan, theme)),
              ],
            },
          ),
        ),
        if (change.kind == BillingChangeKind.upgrade)
          Alert(
            variant: AlertTone.info,
            icon: const InkIcon('info'),
            children: [
              AlertTitle(Text('Move up to ${target.name}')),
              AlertDescription(
                Text(
                  'From $billingRenews you will pay ${billingMoney(change.monthly)} a month. Today we charge ${billingMoney(change.today)} for the $billingDaysLeft days left in this month, and nothing more.',
                ),
              ),
            ],
          ),
        if (change.kind == BillingChangeKind.downgrade)
          Alert(
            variant: AlertTone.warning,
            icon: const InkIcon('triangle-alert'),
            children: [
              AlertTitle(Text('Move down to ${target.name}')),
              AlertDescription(
                Text(
                  'You keep ${current.name} until $billingRenews, then pay ${switch (change.monthly) {
                    0 => 'nothing',
                    final monthly => '${billingMoney(monthly)} a month',
                  }}. Nothing is charged today.${switch (over) {
                    '' => '',
                    _ => ' You use more than ${target.name} holds: $over. The extra stays readable but cannot be edited.',
                  }}',
                ),
              ),
            ],
          ),
        Wrap(
          spacing: Spacing.d12,
          runSpacing: Spacing.d12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Button(
              disabled: change.kind == BillingChangeKind.same,
              onPressed: () => _switch(change),
              child: Text(switch (change.kind) {
                BillingChangeKind.same => 'Pick another plan',
                _ => 'Switch to ${target.name}',
              }),
            ),
            Semantics(
              liveRegion: true,
              child: Text(
                _done,
                style: theme.typography
                    .interface(
                      cssSize: 14,
                      color: theme.colors.green,
                    )
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
