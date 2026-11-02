import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/settings_profile/settings_profile.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// Profile settings on a hole-punched page: photo, name, username, email,
/// bio, pronouns, time zone, website and search visibility, checked as you
/// go, with the index card others see updating beside the form.
///
/// Mirrors upstream `src/blocks/settings-profile/page.tsx`.
class SettingsProfileBlock extends StatefulWidget {
  const SettingsProfileBlock({
    super.key,
    this.initialValues = profileDefaults,
    this.onSave,
    this.onPickPhoto,
  });

  final Map<String, Object?> initialValues;

  /// Saves the values; a throw shows its message. A short pause when null.
  final FutureOr<void> Function(Map<String, Object?> values)? onSave;

  /// Asks for a photo; see [SettingsProfilePhoto.onPick].
  final Future<ImageProvider?> Function()? onPickPhoto;

  @override
  State<SettingsProfileBlock> createState() => _SettingsProfileBlockState();
}

class _SettingsProfileBlockState extends State<SettingsProfileBlock> {
  static const double _asideFrom = 768;
  static const double _asideWidth = 272;
  static const double _pairFrom = 512;
  static const Duration _demoSave = Duration(milliseconds: 450);

  late final _form = FormController(initialValues: widget.initialValues);
  late Map<String, Object?> _baseline = widget.initialValues;
  late final _texts = {
    for (final name in ['name', 'username', 'email', 'bio', 'website'])
      name: TextEditingController(text: '${_baseline[name] ?? ''}'),
  };
  ImageProvider? _photo;
  var _saved = false;
  var _failure = '';

  @override
  void initState() {
    super.initState();
    _form.addListener(_changed);
  }

  @override
  void dispose() {
    _form
      ..removeListener(_changed)
      ..dispose();
    for (final text in _texts.values) {
      text.dispose();
    }
    super.dispose();
  }

  void _changed() => setState(() {});

  bool get _dirty => _baseline.entries.any(
    (entry) => _form.values[entry.key] != entry.value,
  );

  void _edit(String name, Object? value) {
    setState(() {
      _saved = false;
      _failure = '';
    });
    _form.setValue(name, value);
  }

  void _undo() {
    _form.reset(_baseline);
    for (final MapEntry(:key, :value) in _texts.entries) {
      value.text = '${_baseline[key] ?? ''}';
    }
  }

  void _submit() => unawaited(
    _form.handleSubmit((values) async {
      try {
        final save = widget.onSave;
        if (save == null) {
          await Future<void>.delayed(_demoSave);
        }
        await save?.call(values);
      } on Object catch (error) {
        if (!mounted) return;
        setState(
          () => _failure = switch ('$error') {
            '' =>
              'Your changes were not saved. Nothing was lost, so try again in a moment.',
            final message => message,
          },
        );
        return;
      }
      if (!mounted) return;
      _baseline = Map.of(values);
      _form.reset(_baseline);
      setState(() {
        _failure = '';
        _saved = true;
      });
    }),
  );

  Widget _input(
    String name,
    String label, {
    required FormValidator validator,
    String? placeholder,
    String? description,
    List<String>? autofill,
    TextInputType? keyboard,
  }) => InkFormField<String>(
    name: name,
    validator: validator,
    builder: (context, field) => FormItem(
      children: [
        FormLabel(Text(label)),
        FormControl(
          child: Input(
            controller: _texts[name],
            invalid: field.invalid,
            placeholder: placeholder,
            autofillHints: autofill,
            keyboardType: keyboard,
            onChanged: (value) => _edit(name, value),
            onSubmitted: (_) => _submit(),
          ),
        ),
        if (description case final help?) FormDescription(Text(help)),
        const FormMessage(),
      ],
    ),
  );

  Widget _select(
    String name,
    String label,
    String placeholder,
    List<ProfileChoice> choices, {
    FormValidator? validator,
  }) => InkFormField<String>(
    name: name,
    validator: validator,
    builder: (context, field) => FormItem(
      children: [
        FormLabel(Text(label)),
        Select(
          value: field.value,
          onChanged: (value) => _edit(name, value),
          content: SelectContent(
            position: SelectPosition.popper,
            children: [
              for (final choice in choices)
                SelectItem(value: choice.value, child: Text(choice.label)),
            ],
          ),
          child: FormControl(
            child: SelectTrigger(
              invalid: field.invalid,
              child: SelectValue(placeholder: placeholder),
            ),
          ),
        ),
        const FormMessage(),
      ],
    ),
  );

