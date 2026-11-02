import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';

/// Announces [message] to screen readers in the ambient text direction.
Future<void> inkAnnounce(BuildContext context, String message) =>
    // `sendAnnouncement` replaces this on newer Flutter but is missing on 3.32.
    // ignore: deprecated_member_use
    SemanticsService.announce(message, Directionality.of(context));
