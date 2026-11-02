import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/dashboard_01/dashboard_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A section's header as a link that pulls out a drawer: its visitors
/// over six months (not on phones) and a form to edit the section.
///
/// Mirrors `SectionViewer` in upstream
/// `src/blocks/dashboard-01/components/dashboard-01-data-table.tsx`.
class Dashboard01SectionViewer extends StatefulWidget {
  const Dashboard01SectionViewer({
    super.key,
    required this.item,
    required this.onSave,
  });

  final Dashboard01Section item;
  final ValueChanged<Dashboard01Section> onSave;

  @override
  State<Dashboard01SectionViewer> createState() =>
      _Dashboard01SectionViewerState();
}

class _Dashboard01SectionViewerState extends State<Dashboard01SectionViewer> {
  static const double _mobileBelow = 768;
  static const double _chartHeight = 160;

  var _open = false;
  late Dashboard01Section _draft = widget.item;
  final _header = TextEditingController();
  final _target = TextEditingController();
  final _limit = TextEditingController();

  @override
  void dispose() {
    _header.dispose();
    _target.dispose();
    _limit.dispose();
    super.dispose();
  }

  void _setOpen(bool open) {
    if (open) {
      _draft = widget.item;
      _header.text = _draft.header;
      _target.text = _draft.target;
      _limit.text = _draft.limit;
    }
    setState(() => _open = open);
  }

  void _save() {
    widget.onSave(_draft);
    _setOpen(false);
  }

  Widget _labelled(String label, Widget control) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d8,
    children: [
      Label(child: Text(label)),
      control,
    ],
  );

  Widget _select(
    String label,
    String value,
    String placeholder,
    List<(String, String)> options,
    ValueChanged<String> onChanged,
  ) => _labelled(
    label,
    Select(
      value: value,
      onChanged: onChanged,
      content: SelectContent(
        children: [
          for (final (value, text) in options)
            SelectItem(value: value, child: Text(text)),
        ],
      ),
      child: SelectTrigger(
        semanticLabel: label,
        child: SelectValue(placeholder: placeholder),
      ),
    ),
  );

  Widget _pair(Widget start, Widget end) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d16,
    children: [
      Expanded(child: start),
      Expanded(child: end),
    ],
  );

  Widget _form() {
    final draft = _draft;
    final types = [
      for (final type in dashboard01SectionTypes) (type, type),
      if (!dashboard01SectionTypes.contains(draft.type))
        (draft.type, draft.type),
    ];
    final digits = [FilteringTextInputFormatter.digitsOnly];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: Spacing.d16,
      children: [
        _labelled(
          'Header',
          Input(
            controller: _header,
            onChanged: (value) =>
                setState(() => _draft = _draft.copyWith(header: value)),
            onSubmitted: (_) => _save(),
          ),
        ),
        _pair(
          _select(
            'Type',
            draft.type,
            'Pick a type',
            types,
            (value) => setState(() => _draft = _draft.copyWith(type: value)),
          ),
          _select(
            'Status',
            draft.status.name,
            'Pick a status',
            [
              for (final status in Dashboard01Status.values)
                (status.name, status.label),
            ],
            (value) => setState(
              () => _draft = _draft.copyWith(
                status: Dashboard01Status.values.byName(value),
              ),
            ),
          ),
        ),
        _pair(
          _labelled(
            'Target',
            Input(
              controller: _target,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(target: value)),
            ),
          ),
          _labelled(
            'Limit',
            Input(
              controller: _limit,
              keyboardType: TextInputType.number,
              inputFormatters: digits,
              onChanged: (value) =>
                  setState(() => _draft = _draft.copyWith(limit: value)),
            ),
          ),
        ),
        _select(
          'Reviewer',
          draft.reviewer,
          'Pick a reviewer',
          [
            for (final reviewer in dashboard01Reviewers) (reviewer, reviewer),
            (dashboard01Unassigned, 'Not assigned yet'),
          ],
          (value) => setState(() => _draft = _draft.copyWith(reviewer: value)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final mobile = MediaQuery.sizeOf(context).width < _mobileBelow;
    final item = widget.item;
    return Drawer(
      direction: switch (mobile) {
        true => OverlaySide.bottom,
        false => OverlaySide.right,
      },
      open: _open,
      onOpenChange: _setOpen,
      content: DrawerContent(
        seed: 'section-${item.id}',
        children: [
          DrawerHeader(
            children: [
              DrawerTitle(Text(item.header)),
              const DrawerDescription(
                Text('Visitors to this section over the last six months'),
              ),
            ],
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                Spacing.d16,
                0,
                Spacing.d16,
                Spacing.d12,
              ),
              child: DefaultTextStyle.merge(
                style: theme.typography.interface(cssSize: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [
                    if (!mobile) ...[
                      ChartContainer(
                        config: dashboard01ChartConfig,
                        height: _chartHeight,
                        children: [
                          AreaChart(
                            data: dashboard01Monthly,
                            xKey: 'month',
                            stacked: true,
                            xFormatter: (month, [index = 0]) {
                              final name = '$month';
                              return name.substring(0, name.length.clamp(0, 3));
                            },
                            label: 'Visitors per month, January to June',
                          ),
                          const ChartTooltip(
                            content: ChartTooltipContent(
                              indicator: ChartTooltipIndicator.dot,
                            ),
                          ),
                        ],
                      ),
                      const Separator(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: Spacing.d8,
                        children: [
                          Row(
                            spacing: Spacing.d8,
                            children: [
                              Text(
                                'Up 5.2% this month',
                                style: theme.typography
                                    .interface(cssSize: 14)
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              const InkIcon('trending-up', size: Spacing.d16),
                            ],
                          ),
                          Text(
                            'People are reading this section all the way to the end, which is more than we hoped for.',
                            style: TextStyle(color: theme.colors.inkSoft),
                          ),
                        ],
                      ),
                      const Separator(),
                    ],
                    _form(),
                  ],
                ),
              ),
            ),
          ),
          DrawerFooter(
            children: [
              Button(onPressed: _save, child: const Text('Save changes')),
              DrawerClose(
                builder: (context, close) => Button(
                  variant: ButtonVariant.outline,
                  onPressed: close,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
      child: DrawerTrigger.builder(
        builder: (context, drawer) => Button(
          variant: ButtonVariant.link,
          onPressed: drawer.show,
          child: Text(
            item.header,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: theme.colors.ink),
          ),
        ),
      ),
    );
  }
}
