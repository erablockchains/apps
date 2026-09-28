// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;

import 'v13_migration_input.dart' as _i2;

class V13Completion {
  const V13Completion({
    required this.migrationVersion,
    required this.completedAt,
    required this.input,
  });

  factory V13Completion.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// u16
  final int migrationVersion;

  /// BlockNumber
  final int completedAt;

  /// V13MigrationInput<AccountId>
  final _i2.V13MigrationInput input;

  static const $V13CompletionCodec codec = $V13CompletionCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, dynamic> toJson() => {
    'migrationVersion': migrationVersion,
    'completedAt': completedAt,
    'input': input.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is V13Completion &&
          other.migrationVersion == migrationVersion &&
          other.completedAt == completedAt &&
          other.input == input;

  @override
  int get hashCode => Object.hash(migrationVersion, completedAt, input);
}

class $V13CompletionCodec with _i1.Codec<V13Completion> {
  const $V13CompletionCodec();

  @override
  void encodeTo(V13Completion obj, _i1.Output output) {
    _i1.U16Codec.codec.encodeTo(obj.migrationVersion, output);
    _i1.U32Codec.codec.encodeTo(obj.completedAt, output);
    _i2.V13MigrationInput.codec.encodeTo(obj.input, output);
  }

  @override
  V13Completion decode(_i1.Input input) {
    return V13Completion(
      migrationVersion: _i1.U16Codec.codec.decode(input),
      completedAt: _i1.U32Codec.codec.decode(input),
      input: _i2.V13MigrationInput.codec.decode(input),
    );
  }

  @override
  int sizeHint(V13Completion obj) {
    int size = 0;
    size = size + _i1.U16Codec.codec.sizeHint(obj.migrationVersion);
    size = size + _i1.U32Codec.codec.sizeHint(obj.completedAt);
    size = size + _i2.V13MigrationInput.codec.sizeHint(obj.input);
    return size;
  }
}
