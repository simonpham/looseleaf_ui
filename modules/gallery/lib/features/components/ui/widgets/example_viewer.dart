import 'package:flutter/widgets.dart';
import 'package:gallery/features/components/models/models.dart';
import 'package:gallery/features/components/ui/widgets/example_source.dart';
import 'package:gallery/features/components/ui/widgets/preview_stage.dart';
import 'package:gallery/features/kit/ui/widgets/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// One example: its title and description over Preview and Code tabs.
///
/// Mirrors `ExampleViewer` in upstream `src/docs/widgets/ExampleViewer.tsx`.
class ExampleViewer extends StatelessWidget {
  const ExampleViewer({super.key, required this.example, this.level = 3});

  final GalleryExample example;
  final int level;

  @override
  Widget build(BuildContext context) => DocSection(
    title: example.title,
    level: level,
    description: example.description,
    children: [
      Tabs(
        defaultValue: 'preview',
        children: [
          const TabsList(
            variant: TabsVariant.line,
            children: [
              TabsTrigger(value: 'preview', child: Text('Preview')),
              TabsTrigger(value: 'code', child: Text('Code')),
            ],
          ),
          TabsContent(
            value: 'preview',
            child: PreviewStage(
              layout: example.layout,
              stage: example.stage,
              height: example.height,
              seed: 'stage:${example.source}',
              child: example.builder(),
            ),
          ),
          TabsContent(
            value: 'code',
            child: ExampleSource(source: example.source),
          ),
        ],
      ),
    ],
  );
}
