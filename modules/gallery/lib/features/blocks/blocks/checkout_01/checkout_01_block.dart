import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:gallery/features/blocks/blocks/checkout_01/checkout_01.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// A checkout page: three numbered steps on a taped page beside a basket
/// whose receipt writes itself, then a thank you with a stamped receipt.
///
/// Mirrors upstream `src/blocks/checkout-01/page.tsx`.
class Checkout01Block extends StatefulWidget {
  const Checkout01Block({
    super.key,
    this.defaultQty = checkoutDefaultQty,
    this.orderNumber = '0042 1187',
    this.today,
    this.onPlace,
  });

  final List<int> defaultQty;
  final String orderNumber;

  /// The month card expiry is checked against; the current one when null.
  final CheckoutMonth? today;

  /// Places the order; throw to show why it was not placed.
  final FutureOr<void> Function(
    CheckoutPlacedOrder order,
    Map<String, Object?> values,
  )?
  onPlace;

  @override
  State<Checkout01Block> createState() => _Checkout01BlockState();
}

class _Checkout01BlockState extends State<Checkout01Block> {
  final _form = FormController(initialValues: checkoutDefaultValues);
  late final _validators = checkoutValidators(
    today: widget.today ?? checkoutCurrentMonth(),
    method: () => _method,
  );
  late List<int> _qty = List.of(widget.defaultQty);
  String? _code;
  var _placing = false;
  CheckoutPlacedOrder? _placed;
  var _failure = '';

  static const double _maxWidth = 1152;
  static const double _summaryWidth = 384;

  String get _method => _form.value<String>('method') ?? 'standard';

  @override
  void initState() {
    super.initState();
    _form.addListener(_changed);
  }

  @override
  void dispose() {
    _form
      ..removeListener(_changed)
      ..dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  void _submit() => unawaited(
    _form.handleSubmit((values) async {
      final order = (
        number: widget.orderNumber,
        email: '${values['email']}',
        name: '${values['name']}',
        qty: _qty,
        totals: checkoutTotals(_qty, _method, _code),
        code: _code,
      );
      setState(() {
        _placing = true;
        _failure = '';
      });
      try {
        await widget.onPlace?.call(order, values);
        if (mounted) setState(() => _placed = order);
      } on Object catch (error) {
        final message = switch (error) {
          StateError(:final message) when message.isNotEmpty => message,
          _ => 'Something went wrong on our side.',
        };
        if (mounted) setState(() => _failure = message);
      } finally {
        if (mounted) setState(() => _placing = false);
      }
    }),
  );

  void _keepShopping() {
    setState(() {
      _placed = null;
      _qty = List.of(widget.defaultQty);
      _code = null;
    });
    _form.reset();
  }

  @override
  Widget build(BuildContext context) {
    if (_placed case final order?) {
      return Checkout01Done(order: order, onKeepShopping: _keepShopping);
    }
    final totals = checkoutTotals(_qty, _method, _code);
    final shipping = {
      for (final method in checkoutMethods)
        method.id: checkoutTotals(_qty, method.id, _code).shipping,
    };
    final wide = MediaQuery.sizeOf(context).width >= 640;
    final page = PaperPage(
      width: PageWidth.full,
      tape: PaperTape.top,
      seed: 'checkout-form',
      children: [
        const PageHeader(
          children: [
            PageTitle(
              Text('Checkout'),
              underline: TitleMark.wavy,
              seed: 'checkout-title',
            ),
            PageDescription(
              Text(
                'Three short steps and it is on its way. We ask for nothing we do not need.',
              ),
            ),
          ],
        ),
        if (_failure.isNotEmpty)
          Alert(
            variant: AlertTone.destructive,
            icon: const InkIcon('circle-alert'),
            children: [
              const AlertTitle(Text('The order was not placed')),
              AlertDescription(
                Text(
                  '$_failure You have not been charged. Try again, or use another card.',
                ),
              ),
            ],
          ),
        Checkout01Form(
          form: _form,
          validators: _validators,
          shipping: shipping,
        ),
      ],
    );
    final summary = Checkout01Summary(
      qty: _qty,
      onQty: (index, value) => setState(
        () => _qty = [
          for (final (at, count) in _qty.indexed)
            switch (at == index) {
              true => value,
              false => count,
            },
        ],
      ),
      code: _code,
      onCode: (code) => setState(() => _code = code),
      totals: totals,
      orderNumber: widget.orderNumber,
      onPay: _submit,
      placing: _placing,
    );
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: switch (wide) {
              true => Spacing.d32,
              false => Spacing.d16,
            },
            vertical: Spacing.d40,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 896) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: Spacing.d40,
                  children: [
                    Expanded(child: page),
                    SizedBox(width: _summaryWidth, child: summary),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.d40,
                children: [page, summary],
              );
            },
          ),
        ),
      ),
    );
  }
}
