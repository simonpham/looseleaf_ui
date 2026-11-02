import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

const _rows = [
  (name: 'ليلى', status: 'مدفوع', amount: '250.00'),
  (name: 'يوسف', status: 'قيد الانتظار', amount: '150.00'),
  (name: 'مريم', status: 'متأخر', amount: '350.00'),
];

class DirectionArabicNotebookExample extends StatefulWidget {
  const DirectionArabicNotebookExample({super.key});

  @override
  State<DirectionArabicNotebookExample> createState() =>
      _DirectionArabicNotebookExampleState();
}

class _DirectionArabicNotebookExampleState
    extends State<DirectionArabicNotebookExample> {
  static const _maxWidth = 576.0;

  var _size = [40.0];

  @override
  Widget build(BuildContext context) => DirectionProvider(
    direction: TextDirection.rtl,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _maxWidth),
      child: Card(
        seed: 'direction-arabic',
        children: [
          const CardHeader(
            children: [
              CardTitle(Text('دفتر الحسابات')),
              CardDescription(
                Text(
                  'افتح القائمة، حرّك المنزلق، وتنقّل بين الألسنة بمفاتيح الأسهم.',
                ),
              ),
            ],
          ),
          CardContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d24,
              children: [
                Row(
                  spacing: Spacing.d16,
                  children: [
                    DropdownMenu(
                      content: DropdownMenuContent(
                        width: Spacing.d224,
                        align: OverlayAlign.start,
                        seed: 'direction-arabic-menu',
                        children: [
                          const DropdownMenuLabel(
                            child: Text('الصفحة الحالية'),
                          ),
                          DropdownMenuItem(
                            leading: const InkIcon('pencil'),
                            trailing: const DropdownMenuShortcut('⌘E'),
                            onSelect: () {},
                            child: const Text('تعديل'),
                          ),
                          DropdownMenuItem(
                            leading: const InkIcon('copy'),
                            trailing: const DropdownMenuShortcut('⌘C'),
                            onSelect: () {},
                            child: const Text('نسخ'),
                          ),
                          DropdownMenuSub(
                            trigger: const DropdownMenuSubTrigger(
                              leading: InkIcon('folder'),
                              child: Text('نقل إلى'),
                            ),
                            content: DropdownMenuSubContent(
                              children: [
                                DropdownMenuItem(
                                  onSelect: () {},
                                  child: const Text('المسودات'),
                                ),
                                DropdownMenuItem(
                                  onSelect: () {},
                                  child: const Text('الأرشيف'),
                                ),
                              ],
                            ),
                          ),
                          const DropdownMenuSeparator(),
                          DropdownMenuItem(
                            variant: InkMenuItemVariant.destructive,
                            leading: const InkIcon('trash'),
                            onSelect: () {},
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                      child: DropdownMenuTrigger.builder(
                        builder: (context, menu) => Button(
                          variant: ButtonVariant.outline,
                          onPressed: menu.toggle,
                          trailing: const InkIcon('chevron-down'),
                          child: const Text('الخيارات'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        values: _size,
                        tickCount: 5,
                        semanticLabel: 'حجم الخط',
                        valueText: (value, _) => '${value.round()}%',
                        onChanged: (values) => setState(() => _size = values),
                      ),
                    ),
                  ],
                ),
                Tabs(
                  defaultValue: 'paid',
                  children: [
                    const TabsList(
                      children: [
                        TabsTrigger(value: 'paid', child: Text('المدفوعات')),
                        TabsTrigger(value: 'pending', child: Text('المعلّقة')),
                        TabsTrigger(value: 'all', child: Text('الكل')),
                      ],
                    ),
                    TabsContent(
                      value: 'paid',
                      child: InkTable(
                        header: const TableHeader(
                          rows: [
                            InkTableRow(
                              cells: [
                                TableHead(child: Text('الاسم')),
                                TableHead(child: Text('الحالة')),
                                TableHead(
                                  child: Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: Text('المبلغ'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        body: TableBody(
                          rows: [
                            for (final row in _rows)
                              InkTableRow(
                                cells: [
                                  InkTableCell(
                                    child: Text(
                                      row.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  InkTableCell(child: Text(row.status)),
                                  InkTableCell(
                                    child: Align(
                                      alignment: AlignmentDirectional.centerEnd,
                                      child: Text(
                                        row.amount,
                                        style: const TextStyle(
                                          fontFeatures: [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                    const TabsContent(
                      value: 'pending',
                      child: Text('لا توجد مدفوعات معلّقة الآن.'),
                    ),
                    const TabsContent(
                      value: 'all',
                      child: Text('كل الحسابات في دفتر واحد.'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
