// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i3;

import 'package:polkadart/scale_codec.dart' as _i1;
import 'package:quiver/collection.dart' as _i4;

import '../../../sp_core/crypto/account_id32.dart' as _i2;

class V13MigrationInput {
  const V13MigrationInput({
    required this.reconciliationVectorHash,
    required this.communityOnboardingDestination,
  });

  factory V13MigrationInput.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// [u8; 32]
  final List<int> reconciliationVectorHash;

  /// AccountId
  final _i2.AccountId32 communityOnboardingDestination;

  static const $V13MigrationInputCodec codec = $V13MigrationInputCodec();

  _i3.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, List<int>> toJson() => {
    'reconciliationVectorHash': reconciliationVectorHash.toList(),
    'communityOnboardingDestination': communityOnboardingDestination.toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is V13MigrationInput &&
          _i4.listsEqual(
            other.reconciliationVectorHash,
            reconciliationVectorHash,
          ) &&
          _i4.listsEqual(
            other.communityOnboardingDestination,
            communityOnboardingDestination,
          );

  @override
  int get hashCode =>
      Object.hash(reconciliationVectorHash, communityOnboardingDestination);
}

class $V13MigrationInputCodec with _i1.Codec<V13MigrationInput> {
  const $V13MigrationInputCodec();

  @override
  void encodeTo(V13MigrationInput obj, _i1.Output output) {
    const _i1.U8ArrayCodec(32).encodeTo(obj.reconciliationVectorHash, output);
    const _i1.U8ArrayCodec(
      32,
    ).encodeTo(obj.communityOnboardingDestination, output);
  }

  @override
  V13MigrationInput decode(_i1.Input input) {
    return V13MigrationInput(
      reconciliationVectorHash: const _i1.U8ArrayCodec(32).decode(input),
      communityOnboardingDestination: const _i1.U8ArrayCodec(32).decode(input),
    );
  }

  @override
  int sizeHint(V13MigrationInput obj) {
    int size = 0;
    size =
        size +
        const _i1.U8ArrayCodec(32).sizeHint(obj.reconciliationVectorHash);
    size =
        size +
        const _i2.AccountId32Codec().sizeHint(
          obj.communityOnboardingDestination,
        );
    return size;
  }
}
