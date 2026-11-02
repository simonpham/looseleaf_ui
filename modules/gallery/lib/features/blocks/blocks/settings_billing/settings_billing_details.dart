import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// What every invoice is addressed to: email, company and VAT number,
/// checked and saved through [onSave].
class SettingsBillingDetails extends StatefulWidget {
  const SettingsBillingDetails({super.key, this.onSave});

  /// Saves the details; a throw shows its message under the button.
  final FutureOr<void> Function(Map<String, Object?> values)? onSave;

  @override
  State<SettingsBillingDetails> createState() => _SettingsBillingDetailsState();
}

class _SettingsBillingDetailsState extends State<SettingsBillingDetails> {
  static const double _pairFrom = 424;
  static const _initial = {
    'email': 'billing@looseleaf.example',
    'company': 'Delacroix Letterpress',
    'taxId': 'PT123456789',
  };
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _taxId = RegExp(r'^([A-Za-z]{2}[A-Za-z0-9]{8,12})?$');

  final _form = FormController(initialValues: _initial);
  late final _emailText = TextEditingController(text: _initial['email']);
  late final _companyText = TextEditingController(text: _initial['company']);
  late final _taxIdText = TextEditingController(text: _initial['taxId']);
  var _saved = false;
  var _failure = '';

  @override
  void dispose() {
    _form.dispose();
    _emailText.dispose();
    _companyText.dispose();
    _taxIdText.dispose();
    super.dispose();
  }

  void _edited(FormFieldData<String> field, String value) {
    setState(() {
      _saved = false;
      _failure = '';
    });
    field.onChanged(value);
  }

  void _submit() => unawaited(
    _form.handleSubmit((values) async {
      try {
        await widget.onSave?.call(values);
      } on Object catch (error) {
        setState(
          () => _failure = switch ('$error') {
            '' =>
              'The details were not saved. Nothing was lost, so try again in a moment.',
            final message => message,
          },
        );
        return;
      }
      _form.reset(values);
      setState(() {
        _failure = '';
        _saved = true;
      });
    }),
  );

  Widget _text({
    required String name,
    required String label,
    required TextEditingController controller,
    required FormValidator validator,
    String? placeholder,
    String? description,
    List<TextInputFormatter>? formatters,
    List<String>? autofill,
  }) => InkFormField<String>(
    name: name,
    validator: validator,
    builder: (context, field) => FormItem(
      children: [
        FormLabel(Text(label)),
        FormControl(
          child: Input(
            controller: controller,
            invalid: field.invalid,
            placeholder: placeholder,
            inputFormatters: formatters,
            autofillHints: autofill,
            onChanged: (value) => _edited(field, value),
            onSubmitted: (_) => _submit(),
          ),
        ),
        if (description case final help?) FormDescription(Text(help)),
        const FormMessage(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final status = theme.typography
        .interface(cssSize: 14, color: theme.colors.green)
        .copyWith(fontWeight: FontWeight.w700);
    final company = _text(
      name: 'company',
      label: 'Company',
      controller: _companyText,
      placeholder: 'Optional',
      autofill: const [AutofillHints.organizationName],
      validator: (value) => switch ('${value ?? ''}'.trim().length > 60) {
        true => 'Keep the company name to 60 characters.',
        false => null,
      },
    );
    final taxId = _text(
      name: 'taxId',
      label: 'VAT number',
      controller: _taxIdText,
      placeholder: 'Optional',
      description: 'Two letters and the number, no spaces.',
      formatters: [
        TextInputFormatter.withFunction(
          (old, value) => value.copyWith(text: value.text.toUpperCase()),
        ),
      ],
      validator: (value) => switch (_taxId.hasMatch('${value ?? ''}'.trim())) {
        true => null,
        false => 'A VAT number starts with two letters, like PT123456789.',
      },
    );
    return InkForm(
      controller: _form,
      child: Semantics(
        container: true,
        label: 'Invoice details',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d20,
          children: [
            _text(
              name: 'email',
              label: 'Send invoices to',
              controller: _emailText,
              autofill: const [AutofillHints.email],
              validator: (value) => switch (_email.hasMatch(
                '${value ?? ''}',
              )) {
                true => null,
                false => 'Enter an address like billing@notes.dev.',
              },
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < _pairFrom) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: Spacing.d20,
                    children: [company, taxId],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d20,
                  children: [
                    Expanded(child: company),
                    Expanded(child: taxId),
                  ],
                );
              },
            ),
            Field(
              orientation: FieldOrientation.horizontal,
              children: [
                Button(onPressed: _submit, child: const Text('Save details')),
                FieldContent(
                  children: [
                    Semantics(
                      liveRegion: true,
                      child: Text(switch (_saved) {
                        true => 'Saved. New invoices will say so.',
                        false => '',
                      }, style: status),
                    ),
                    if (_failure.isNotEmpty)
                      Text(
                        _failure,
                        style: status.copyWith(color: theme.colors.red),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
