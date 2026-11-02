import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/looseleaf_ui.dart';

/// `w-52`.
const _width = 208.0;

/// `text-[1.1rem]`.
const _addressSize = 17.6;

class EnvelopeStocksAndAirmailExample extends StatelessWidget {
  const EnvelopeStocksAndAirmailExample({super.key});

  @override
  Widget build(BuildContext context) => const Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: Spacing.d32,
    runSpacing: Spacing.d32,
    children: [
      Envelope(
        seed: 'a',
        tiltDegrees: -1,
        maxWidth: _width,
        children: [
          EnvelopeFront(
            children: [
              EnvelopeAddress(
                cssFontSize: _addressSize,
                children: [
                  Text('The Stationer', softWrap: false),
                  Text('High Street', softWrap: false),
                ],
              ),
              EnvelopeTrigger(label: 'Open the letter from Ada'),
            ],
          ),
          EnvelopeLetter(child: Text('hello')),
        ],
      ),
      Envelope(
        stock: StockName.paper,
        stamp: Accent.sky,
        seed: 'b',
        tiltDegrees: 0.8,
        maxWidth: _width,
        children: [
          EnvelopeFront(
            children: [
              EnvelopeAddress(
                cssFontSize: _addressSize,
                children: [
                  Text('Marguerite', softWrap: false),
                  Text('Lyon', softWrap: false),
                ],
              ),
              EnvelopeTrigger(label: 'Open the letter for Marguerite'),
            ],
          ),
          EnvelopeLetter(child: Text('hello')),
        ],
      ),
      Envelope(
        stock: StockName.paper,
        airmail: true,
        stamp: Accent.tangerine,
        seed: 'c',
        tiltDegrees: -0.6,
        maxWidth: _width,
        children: [
          EnvelopeFront(
            children: [
              EnvelopeAddress(
                cssFontSize: _addressSize,
                children: [
                  Text('Ms. A. Lovelace', softWrap: false),
                  Text('Par avion', softWrap: false),
                ],
              ),
              EnvelopeTrigger(label: 'Open the airmail letter'),
            ],
          ),
          EnvelopeLetter(child: Text('hello')),
        ],
      ),
    ],
  );
}
