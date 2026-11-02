/// Whether the bank has agreed to a transaction yet.
enum FinanceStatus { cleared, pending, flagged }

/// One line in the ledger; [cents] is negative for money out.
typedef FinanceTransaction = ({
  int id,
  String date,
  String description,
  String account,
  String category,
  int cents,
  FinanceStatus status,
});

const List<String> financeCategories = [
  'Groceries',
  'Rent',
  'Eating out',
  'Transport',
  'Fun',
  'Bills',
  'Income',
];

const Map<String, String> financeCategoryIcon = {
  'Groceries': 'shopping-cart',
  'Rent': 'house',
  'Eating out': 'receipt',
  'Transport': 'map',
  'Fun': 'sparkles',
  'Bills': 'credit-card',
  'Income': 'wallet',
};

const List<({String id, String label, String name})> financeMonths = [
  (id: '2026-09', label: 'September 2026', name: 'September'),
  (id: '2026-08', label: 'August 2026', name: 'August'),
];

const financeToday = '2026-09-25';

const List<({String category, int cents})> financeBudgets = [
  (category: 'Groceries', cents: 50000),
  (category: 'Rent', cents: 145000),
  (category: 'Eating out', cents: 15000),
  (category: 'Transport', cents: 12000),
  (category: 'Fun', cents: 15000),
  (category: 'Bills', cents: 24000),
];

const List<({String name, int cents})> financeAccounts = [
  (name: 'Checking', cents: 421832),
  (name: 'Savings', cents: 1290000),
  (name: 'Credit card', cents: -64210),
  (name: 'Index funds', cents: 845571),
];

const List<FinanceTransaction> financeTransactions = [
  (
    id: 1,
    date: '2026-09-25',
    description: 'Oat latte at the Blue Door',
    account: 'Card',
    category: 'Eating out',
    cents: -650,
    status: FinanceStatus.pending,
  ),
  (
    id: 2,
    date: '2026-09-24',
    description: 'Whole Foods',
    account: 'Card',
    category: 'Groceries',
    cents: -8412,
    status: FinanceStatus.cleared,
  ),
  (
    id: 3,
    date: '2026-09-24',
    description: 'Invoice 118, Pemberton & Sons',
    account: 'Checking',
    category: 'Income',
    cents: 180000,
    status: FinanceStatus.pending,
  ),
  (
    id: 4,
    date: '2026-09-23',
    description: 'Metro pass top-up',
    account: 'Checking',
    category: 'Transport',
    cents: -3000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 5,
    date: '2026-09-22',
    description: 'Bakery on rue Cler',
    account: 'Card',
    category: 'Eating out',
    cents: -1840,
    status: FinanceStatus.cleared,
  ),
  (
    id: 6,
    date: '2026-09-21',
    description: 'Anniversary dinner',
    account: 'Card',
    category: 'Eating out',
    cents: -9800,
    status: FinanceStatus.cleared,
  ),
  (
    id: 7,
    date: '2026-09-20',
    description: 'Farmers market',
    account: 'Checking',
    category: 'Groceries',
    cents: -4630,
    status: FinanceStatus.cleared,
  ),
  (
    id: 8,
    date: '2026-09-19',
    description: 'Climbing gym',
    account: 'Card',
    category: 'Fun',
    cents: -3800,
    status: FinanceStatus.cleared,
  ),
  (
    id: 9,
    date: '2026-09-18',
    description: 'Electric bill',
    account: 'Checking',
    category: 'Bills',
    cents: -9215,
    status: FinanceStatus.cleared,
  ),
  (
    id: 10,
    date: '2026-09-17',
    description: 'Corner shop',
    account: 'Card',
    category: 'Groceries',
    cents: -6785,
    status: FinanceStatus.cleared,
  ),
  (
    id: 11,
    date: '2026-09-15',
    description: 'Salary, Marigold Paper Co.',
    account: 'Checking',
    category: 'Income',
    cents: 340000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 12,
    date: '2026-09-14',
    description: 'Cinema, two tickets',
    account: 'Card',
    category: 'Fun',
    cents: -2200,
    status: FinanceStatus.cleared,
  ),
  (
    id: 13,
    date: '2026-09-12',
    description: 'Taxi home (charged twice?)',
    account: 'Card',
    category: 'Transport',
    cents: -2400,
    status: FinanceStatus.flagged,
  ),
  (
    id: 14,
    date: '2026-09-10',
    description: 'Internet',
    account: 'Checking',
    category: 'Bills',
    cents: -4900,
    status: FinanceStatus.cleared,
  ),
  (
    id: 15,
    date: '2026-09-08',
    description: 'Whole Foods',
    account: 'Card',
    category: 'Groceries',
    cents: -10250,
    status: FinanceStatus.cleared,
  ),
  (
    id: 16,
    date: '2026-09-05',
    description: 'Ramen night',
    account: 'Card',
    category: 'Eating out',
    cents: -6000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 17,
    date: '2026-09-03',
    description: 'Watercolor set',
    account: 'Card',
    category: 'Fun',
    cents: -3600,
    status: FinanceStatus.cleared,
  ),
  (
    id: 18,
    date: '2026-09-02',
    description: 'Rent',
    account: 'Checking',
    category: 'Rent',
    cents: -145000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 19,
    date: '2026-09-01',
    description: 'Phone plan',
    account: 'Checking',
    category: 'Bills',
    cents: -6400,
    status: FinanceStatus.cleared,
  ),
  (
    id: 20,
    date: '2026-09-01',
    description: 'Garden club dues',
    account: 'Checking',
    category: 'Fun',
    cents: -1200,
    status: FinanceStatus.cleared,
  ),
  (
    id: 21,
    date: '2026-08-31',
    description: 'Whole Foods',
    account: 'Card',
    category: 'Groceries',
    cents: -9120,
    status: FinanceStatus.cleared,
  ),
  (
    id: 22,
    date: '2026-08-29',
    description: 'Salary, Marigold Paper Co.',
    account: 'Checking',
    category: 'Income',
    cents: 340000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 23,
    date: '2026-08-27',
    description: 'Pottery class',
    account: 'Card',
    category: 'Fun',
    cents: -4500,
    status: FinanceStatus.cleared,
  ),
  (
    id: 24,
    date: '2026-08-24',
    description: 'Ramen night',
    account: 'Card',
    category: 'Eating out',
    cents: -5200,
    status: FinanceStatus.cleared,
  ),
  (
    id: 25,
    date: '2026-08-20',
    description: 'Electric bill',
    account: 'Checking',
    category: 'Bills',
    cents: -8830,
    status: FinanceStatus.cleared,
  ),
  (
    id: 26,
    date: '2026-08-18',
    description: 'Farmers market',
    account: 'Checking',
    category: 'Groceries',
    cents: -5210,
    status: FinanceStatus.cleared,
  ),
  (
    id: 27,
    date: '2026-08-14',
    description: 'Metro pass top-up',
    account: 'Checking',
    category: 'Transport',
    cents: -3000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 28,
    date: '2026-08-12',
    description: 'Invoice 112, Pemberton & Sons',
    account: 'Checking',
    category: 'Income',
    cents: 120000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 29,
    date: '2026-08-10',
    description: 'Trattoria',
    account: 'Card',
    category: 'Eating out',
    cents: -7300,
    status: FinanceStatus.cleared,
  ),
  (
    id: 30,
    date: '2026-08-02',
    description: 'Rent',
    account: 'Checking',
    category: 'Rent',
    cents: -145000,
    status: FinanceStatus.cleared,
  ),
  (
    id: 31,
    date: '2026-08-01',
    description: 'Phone plan',
    account: 'Checking',
    category: 'Bills',
    cents: -6400,
    status: FinanceStatus.cleared,
  ),
];

