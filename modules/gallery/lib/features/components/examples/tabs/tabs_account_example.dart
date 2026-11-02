import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class TabsAccountExample extends StatefulWidget {
  const TabsAccountExample({super.key});

  @override
  State<TabsAccountExample> createState() => _TabsAccountExampleState();
}

class _TabsAccountExampleState extends State<TabsAccountExample> {
  static const _maxWidth = Spacing.d384;

  final _name = TextEditingController(text: 'Ada Lovelace');
  final _username = TextEditingController(text: '@ada');

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: _maxWidth),
    child: Tabs(
      defaultValue: 'account',
      children: [
        const TabsList(
          children: [
            TabsTrigger(value: 'account', child: Text('Account')),
            TabsTrigger(value: 'password', child: Text('Password')),
          ],
        ),
        TabsContent(
          value: 'account',
          child: Card(
            seed: 'tabs-account',
            children: [
              const CardHeader(
                children: [
                  CardTitle(Text('Account')),
                  CardDescription(
                    Text(
                      'Make changes to your account here. Click save when you are done.',
                    ),
                  ),
                ],
              ),
              CardContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [
                    _Field(
                      label: 'Name',
                      input: Input(controller: _name),
                    ),
                    _Field(
                      label: 'Username',
                      input: Input(controller: _username),
                    ),
                  ],
                ),
              ),
              CardFooter(
                children: [
                  Button(onPressed: () {}, child: const Text('Save changes')),
                ],
              ),
            ],
          ),
        ),
        TabsContent(
          value: 'password',
          child: Card(
            seed: 'tabs-password',
            children: [
              const CardHeader(
                children: [
                  CardTitle(Text('Password')),
                  CardDescription(
                    Text(
                      'Change your password here. After saving, you will be logged out.',
                    ),
                  ),
                ],
              ),
              const CardContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: Spacing.d16,
                  children: [
                    _Field(
                      label: 'Current password',
                      input: Input(obscureText: true),
                    ),
                    _Field(
                      label: 'New password',
                      input: Input(obscureText: true),
                    ),
                  ],
                ),
              ),
              CardFooter(
                children: [
                  Button(onPressed: () {}, child: const Text('Save password')),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.input});

  final String label;
  final Widget input;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    spacing: Spacing.d8,
    children: [
      Label(child: Text(label)),
      input,
    ],
  );
}
