final RegExp _nonDigits = RegExp(r'\D');
final RegExp _amex = RegExp(r'^3[47]');
final RegExp _mastercard = RegExp('^(5[1-5]|2[2-7])');
final RegExp _expiry = RegExp(r'^(0[1-9]|1[0-2])/\d{2}$');
final RegExp _cvc = RegExp(r'^\d{3,4}$');
final RegExp _cardDigits = RegExp(r'^\d{13,19}$');

String billingDigits(String value) => value.replaceAll(_nonDigits, '');

/// The Luhn checksum every card number passes.
bool billingLuhn(String digits) {
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

String billingCardBrand(String digits) {
  if (digits.startsWith('4')) return 'Visa';
  if (_mastercard.hasMatch(digits)) return 'Mastercard';
  if (_amex.hasMatch(digits)) return 'Amex';
  return 'Card';
}

/// Groups the digits in fours, or 4-6-5 for Amex.
String billingFormatCardNumber(String raw) {
  final all = billingDigits(raw);
  final digits = all.substring(0, all.length.clamp(0, 19));
  if (_amex.hasMatch(digits)) {
    return [
      digits.substring(0, digits.length.clamp(0, 4)),
      digits.substring(digits.length.clamp(0, 4), digits.length.clamp(0, 10)),
      digits.substring(digits.length.clamp(0, 10), digits.length.clamp(0, 15)),
    ].where((group) => group.isNotEmpty).join(' ');
  }
  return [
    for (var i = 0; i < digits.length; i += 4)
      digits.substring(i, (i + 4).clamp(0, digits.length)),
  ].join(' ');
}

/// `MM/YY` as you type: `1` stays, `3` becomes `03/`.
String billingFormatExpiry(String raw) {
  final all = billingDigits(raw);
  final digits = all.substring(0, all.length.clamp(0, 4));
  if (digits.length == 1 && int.parse(digits) > 1) return '0$digits/';
  if (digits.length > 2) {
    return '${digits.substring(0, 2)}/${digits.substring(2)}';
  }
  return digits;
}

String? billingValidateCardName(Object? value) =>
    switch ('${value ?? ''}'.trim()) {
      final name when name.length < 2 =>
        'Type the name as it is printed on the card.',
      _ => null,
    };

String? billingValidateCardNumber(Object? value) {
  final digits = '${value ?? ''}'.replaceAll(' ', '');
  if (!_cardDigits.hasMatch(digits)) {
    return 'A card number has 13 to 19 digits.';
  }
  if (billingLuhn(digits)) return null;
  return 'That number does not add up. Check each digit.';
}

String? billingValidateCardExpiry(Object? value, DateTime today) {
  final expiry = '${value ?? ''}';
  if (!_expiry.hasMatch(expiry)) return 'Write it as MM/YY, like 08/28.';
  final [month, year] = expiry.split('/').map(int.parse).toList();
  final fullYear = 2000 + year;
  final current =
      fullYear > today.year || (fullYear == today.year && month >= today.month);
  if (!current) return 'That card has expired.';
  return null;
}

String? billingValidateCardCvc(Object? value) => switch (_cvc.hasMatch(
  '${value ?? ''}',
)) {
  true => null,
  false => 'The security code is 3 or 4 digits.',
};
