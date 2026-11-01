import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_area.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_description.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_file.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_icon.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_limits.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_list.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_rejections.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_scope.dart';
import 'package:looseleaf_ui/src/components/dropzone/dropzone_title.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Opens the app's file picker; resolves to the files chosen, or null.
typedef DropzoneBrowse = Future<List<DropzoneFile>?> Function();

/// Builds the message of a rejection [code] for [file].
typedef DropzoneMessage = String Function(DropzoneFile file);

/// Checks a file the built-in limits let through; an error turns it away.
typedef DropzoneValidator = DropzoneFileError? Function(DropzoneFile file);

/// A dashed pencil area files are dropped on or browsed for, with the
/// files listed under it and the ones turned away (wrong kind, too large,
/// too many) said in red.
///
/// Flutter widgets have no file picker or desktop drag and drop: the app
/// supplies them. [onBrowse] opens its picker (the area calls it on tap,
/// Enter and Space); a drop handler hands files to
/// `Dropzone.of(context).add` and drives [dragOver]. The dropzone checks
/// [accept], [maxSize], [minSize], [maxFiles] and [validator] itself.
///
/// ```dart
/// Dropzone(
///   accept: const ['image/*', '.pdf'],
///   maxSize: 5 * 1024 * 1024,
///   onBrowse: pickFiles,
///   onFilesChange: (files) => setState(() => attachments = files),
/// )
/// ```
///
/// Mirrors `Dropzone` in upstream `src/components/ui/dropzone.tsx`.
class Dropzone extends StatefulWidget {
  const Dropzone({
    super.key,
    this.files,
    this.initialFiles = const [],
    this.onFilesChange,
    this.onBrowse,
    this.accept = const [],
    this.multiple = true,
    this.maxFiles,
    this.maxSize,
    this.minSize,
    this.disabled = false,
    this.invalid = false,
    this.dragOver = false,
    this.validator,
    this.messages = const {},
    this.onDrop,
    this.onReject,
    this.child,
  });

  /// The files, when the app holds them; null lets the dropzone keep
  /// its own, starting from [initialFiles].
  final List<DropzoneFile>? files;

  final List<DropzoneFile> initialFiles;

  /// Called with the next list of files.
  final ValueChanged<List<DropzoneFile>>? onFilesChange;

  /// Opens the app's file picker.
  final DropzoneBrowse? onBrowse;

  /// The kinds taken: extensions (`.pdf`), MIME types or families
  /// (`image/*`); every kind when empty.
  final List<String> accept;

  /// Several files; false keeps one, replacing it.
  final bool multiple;

  /// The most files kept.
  final int? maxFiles;

  /// The largest file taken, in bytes.
  final int? maxSize;

  /// The smallest file taken, in bytes.
  final int? minSize;

  final bool disabled;

  /// Red pencil around the area.
  final bool invalid;

  /// Files are being dragged over the area: Stubby carries one in and the
  /// box turns solid. The app's drag-and-drop handler sets it.
  final bool dragOver;

  final DropzoneValidator? validator;

  /// Replaces the built-in rejection messages.
  final Map<DropzoneErrorCode, DropzoneMessage> messages;

  /// Called after each batch with the files taken and turned away.
  final void Function(
    List<DropzoneFile> accepted,
    List<DropzoneRejection> rejected,
  )?
  onDrop;

  /// Called with the files turned away, when there are any.
  final ValueChanged<List<DropzoneRejection>>? onReject;

  /// The parts; the area (icon, title, description), the rejections and
  /// the list when null.
  final Widget? child;

  /// The nearest dropzone's state, like upstream `useDropzone()`.
  static DropzoneState of(BuildContext context) =>
      DropzoneScope.of(context).state;

  @override
  State<Dropzone> createState() => DropzoneState();
}

/// The state of a [Dropzone]: its files, the latest rejections and the
/// ways to change them.
class DropzoneState extends State<Dropzone> {
  late List<DropzoneFile> _inner = widget.initialFiles;
  List<DropzoneRejection> _rejections = const [];
  int _revision = 0;

  /// The files kept.
  List<DropzoneFile> get files => widget.files ?? _inner;

  /// The files turned away by the latest batch.
  List<DropzoneRejection> get rejections => _rejections;

