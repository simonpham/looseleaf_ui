import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class NativeSelectGroupsExample extends StatefulWidget {
  const NativeSelectGroupsExample({super.key});

  @override
  State<NativeSelectGroupsExample> createState() =>
      _NativeSelectGroupsExampleState();
}

class _NativeSelectGroupsExampleState extends State<NativeSelectGroupsExample> {
  String? _value;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: Spacing.d160 * 2),
    child: NativeSelect<String>(
      value: _value,
      onChanged: (value) => setState(() => _value = value),
      placeholder: 'Select department',
      semanticLabel: 'Department',
      options: const [
        NativeSelectOptGroup(
          label: 'Engineering',
          options: [
            NativeSelectOption(value: 'frontend', label: 'Frontend'),
            NativeSelectOption(value: 'backend', label: 'Backend'),
            NativeSelectOption(value: 'devops', label: 'DevOps'),
          ],
        ),
        NativeSelectOptGroup(
          label: 'Sales',
          options: [
            NativeSelectOption(value: 'sales-rep', label: 'Sales Rep'),
            NativeSelectOption(
              value: 'account-manager',
              label: 'Account Manager',
            ),
            NativeSelectOption(
              value: 'sales-director',
              label: 'Sales Director',
            ),
          ],
        ),
        NativeSelectOptGroup(
          label: 'Operations',
          options: [
            NativeSelectOption(value: 'support', label: 'Customer Support'),
            NativeSelectOption(
              value: 'product-manager',
              label: 'Product Manager',
            ),
            NativeSelectOption(
              value: 'ops-manager',
              label: 'Operations Manager',
            ),
          ],
        ),
      ],
    ),
  );
}
