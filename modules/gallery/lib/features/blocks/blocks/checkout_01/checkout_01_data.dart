/// A product in the shop.
typedef CheckoutProduct = ({String id, String name, int cents, String note});

/// A delivery method and what it costs before any free delivery.
typedef CheckoutMethod = ({String id, String name, String help, int cents});

/// What a promo code does.
typedef CheckoutPromo = ({String label, int? percent, bool freeStandard});

/// The money on an order, in cents.
typedef CheckoutTotals = ({
  int subtotal,
  int discount,
  int shipping,
  int vat,
  int total,
});

/// A calendar month, to check card expiry against.
typedef CheckoutMonth = ({int year, int month});

/// An order once it is paid.
typedef PlacedOrder = ({
  String number,
  String email,
  String name,
  List<int> qty,
  CheckoutTotals totals,
  String? code,
});

const List<CheckoutProduct> checkoutProducts = [
  (
    id: 'notebook',
    name: 'Field notebook, A5 ruled',
    cents: 1400,
    note: 'Stitched, 96 pages',
  ),
  (
    id: 'tape',
    name: 'Washi tape, three rolls',
    cents: 900,
    note: 'Dots, stripes, gingham',
  ),
  (id: 'pen', name: 'Brass pen', cents: 2200, note: 'Refillable, felt tip'),
];

const List<int> checkoutDefaultQty = [1, 2, 1];

String money(int cents) => (cents / 100).toStringAsFixed(2);

const List<CheckoutMethod> checkoutMethods = [
  (
    id: 'standard',
    name: 'Standard',
    help: '4 to 6 days. Free over 50.00.',
    cents: 490,
  ),
  (
    id: 'express',
    name: 'Express',
    help: 'Tomorrow, if you order before 4 pm.',
    cents: 990,
  ),
  (
    id: 'pickup',
    name: 'Pick up at the shop',
    help: "12 rue de l'Eau, ready in an hour.",
    cents: 0,
  ),
];

const Map<String, CheckoutPromo> checkoutPromos = {
  'PAPER10': (label: '10% off the paper', percent: 10, freeStandard: false),
  'FREESHIP': (
    label: 'Standard delivery on us',
    percent: null,
    freeStandard: true,
  ),
};

const freeShippingFrom = 5000;
const vatPercent = 23;

CheckoutTotals checkoutTotals(List<int> qty, String method, String? code) {
  var subtotal = 0;
  for (final (index, product) in checkoutProducts.indexed) {
    subtotal += product.cents * (qty.elementAtOrNull(index) ?? 0);
  }
  final promo = checkoutPromos[code];
  final discount = switch (promo?.percent) {
    final percent? => (subtotal * percent / 100).round(),
    null => 0,
  };
  final base = checkoutMethods.firstWhere((m) => m.id == method).cents;
  final freeStandard = promo?.freeStandard ?? false;
  final shipping = switch (method) {
    _ when subtotal == 0 => 0,
    'standard' when subtotal - discount >= freeShippingFrom || freeStandard =>
      0,
    'express' when freeStandard => base - checkoutMethods.first.cents,
    _ => base,
  };
  final total = subtotal - discount + shipping;
  return (
    subtotal: subtotal,
    discount: discount,
    shipping: shipping,
    vat: (total * vatPercent / (100 + vatPercent)).round(),
    total: total,
  );
}

bool luhn(String digits) {
  var sum = 0;
  for (var i = 0; i < digits.length; i++) {
    var digit = int.parse(digits[digits.length - 1 - i]);
    if (i.isOdd) {
      digit *= 2;
      if (digit > 9) digit -= 9;
    }
    sum += digit;
  }
  return digits.isNotEmpty && sum % 10 == 0;
}

String _digits(String raw, int max) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  return digits.substring(0, digits.length.clamp(0, max));
}

