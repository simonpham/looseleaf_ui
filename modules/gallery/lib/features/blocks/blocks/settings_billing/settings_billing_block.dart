import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_billing/settings_billing.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Billing settings on a taped, coffee-ringed page: the plan as a ticket
/// with choice cards to change it, usage bars, the card on file with a
/// replace dialog, the invoice details form and the invoices as receipts.
///
/// Mirrors upstream `src/blocks/settings-billing/page.tsx`.
class SettingsBillingBlock extends StatefulWidget {
  const SettingsBillingBlock({
    super.key,
    this.defaultPlan = BillingPlan.studio,
    this.today,
    this.onSaveDetails,
    this.onDownload,
  });

  final BillingPlan defaultPlan;

  /// The month a new card must not have expired before; this month when
  /// null.
  final DateTime? today;
  final FutureOr<void> Function(Map<String, Object?> values)? onSaveDetails;
  final ValueChanged<Invoice>? onDownload;

  @override
  State<SettingsBillingBlock> createState() => _SettingsBillingBlockState();
}

class _SettingsBillingBlockState extends State<SettingsBillingBlock> {
  static const double _cardInlineFrom = 360;

  late BillingPlan _plan = widget.defaultPlan;
  BillingPlan? _scheduled;
  SavedCard _card = (brand: 'Visa', last4: '4242', expiry: '08/28');
  var _cardSaved = false;

  void _changePlan(BillingPlan next) {
    final kind = planChange(_plan, next).kind;
    setState(() {
      if (kind == PlanChangeKind.upgrade) _plan = next;
      _scheduled = switch (kind) {
        PlanChangeKind.downgrade => next,
        _ => null,
      };
    });
  }

  Widget _usage(BillingUsage usage, LooseleafThemeData theme) {
    final limit = _plan.limitOf(usage);
    final share = (usage.used / limit * 100).round().clamp(0, 100);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d8,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          spacing: Spacing.d16,
          children: [
            Expanded(
              child: Text(
                usage.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              '${usage.usedText} of $limit${usage.unit}${switch (usage.used > limit) {
                true => ' (over)',
                false => '',
              }}',
              style: theme.typography.interface(
                cssSize: 14,
                color: theme.colors.inkSoft,
              ),
            ),
          ],
        ),
        Progress(
          value: share.toDouble(),
          tone: switch (share >= 90) {
            true => ProgressTone.marker,
            false => ProgressTone.green,
          },
          semanticLabel: '${usage.label}: $share% used',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final card = _card;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d20,
        vertical: Spacing.d40,
      ),
      child: PaperPage(
        width: PageWidth.xl,
        tape: PaperTape.top,
        stain: true,
        seed: 'settings-billing',
        children: [
          const PageHeader(
            children: [
              PageTitle(
                Text('Billing'),
                underline: TitleMark.double,
                seed: 'billing-title',
              ),
              PageDescription(
                Text(
                  'What you pay, what you use, and every receipt we have ever handed you.',
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.d32,
            children: [
              SettingsBillingSection(
                title: 'Your plan',
                description: 'Change it whenever you like. We only charge the difference.',
                children: [
                  SettingsBillingPlan(
                    current: _plan,
                    scheduled: _scheduled,
                    onChanged: _changePlan,
                  ),
                ],
              ),
              const Separator(variant: SeparatorVariant.dashed),
              SettingsBillingSection(
                title: 'Usage',
                description: 'Counted on your current plan. Bars turn to marker when you get close.',
                children: [
                  Semantics(
                    container: true,
                    label: 'Usage',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: Spacing.d20,
                      children: [
                        for (final usage in BillingUsage.values)
                          _usage(usage, theme),
                      ],
                    ),
                  ),
                ],
              ),
              const Separator(variant: SeparatorVariant.dashed),
              SettingsBillingSection(
                title: 'Payment method',
                description: 'One card, charged on the 14th.',
                children: [
                  Semantics(
                    container: true,
                    label: 'Card on file',
                    child: Paper(
                      stock: StockName.slip,
                      tiltDegrees: -0.4,
                      seed: 'card-on-file',
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.d16,
                        vertical: Spacing.d12,
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final details = Row(
                            spacing: Spacing.d16,
                            children: [
                              const InkIcon('credit-card', size: Spacing.d28),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${card.brand} ending in ${card.last4}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Expires ${card.expiry}',
                                      style: theme.typography.interface(
                                        cssSize: 14,
                                        color: theme.colors.inkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                          final replace = SettingsBillingCardDialog(
                            today: widget.today,
                            onSaved: (saved) => setState(() {
                              _card = saved;
                              _cardSaved = true;
                            }),
                          );
                          if (constraints.maxWidth < _cardInlineFrom) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: Spacing.d12,
                              children: [details, replace],
                            );
                          }
                          return Row(
                            spacing: Spacing.d16,
                            children: [
                              Expanded(child: details),
                              replace,
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  if (_cardSaved)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        'Done. New charges go to the ${card.brand} ending in ${card.last4}.',
                        style: theme.typography
                            .interface(cssSize: 14, color: theme.colors.green)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const Separator(variant: SeparatorVariant.dashed),
              SettingsBillingSection(
                title: 'Invoice details',
                description: 'Printed on every receipt. Change it and old receipts keep what they said.',
                children: [
                  SettingsBillingDetails(onSave: widget.onSaveDetails),
                ],
              ),
              const Separator(variant: SeparatorVariant.dashed),
              SettingsBillingSection(
                title: 'Invoices',
                description: 'Newest first. Each is a PDF you can keep.',
                children: [
                  SettingsBillingInvoices(
                    invoices: billingInvoices,
                    onDownload: widget.onDownload,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
