import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

class PaginationDefaultExample extends StatelessWidget {
  const PaginationDefaultExample({super.key});

  @override
  Widget build(BuildContext context) => Pagination(
    child: PaginationContent(
      children: [
        PaginationPrevious(onPressed: () {}),
        PaginationLink(onPressed: () {}, child: const Text('1')),
        PaginationLink(
          onPressed: () {},
          isActive: true,
          child: const Text('2'),
        ),
        PaginationLink(onPressed: () {}, child: const Text('3')),
        const PaginationEllipsis(),
        PaginationNext(onPressed: () {}),
      ],
    ),
  );
}
