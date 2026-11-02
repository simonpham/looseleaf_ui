import 'package:looseleaf_ui/looseleaf_ui.dart';

/// How often a plan is billed.
enum Pricing01Period { monthly, yearly }

/// One plan: its name, prices in cents and what it includes.
///
/// Mirrors `Tier` in upstream
/// `src/blocks/pricing-01/components/pricing-01-data.ts`.
typedef Pricing01Tier = ({
  String id,
  String name,
  String tagline,
  int monthly,
  int yearly,
  List<String> features,
  String cta,
  bool popular,
  TapeKind tape,
});

/// The three plans.
const List<Pricing01Tier> pricing01Tiers = [
  (
    id: 'starter',
    name: 'Starter',
    tagline: 'One notebook, one pen, no rush.',
    monthly: 0,
    yearly: 0,
    features: [
      '3 notebooks',
      '1 GB of paper',
      'Just you at the desk',
      'Help from the community',
    ],
    cta: 'Start for free',
    popular: false,
    tape: TapeKind.masking,
  ),
  (
    id: 'studio',
    name: 'Studio',
    tagline: 'Ten notebooks and the good highlighters.',
    monthly: 1200,
    yearly: 12000,
    features: [
      '10 notebooks',
      '10 GB of paper',
      '3 people at the desk',
      'The good highlighters',
      'Email help, same day',
    ],
    cta: 'Get Studio',
    popular: true,
    tape: TapeKind.washiDots,
  ),
  (
    id: 'workshop',
    name: 'Workshop',
    tagline: 'A whole desk. Washi tape included.',
    monthly: 3200,
    yearly: 32000,
    features: [
      '100 notebooks',
      '100 GB of paper',
      '15 people at the desk',
      'Unlimited washi tape',
      'A real person, quickly',
    ],
    cta: 'Get Workshop',
    popular: false,
    tape: TapeKind.washiStripes,
  ),
];

/// [cents] as dollars: `$12`, or `$26.67` when there are cents.
String pricing01Dollars(int cents) => switch (cents % 100) {
  0 => '\$${cents ~/ 100}',
  _ => '\$${(cents / 100).toStringAsFixed(2)}',
};

/// What [tier] costs a month when billed every [period].
int pricing01PerMonth(Pricing01Tier tier, Pricing01Period period) =>
    switch (period) {
      Pricing01Period.yearly => (tier.yearly / 12).round(),
      Pricing01Period.monthly => tier.monthly,
    };

/// The questions under the plans.
const List<({String question, String answer})> pricing01Faq = [
  (
    question: 'Can I change plans later?',
    answer: 'Any time. Going up starts today and you pay only the difference for the days that are left. Going down waits for your next renewal.',
  ),
  (
    question: 'What happens if I run out of notebooks?',
    answer: 'Nothing is deleted. The extra notebooks stay readable, and you can write in them again when there is room.',
  ),
  (
    question: 'Is there a discount for schools or clubs?',
    answer: 'Yes, 40% off for teachers, students and anyone running a club. Write to us from your school address and we will sort it out.',
  ),
  (
    question: 'Do you take my card details on this page?',
    answer: 'No. You pick a plan here and add a card on the next page, where it is checked and stored by our payment provider.',
  ),
];
