import 'package:gallery/features/components/examples/signature_pad/signature_pad.dart';
import 'package:gallery/features/components/models/models.dart';

/// Mirrors `src/docs/examples/signature-pad/`.
const signaturePadExamples = <GalleryExample>[
  GalleryExample(
    title: 'Default',
    description:
        'Sign with the mouse, a finger or a pen. The brush swells where you lean on it.',
    layout: ExampleLayout.stack,
    source: 'signature_pad/signature_pad_default_example.dart',
    builder: SignaturePadDefaultExample.new,
  ),
  GalleryExample(
    title: 'Type instead',
    description:
        'The typed fallback: the name is hand lettering with a brush swash under it. Anyone who cannot draw gets a signature that is still an image.',
    layout: ExampleLayout.stack,
    source: 'signature_pad/signature_pad_type_instead_example.dart',
    builder: SignaturePadTypeInsteadExample.new,
  ),
  GalleryExample(
    title: 'Agreement form',
    description:
        'A real form: the signature is a required field that posts as a data URL. Submit it empty to see the red baseline; sign and it goes through.',
    layout: ExampleLayout.stack,
    stage: ExampleStage.desk,
    source: 'signature_pad/signature_pad_agreement_form_example.dart',
    builder: SignaturePadAgreementFormExample.new,
  ),
];