  Widget _pair(Widget start, Widget end) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < _pairFrom) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d24,
          children: [start, end],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d24,
        children: [
          Expanded(child: start),
          Expanded(child: end),
        ],
      );
    },
  );

  Widget _fields(BuildContext context, LooseleafThemeData theme) {
    final status = theme.typography
        .interface(cssSize: 14, color: theme.colors.green)
        .copyWith(fontWeight: FontWeight.w700);
    return InkForm(
      controller: _form,
      child: Semantics(
        container: true,
        label: 'Profile settings',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d24,
          children: [
            SettingsProfilePhoto(
              name: '${_form.values['name'] ?? ''}',
              photo: _photo,
              onPick: widget.onPickPhoto,
              onPhoto: (photo) => setState(() => _photo = photo),
            ),
            const Separator(variant: SeparatorVariant.dashed),
            _pair(
              _input(
                'name',
                'Name',
                validator: profileValidateName,
                placeholder: 'Ada Lovelace',
                autofill: const [AutofillHints.name],
              ),
              InkFormField<String>(
                name: 'username',
                validator: profileValidateUsername,
                builder: (context, field) => FormItem(
                  children: [
                    const FormLabel(Text('Username')),
                    FormControl(
                      child: InputGroup(
                        invalid: field.invalid,
                        children: [
                          const InputGroupAddon(
                            child: InputGroupText(child: Text('@')),
                          ),
                          InputGroupInput(
                            controller: _texts['username'],
                            placeholder: 'ada_writes',
                            onChanged: (value) => _edit('username', value),
                            onSubmitted: (_) => _submit(),
                          ),
                        ],
                      ),
                    ),
                    const FormMessage(),
                  ],
                ),
              ),
            ),
            _input(
              'email',
              'Email',
              validator: profileValidateEmail,
              placeholder: 'ada@notes.dev',
              description:
                  'Receipts and sign-in links go here. It is never shown on your card.',
              autofill: const [AutofillHints.email],
              keyboard: TextInputType.emailAddress,
            ),
            InkFormField<String>(
              name: 'bio',
              validator: profileValidateBio,
              builder: (context, field) => FormItem(
                children: [
                  const FormLabel(Text('Bio')),
                  FormControl(
                    child: Textarea(
                      controller: _texts['bio'],
                      rows: 3,
                      invalid: field.invalid,
                      placeholder: 'A line or two, in your own words.',
                      onChanged: (value) => _edit('bio', value),
                      countBuilder: (context, length, _) => Text(
                        '$length/$profileBioMax',
                        style: switch (length > profileBioMax) {
                          true => TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colors.red,
                          ),
                          false => null,
                        },
                      ),
                    ),
                  ),
                  const FormMessage(),
                ],
              ),
            ),
            _pair(
              _select(
                'pronouns',
                'Pronouns',
                'Rather not say',
                profilePronouns,
              ),
              _select(
                'timezone',
                'Time zone',
                'Pick a time zone',
                profileTimeZones,
                validator: profileValidateTimezone,
              ),
            ),
            _input(
              'website',
              'Website',
              validator: profileValidateWebsite,
              placeholder: 'https://',
              autofill: const [AutofillHints.url],
              keyboard: TextInputType.url,
            ),
            const Separator(variant: SeparatorVariant.dashed),
            InkFormField<bool>(
              name: 'discoverable',
              builder: (context, field) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d24,
                children: [
                  const Expanded(
                    child: FormItem(
                      children: [
                        FormLabel(Text('Show me in search')),
                        FormDescription(
                          Text(
                            'Anyone can find your card by name. Turn it off and only people with the link can.',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.d2),
                    child: Switch(
                      value: field.value ?? false,
                      semanticLabel: 'Show me in search',
                      onChanged: (value) => _edit('discoverable', value),
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: Spacing.d12,
              runSpacing: Spacing.d12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Button(
                  onPressed: _submit,
                  child: Text(switch (_form.isSubmitting) {
                    true => 'Saving…',
                    false => 'Save changes',
                  }),
                ),
                if (_dirty)
                  Button(
                    variant: ButtonVariant.ghost,
                    onPressed: _undo,
                    child: const Text('Undo changes'),
                  ),
                if (_saved)
                  _StatusLine(
                    icon: 'circle-check',
                    color: theme.colors.green,
                    style: status,
                    text: 'Saved. Your card is up to date.',
                  ),
              ],
            ),
            if (_failure.isNotEmpty)
              _StatusLine(
                icon: 'circle-alert',
                color: theme.colors.red,
                style: status.copyWith(color: theme.colors.red),
                text: _failure,
              ),
          ],
        ),
      ),
    );
  }

  Widget _aside(LooseleafThemeData theme) => Semantics(
    container: true,
    label: 'Preview',
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d12,
          children: [
            Text(
              'How others see you',
              style: theme.typography.face(
                KevinSansFace.script,
                cssSize: 24,
                cssLineHeight: 1,
                fontWeight: FontWeight.w600,
                color: theme.colors.ink,
              ),
            ),
            SettingsProfileCard(values: _form.values, photo: _photo),
          ],
        ),
        if (_saved)
          const PositionedDirectional(
            end: -Spacing.d8,
            bottom: -Spacing.d32,
            child: IgnorePointer(
              child: Sticker('done', size: 64, rotate: 8),
            ),
          ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.d20,
        vertical: Spacing.d40,
      ),
      child: PaperPage(
        width: PageWidth.xl,
        holes: PageHoles.start,
        reinforced: true,
        seed: 'settings-profile',
        children: [
          const PageHeader(
            children: [
              PageTitle(Text('Profile'), seed: 'profile-title'),
              PageDescription(
                Text(
                  'This is how you sign the pages you share. Nothing changes for anyone until you save.',
                ),
              ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < _asideFrom) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d40,
                  children: [_fields(context, theme), _aside(theme)],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: Spacing.d40,
                children: [
                  Expanded(child: _fields(context, theme)),
                  SizedBox(width: _asideWidth, child: _aside(theme)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.color,
    required this.style,
    required this.text,
  });

  final String icon;
  final Color color;
  final TextStyle style;
  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: IconTheme(
      data: IconThemeData(color: color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: Spacing.d8,
        children: [
          InkIcon(icon),
          Flexible(child: Text(text, style: style)),
        ],
      ),
    ),
  );
}