String formatCardNumber(String raw) {
  final digits = _digits(raw, 19);
  if (RegExp('^3[47]').hasMatch(digits)) {
    return [
      digits.substring(0, digits.length.clamp(0, 4)),
      digits.substring(digits.length.clamp(0, 4), digits.length.clamp(0, 10)),
      digits.substring(digits.length.clamp(0, 10), digits.length.clamp(0, 15)),
    ].where((group) => group.isNotEmpty).join(' ');
  }
  return digits
      .replaceAllMapped(RegExp('(.{4})'), (match) => '${match[1]} ')
      .trim();
}

String formatExpiry(String raw) {
  final digits = _digits(raw, 4);
  if (digits.length == 1 && int.parse(digits) > 1) return '0$digits/';
  if (digits.length > 2) {
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }
  return digits;
}

CheckoutMonth currentMonth() {
  final now = DateTime.now();
  return (year: now.year, month: now.month);
}

const List<String> checkoutCountries = [
  'Portugal',
  'France',
  'Germany',
  'Netherlands',
  'United Kingdom',
  'United States',
];

const Map<String, Object?> checkoutDefaultValues = {
  'email': '',
  'name': '',
  'address': '',
  'city': '',
  'postcode': '',
  'country': 'Portugal',
  'method': 'standard',
  'cardName': '',
  'cardNumber': '',
  'expiry': '',
  'cvc': '',
  'terms': false,
};

/// Every field in the order it is on the form, with its label.
const Map<String, String> checkoutFieldLabels = {
  'email': 'Email',
  'name': 'Full name',
  'address': 'Street and number',
  'city': 'Town or city',
  'postcode': 'Postal code',
  'country': 'Country',
  'cardName': 'Name on card',
  'cardNumber': 'Card number',
  'expiry': 'Expires',
  'cvc': 'Security code',
  'terms': 'The terms',
};

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

String _trimmed(Object? value) => switch (value) {
  final String text => text.trim(),
  _ => '',
};

/// The checks of upstream's `makeCheckoutSchema`, by field. [method] reads
/// the chosen delivery, since pick up needs no address.
Map<String, String? Function(Object? value)> checkoutValidators({
  required CheckoutMonth today,
  required String Function() method,
}) {
  String? needsAddress(bool ok, String message) => switch (method()) {
    'pickup' => null,
    _ when ok => null,
    _ => message,
  };
  return {
    'email': (value) => switch (_email.hasMatch(_trimmed(value))) {
      true => null,
      false => 'Enter an address like ada@notes.dev.',
    },
    'name': (value) => switch (_trimmed(value).length >= 2) {
      true => null,
      false => 'Who should we address it to?',
    },
    'address': (value) => needsAddress(
      _trimmed(value).length >= 5,
      'Where should it go? Add a street and number.',
    ),
    'city': (value) =>
        needsAddress(_trimmed(value).length >= 2, 'Add the town or city.'),
    'postcode': (value) =>
        needsAddress(_trimmed(value).length >= 3, 'Add the postal code.'),
    'country': (value) => switch (_trimmed(value).isEmpty) {
      true => 'Choose a country.',
      false => null,
    },
    'cardName': (value) => switch (_trimmed(value).length >= 2) {
      true => null,
      false => 'Type the name as it is printed on the card.',
    },
    'cardNumber': (value) {
      final digits = _trimmed(value).replaceAll(RegExp(r'\s'), '');
      if (!RegExp(r'^\d{13,19}$').hasMatch(digits)) {
        return 'A card number has 13 to 19 digits.';
      }
      if (luhn(digits)) return null;
      return 'That number does not add up. Check each digit.';
    },
    'expiry': (value) {
      final text = _trimmed(value);
      if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$').hasMatch(text)) {
        return 'Write it as MM/YY, like 08/28.';
      }
      final [month, year] = text.split('/').map(int.parse).toList();
      final fullYear = 2000 + year;
      final current =
          fullYear > today.year ||
          (fullYear == today.year && month >= today.month);
      if (!current) return 'That card has expired.';
      return null;
    },
    'cvc': (value) => switch (RegExp(r'^\d{3,4}$').hasMatch(_trimmed(value))) {
      true => null,
      false => 'The security code is 3 or 4 digits.',
    },
    'terms': (value) => switch (value) {
      true => null,
      _ => 'Please tick the box to place the order.',
    },
  };
}
