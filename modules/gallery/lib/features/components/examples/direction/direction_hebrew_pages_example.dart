import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _slides = ['הדף הראשון', 'רשימת קניות', 'מכתב לסבתא', 'רעיונות לקיץ'];

class DirectionHebrewPagesExample extends StatelessWidget {
  const DirectionHebrewPagesExample({super.key});

  static const _maxWidth = Spacing.d384;
  static const _slideHeight = 128.0;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DirectionProvider(
      direction: TextDirection.rtl,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d32,
          children: [
            Breadcrumb(
              child: BreadcrumbList(
                children: [
                  BreadcrumbItem(
                    children: [
                      BreadcrumbLink(
                        onPressed: () {},
                        child: const Text('בית'),
                      ),
                    ],
                  ),
                  const BreadcrumbSeparator(child: InkIcon('chevron-right')),
                  BreadcrumbItem(
                    children: [
                      BreadcrumbLink(
                        onPressed: () {},
                        child: const Text('מחברות'),
                      ),
                    ],
                  ),
                  const BreadcrumbSeparator(child: InkIcon('chevron-right')),
                  const BreadcrumbItem(
                    children: [
                      BreadcrumbPage(
                        seed: 'direction-hebrew',
                        child: Text('מחברת הקיץ'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Carousel(
              semanticLabel: 'דפי המחברת',
              seed: 'direction-hebrew-carousel',
              children: [
                CarouselContent(
                  extent: _slideHeight,
                  children: [
                    for (final (index, title) in _slides.indexed)
                      CarouselItem(
                        semanticLabel: '${index + 1} מתוך ${_slides.length}',
                        child: Card(
                          seed: 'direction-hebrew-$index',
                          padding: EdgeInsets.zero,
                          children: [
                            SizedBox(
                              height: _slideHeight,
                              child: Center(
                                child: Text(
                                  title,
                                  style: theme.typography.face(
                                    KevinSansFace.script,
                                    cssSize: 30,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const CarouselPrevious(),
                const CarouselNext(),
              ],
            ),
            Pagination(
              label: 'עימוד',
              child: PaginationContent(
                children: [
                  PaginationLink(
                    size: ButtonSize.regular,
                    semanticLabel: 'לעמוד הקודם',
                    leading: const InkIcon('chevron-left'),
                    onPressed: () {},
                    child: const Text('הקודם'),
                  ),
                  PaginationLink(onPressed: () {}, child: const Text('1')),
                  PaginationLink(
                    isActive: true,
                    onPressed: () {},
                    child: const Text('2'),
                  ),
                  PaginationLink(onPressed: () {}, child: const Text('3')),
                  PaginationLink(
                    size: ButtonSize.regular,
                    semanticLabel: 'לעמוד הבא',
                    trailing: const InkIcon('chevron-right'),
                    onPressed: () {},
                    child: const Text('הבא'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
