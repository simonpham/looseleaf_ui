import 'package:gallery/features/components/examples/input_otp/input_otp.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/input-otp/`.
const inputOtpExamples = <GalleryExample>[
  GalleryExample(
    title: 'Six digits',
    description:
        'Click and type, or paste "482915" (three digits are already in). The box with the caret wears the blue ring and a blinking pencil stroke; each digit writes itself in; the dash is only decoration.',
    height: 220,
    source: 'input_otp/input_otp_six_digits_example.dart',
    builder: InputOtpSixDigitsExample.new,
  ),
  GalleryExample(
    title: 'Letters and digits, a wrong code',
    description:
        'pattern lets letters in (anything else is refused, also when pasted). The right code here is AB12; the box starts on AB13, so you can see what a wrong code looks like: red boxes and a message you write. Change the last character to 2 and it clears.',
    height: 240,
    source: 'input_otp/input_otp_letters_and_invalid_example.dart',
    builder: InputOtpLettersAndInvalidExample.new,
  ),
  GalleryExample(
    title: 'Verify your email',
    description:
        'The whole flow: the last digit completes the code (onComplete), which checks it; a wrong one turns the boxes red and offers a fresh start; 246810 is the right code. Resend is a link-style Button.',
    stage: ExampleStage.desk,
    height: 420,
    source: 'input_otp/input_otp_verify_your_email_example.dart',
    builder: InputOtpVerifyYourEmailExample.new,
  ),
  GalleryExample(
    title: 'Three and three',
    description:
        'shadcn\'s `input-otp-demo`: six digits in two groups with the separator between them. Type, paste, or use Backspace; the boxes are drawn, the input behind them is one real field.',
    source: 'input_otp/input_otp_demo_example.dart',
    builder: InputOtpDemoExample.new,
  ),
  GalleryExample(
    title: 'Digits and letters',
    description:
        'shadcn\'s `input-otp-pattern`: `pattern` takes one of the InputOTPPattern presets (upstream\'s REGEXP_ONLY_* constants). Anything the pattern refuses is dropped, pasted or typed.',
    source: 'input_otp/input_otp_pattern_example.dart',
    builder: InputOtpPatternExample.new,
  ),
  GalleryExample(
    title: 'Two-two-two',
    description:
        'shadcn\'s `input-otp-separator`: three groups of two with a separator between each pair. The dash is decoration only; the screen reader hears one six-digit field.',
    source: 'input_otp/input_otp_separator_example.dart',
    builder: InputOtpSeparatorExample.new,
  ),
  GalleryExample(
    title: 'Controlled',
    description:
        'shadcn\'s `input-otp-controlled`: `onChanged` holds the code in your state, and a line under the boxes echoes it back. The line is a live region, so it is read out as you type.',
    source: 'input_otp/input_otp_controlled_example.dart',
    builder: InputOtpControlledExample.new,
  ),
];
