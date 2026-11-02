import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

/// Matches a [SemanticsNode] on only the properties given, like
/// `isSemantics`, plus its [role], which `matchesSemantics` can't check on
/// Flutter 3.32.
Matcher includesSemantics({
  SemanticsRole? role,
  String? label,
  String? hint,
  String? value,
  bool? isButton,
  bool? isEnabled,
  bool? isChecked,
  bool? hasCheckedState,
  bool? isSelected,
  bool? hasExpandedState,
  bool? isExpanded,
  bool? isFocusable,
  bool? isTextField,
  bool? isImage,
  bool? hasTapAction,
}) => allOf([
  if (role case final expectedRole?)
    isA<SemanticsNode>().having(
      (node) => node.getSemanticsData().role,
      'role',
      expectedRole,
    ),
  // `isSemantics` replaces this on newer Flutter but is missing on 3.32.
  // ignore: deprecated_member_use
  containsSemantics(
    label: label,
    hint: hint,
    value: value,
    isButton: isButton,
    isEnabled: isEnabled,
    isChecked: isChecked,
    hasCheckedState: hasCheckedState,
    isSelected: isSelected,
    hasExpandedState: hasExpandedState,
    isExpanded: isExpanded,
    isFocusable: isFocusable,
    isTextField: isTextField,
    isImage: isImage,
    hasTapAction: hasTapAction,
  ),
]);
