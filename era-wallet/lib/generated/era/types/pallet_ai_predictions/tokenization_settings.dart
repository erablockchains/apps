// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

class TokenizationSettings {
  const TokenizationSettings({
    required this.tokenizationEnabled,
    required this.transfersEnabled,
  });

  factory TokenizationSettings.decode(_i1.Input input) {
    return codec.decode(input);
  }

  /// bool
  final bool tokenizationEnabled;

  /// bool
  final bool transfersEnabled;

  static const $TokenizationSettingsCodec codec = $TokenizationSettingsCodec();

  _i2.Uint8List encode() {
    return codec.encode(this);
  }

  Map<String, bool> toJson() => {
    'tokenizationEnabled': tokenizationEnabled,
    'transfersEnabled': transfersEnabled,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TokenizationSettings &&
          other.tokenizationEnabled == tokenizationEnabled &&
          other.transfersEnabled == transfersEnabled;

  @override
  int get hashCode => Object.hash(tokenizationEnabled, transfersEnabled);
}

class $TokenizationSettingsCodec with _i1.Codec<TokenizationSettings> {
  const $TokenizationSettingsCodec();

  @override
  void encodeTo(TokenizationSettings obj, _i1.Output output) {
    _i1.BoolCodec.codec.encodeTo(obj.tokenizationEnabled, output);
    _i1.BoolCodec.codec.encodeTo(obj.transfersEnabled, output);
  }

  @override
  TokenizationSettings decode(_i1.Input input) {
    return TokenizationSettings(
      tokenizationEnabled: _i1.BoolCodec.codec.decode(input),
      transfersEnabled: _i1.BoolCodec.codec.decode(input),
    );
  }

  @override
  int sizeHint(TokenizationSettings obj) {
    int size = 0;
    size = size + _i1.BoolCodec.codec.sizeHint(obj.tokenizationEnabled);
    size = size + _i1.BoolCodec.codec.sizeHint(obj.transfersEnabled);
    return size;
  }
}