const List<String> _monthNames = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// Cents as dollars: `$1,234.50`, `−$6.50` (a true minus), `+$18.00` with
/// [sign].
String financeMoney(num cents, {bool sign = false}) {
  final abs = (cents.round()).abs();
  final dollars = '${abs ~/ 100}'.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  final body = '\$$dollars.${'${abs % 100}'.padLeft(2, '0')}';
  if (cents < 0) return '\u2212$body';
  if (sign && cents > 0) return '+$body';
  return body;
}

/// Whole dollars without the cents: `$2,410`.
String financeDollars(num value) =>
    financeMoney(value.round() * 100).replaceFirst(RegExp(r'\.00$'), '');

/// An ISO date as `Sep 25`.
String financeShortDate(String iso) {
  final [_, month, day] = iso.split('-');
  return '${_monthNames.elementAtOrNull(int.parse(month) - 1) ?? month} ${int.parse(day)}';
}

List<FinanceTransaction> financeInMonth(
  List<FinanceTransaction> list,
  String month,
) => [
  for (final transaction in list)
    if (transaction.date.startsWith(month)) transaction,
];

/// Money out per category in [month], in cents.
Map<String, int> financeSpentBy(List<FinanceTransaction> list, String month) {
  final out = <String, int>{};
  for (final transaction in financeInMonth(list, month)) {
    if (transaction.cents >= 0) continue;
    out[transaction.category] =
        (out[transaction.category] ?? 0) - transaction.cents;
  }
  return out;
}

/// Money in and out per month, April to September, in whole dollars.
List<Map<String, Object?>> financeCashFlow(List<FinanceTransaction> list) {
  Map<String, Object?> totals(String month, String name) {
    final rows = financeInMonth(list, month);
    final income = rows
        .where((t) => t.cents > 0)
        .fold<int>(0, (sum, t) => sum + t.cents);
    final spending = rows
        .where((t) => t.cents < 0)
        .fold<int>(0, (sum, t) => sum - t.cents);
    return {
      'month': name,
      'income': (income / 100).round(),
      'spending': (spending / 100).round(),
    };
  }

  return [
    {'month': 'Apr', 'income': 5200, 'spending': 2410},
    {'month': 'May', 'income': 5200, 'spending': 2180},
    {'month': 'Jun', 'income': 5350, 'spending': 2630},
    {'month': 'Jul', 'income': 5200, 'spending': 2305},
    totals('2026-08', 'Aug'),
    totals('2026-09', 'Sep'),
  ];
}

/// Parses `12.50`, `$1,200` or `12,5` to cents; null unless above zero.
int? financeParseAmount(String text) {
  final trimmed = text.replaceAll(RegExp(r'[$\s]'), '');
  if (!RegExp(r'^[\d.,]+$').hasMatch(trimmed)) return null;
  final normal = switch (trimmed.contains('.')) {
    true => trimmed.replaceAll(',', ''),
    false => trimmed.replaceFirst(',', '.'),
  };
  final value = double.tryParse(normal);
  if (value == null || !value.isFinite || value <= 0) return null;
  return (value * 100).round();
}
