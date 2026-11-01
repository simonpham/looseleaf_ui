import 'package:flutter/widgets.dart';
import 'package:gallery/features/foundations/models/models.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';

class FoundationsPage extends StatelessWidget {
  const FoundationsPage({super.key, this.topic});

  final FoundationTopic? topic;

  @override
  Widget build(BuildContext context) =>
      DocPage(title: topic?.title ?? 'Foundations', children: const []);
}
