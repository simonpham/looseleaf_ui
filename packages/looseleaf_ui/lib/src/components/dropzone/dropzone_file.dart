import 'package:flutter/widgets.dart';

/// A file handed to a [Dropzone]: what the browser's `File` tells
/// upstream, filled in by the app's picker or drop handler.
class DropzoneFile {
  const DropzoneFile({
    required this.name,
    required this.size,
    this.type = '',
    this.lastModified = 0,
    this.preview,
    this.data,
  });

  /// The file name, with its extension.
  final String name;

  /// The size in bytes.
  final int size;

  /// The MIME type (`image/png`); empty when unknown.
  final String type;

  /// When the file last changed, in milliseconds since the epoch; tells
  /// two files with the same name and size apart.
  final int lastModified;

  /// An image to show as the row's thumbnail (upstream makes one from
  /// image files).
  final ImageProvider? preview;

  /// The app's own handle on the file (a path, bytes, a platform file).
  final Object? data;

  /// Upstream `sameFile`: the same name, size and modification time.
  bool sameAs(DropzoneFile other) =>
      other.name == name &&
      other.size == size &&
      other.lastModified == lastModified;
}

/// Why a file was turned away, upstream's `ErrorCode`.
enum DropzoneErrorCode {
  fileInvalidType,
  fileTooLarge,
  fileTooSmall,
  tooManyFiles,
  validator,
}

/// One reason a file was turned away.
class DropzoneFileError {
  const DropzoneFileError({required this.code, required this.message});

  final DropzoneErrorCode code;
  final String message;
}

/// A file the [Dropzone] turned away, with its reasons.
class DropzoneRejection {
  const DropzoneRejection({required this.file, required this.errors});

  final DropzoneFile file;
  final List<DropzoneFileError> errors;
}
