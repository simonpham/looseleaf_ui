/// The plans you can be on.
enum BillingPlan {
  starter(
    name: 'Starter',
    cents: 0,
    blurb: 'One notebook, one pen, no rush.',
    notebooks: 3,
    storageGb: 1,
    seats: 1,
  ),
  studio(
    name: 'Studio',
    cents: 1200,
    blurb: 'Ten notebooks and the good highlighters.',
    notebooks: 10,
    storageGb: 10,
    seats: 3,
  ),
  workshop(
    name: 'Workshop',
    cents: 3200,
    blurb: 'A whole desk. Washi tape included.',
    notebooks: 100,
    storageGb: 100,
    seats: 15,
  );

  const BillingPlan({
    required this.name,
    required this.cents,
    required this.blurb,
    required this.notebooks,
    required this.storageGb,
    required this.seats,
  });

  final String name;
  final int cents;
  final String blurb;
  final int notebooks;
  final int storageGb;
  final int seats;

  /// How much of [usage] this plan holds.
  int limitOf(BillingUsage usage) => switch (usage) {
    BillingUsage.notebooks => notebooks,
    BillingUsage.storage => storageGb,
    BillingUsage.seats => seats,
  };
}

/// What is counted against a plan.
enum BillingUsage {
  notebooks(label: 'Notebooks', used: 8, unit: ''),
  storage(label: 'Storage', used: 8.4, unit: ' GB'),
  seats(label: 'People on the desk', used: 3, unit: '');

  const BillingUsage({
    required this.label,
    required this.used,
    required this.unit,
  });

  final String label;
  final num used;
  final String unit;

  String get usedText => '${formatNumber(used)}$unit';
}

/// [value] like JavaScript prints it: `8`, `8.4`.
String formatNumber(num value) => switch (value == value.roundToDouble()) {
  true => '${value.round()}',
  false => '$value',
};

String money(int cents) => '\$${(cents / 100).toStringAsFixed(2)}';

const int billingDaysLeft = 18;
const int billingDaysInCycle = 30;
const String billingRenews = '14 Oct';

enum PlanChangeKind { same, upgrade, downgrade }

/// Moving from one plan to another: what it costs today and every month.
typedef PlanChange = ({PlanChangeKind kind, int today, int monthly});

PlanChange planChange(BillingPlan from, BillingPlan to) {
  if (from == to) {
    return (kind: PlanChangeKind.same, today: 0, monthly: to.cents);
  }
  if (to.cents > from.cents) {
    return (
      kind: PlanChangeKind.upgrade,
      today: ((to.cents - from.cents) * billingDaysLeft / billingDaysInCycle)
          .round(),
      monthly: to.cents,
    );
  }
  return (kind: PlanChangeKind.downgrade, today: 0, monthly: to.cents);
}

typedef InvoiceLine = ({String name, String price});

typedef Invoice = ({
  String number,
  String date,
  List<InvoiceLine> lines,
  String total,
  String paidWith,
});

const List<Invoice> billingInvoices = [
  (
    number: '2026-0009',
    date: '14 Sep 2026',
    lines: [
      (name: 'Studio plan, September', price: '12.00'),
      (name: 'Extra storage, 5 GB', price: '2.50'),
    ],
    total: '14.50',
    paidWith: 'Visa 4242',
  ),
  (
    number: '2026-0008',
    date: '14 Aug 2026',
    lines: [(name: 'Studio plan, August', price: '12.00')],
    total: '12.00',
    paidWith: 'Visa 4242',
  ),
  (
    number: '2026-0007',
    date: '14 Jul 2026',
    lines: [
      (name: 'Studio plan, July', price: '12.00'),
      (name: 'Washi tape pack, sticker sheet', price: '6.00'),
    ],
    total: '18.00',
    paidWith: 'Visa 4242',
  ),
  (
    number: '2026-0006',
    date: '14 Jun 2026',
    lines: [(name: 'Studio plan, June', price: '12.00')],
    total: '12.00',
    paidWith: 'Visa 4242',
  ),
  (
    number: '2026-0005',
    date: '14 May 2026',
    lines: [(name: 'Studio plan, May', price: '12.00')],
    total: '12.00',
    paidWith: 'Visa 4242',
  ),
  (
    number: '2026-0004',
    date: '14 Apr 2026',
    lines: [(name: 'Starter to Studio, part month', price: '7.20')],
    total: '7.20',
    paidWith: 'Visa 4242',
  ),
];

/// A card on file.
typedef SavedCard = ({String brand, String last4, String expiry});
