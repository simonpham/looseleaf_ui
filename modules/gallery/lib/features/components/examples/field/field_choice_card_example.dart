import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class FieldChoiceCardExample extends StatefulWidget {
  const FieldChoiceCardExample({super.key});

  @override
  State<FieldChoiceCardExample> createState() => _FieldChoiceCardExampleState();
}

class _FieldChoiceCardExampleState extends State<FieldChoiceCardExample> {
  static const _maxWidth = Spacing.d448;
  static const _environments = [
    (
      'kubernetes',
      'Kubernetes',
      'Run GPU workloads on a K8s configured cluster.',
    ),
    (
      'vm',
      'Virtual Machine',
      'Access a VM configured cluster to run GPU workloads.',
    ),
  ];

  var _environment = 'kubernetes';

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: FieldGroup(
      children: [
        FieldSet(
          children: [
            const FieldLegend(
              Text('Compute Environment'),
              variant: FieldLegendVariant.label,
            ),
            const FieldDescription(
              Text('Select the compute environment for your cluster.'),
            ),
            InkRadioGroup<String>(
              value: _environment,
              onChanged: (value) => setState(() => _environment = value),
              semanticLabel: 'Compute Environment',
              children: [
                for (final (value, title, help) in _environments)
                  FieldLabel(
                    checked: _environment == value,
                    onPressed: () => setState(() => _environment = value),
                    child: Field(
                      orientation: FieldOrientation.horizontal,
                      children: [
                        FieldContent(
                          children: [
                            FieldTitle(Text(title)),
                            FieldDescription(Text(help)),
                          ],
                        ),
                        InkRadioGroupItem(value: value),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