  bool get disabled => widget.disabled;
  bool get invalid => widget.invalid;
  bool get multiple => widget.multiple;
  bool get dragOver => widget.dragOver && !widget.disabled;
  List<String> get accept => widget.accept;
  int? get maxSize => widget.maxSize;
  int? get maxFiles => widget.maxFiles;

  @override
  void didUpdateWidget(Dropzone oldWidget) {
    super.didUpdateWidget(oldWidget);
    _revision++;
  }

  void _setFiles(List<DropzoneFile> next) {
    if (widget.files == null) _inner = next;
    widget.onFilesChange?.call(next);
  }

  DropzoneFileError _say(
    DropzoneErrorCode code,
    DropzoneFile file,
    String fallback,
  ) => DropzoneFileError(
    code: code,
    message: widget.messages[code]?.call(file) ?? fallback,
  );

  /// Checks [incoming] against the limits, keeps the files that pass and
  /// says why the others were turned away.
  void add(List<DropzoneFile> incoming) {
    final zone = widget;
    if (zone.disabled || incoming.isEmpty) return;
    final current = files;
    final maxFiles = zone.maxFiles;
    final room = switch ((zone.multiple, maxFiles)) {
      (false, _) => 1,
      (true, null) => incoming.length,
      (true, final most?) => (most - current.length).clamp(0, most),
    };
    final accepted = <DropzoneFile>[];
    final rejected = <DropzoneRejection>[];
    for (final file in incoming) {
      final errors = [
        if (!matchesAccept(file, zone.accept))
          _say(
            DropzoneErrorCode.fileInvalidType,
            file,
            '${file.name} is not a file type we take.',
          ),
        if (zone.maxSize case final most? when file.size > most)
          _say(
            DropzoneErrorCode.fileTooLarge,
            file,
            '${file.name} is larger than ${formatBytes(most)}.',
          ),
        if (zone.minSize case final least? when file.size < least)
          _say(
            DropzoneErrorCode.fileTooSmall,
            file,
            '${file.name} is smaller than ${formatBytes(least)}.',
          ),
      ];
      if (errors.isEmpty) {
        if (zone.validator?.call(file) case final custom?) errors.add(custom);
      }
      if (errors.isEmpty && accepted.length >= room) {
        final plural = switch (maxFiles == 1) {
          true => '',
          false => 's',
        };
        errors.add(
          _say(DropzoneErrorCode.tooManyFiles, file, switch (zone.multiple) {
            true => 'Only $maxFiles file$plural at a time.',
            false => 'One file at a time.',
          }),
        );
      }
      if (errors.isNotEmpty) {
        rejected.add(DropzoneRejection(file: file, errors: errors));
        continue;
      }
      accepted.add(file);
    }
    setState(() {
      _rejections = rejected;
      _revision++;
      if (accepted.isEmpty) return;
      _setFiles(switch (zone.multiple) {
        true => [
          for (final kept in current)
            if (!accepted.any((file) => file.sameAs(kept))) kept,
          ...accepted,
        ],
        false => [accepted.first],
      });
    });
    zone.onDrop?.call(accepted, rejected);
    if (rejected.isNotEmpty) zone.onReject?.call(rejected);
  }

  /// Takes [file] out of the list.
  void remove(DropzoneFile file) {
    if (widget.disabled) return;
    setState(() {
      _setFiles([
        for (final kept in files)
          if (!identical(kept, file)) kept,
      ]);
      _rejections = const [];
      _revision++;
    });
  }

  /// Empties the list and the rejections.
  void clear() => setState(() {
    _setFiles(const []);
    _rejections = const [];
    _revision++;
  });

  void clearRejections() => setState(() {
    _rejections = const [];
    _revision++;
  });

  /// Opens the app's picker and adds what it returns.
  void browse() {
    final pick = widget.onBrowse;
    if (widget.disabled || pick == null) return;
    unawaited(
      pick().then((picked) {
        if (picked == null || !mounted) return;
        add(picked);
      }),
    );
  }

  @override
  Widget build(BuildContext context) => DropzoneScope(
    state: this,
    revision: _revision,
    child:
        widget.child ??
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.d12,
          children: [
            const DropzoneArea(
              children: [
                DropzoneIcon(),
                DropzoneTitle(),
                DropzoneDescription(),
              ],
            ),
            if (_rejections.isNotEmpty) const DropzoneRejections(),
            if (files.isNotEmpty) const DropzoneList(),
          ],
        ),
  );
}
