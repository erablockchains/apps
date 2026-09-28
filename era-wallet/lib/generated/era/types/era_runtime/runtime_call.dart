// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

import '../era_v14_custody_governance/active/pallet/call.dart' as _i20;
import '../frame_system/pallet/call.dart' as _i3;
import '../pallet_ai_predictions/pallet/call.dart' as _i12;
import '../pallet_assets/pallet/call.dart' as _i16;
import '../pallet_babe/pallet/call.dart' as _i9;
import '../pallet_balances/pallet/call.dart' as _i5;
import '../pallet_era_worlds/pallet/call.dart' as _i18;
import '../pallet_grandpa/pallet/call.dart' as _i10;
import '../pallet_multisig/pallet/call.dart' as _i14;
import '../pallet_nfts/pallet/call.dart' as _i17;
import '../pallet_proxy/pallet/call.dart' as _i15;
import '../pallet_reward_reserve/pallet/call.dart' as _i13;
import '../pallet_security_budget/pallet/call.dart' as _i19;
import '../pallet_session/pallet/call.dart' as _i8;
import '../pallet_staking/pallet/pallet/call.dart' as _i7;
import '../pallet_sudo/pallet/call.dart' as _i6;
import '../pallet_timestamp/pallet/call.dart' as _i4;
import '../pallet_vesting/pallet/call.dart' as _i11;
import 'v14_allocator/pallet/call.dart' as _i23;
import 'v14_amm/pallet/call.dart' as _i21;
import 'v14_penalties/pallet/call.dart' as _i22;

abstract class RuntimeCall {
  const RuntimeCall();

  factory RuntimeCall.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $RuntimeCallCodec codec = $RuntimeCallCodec();

  static const $RuntimeCall values = $RuntimeCall();

  _i2.Uint8List encode() {
    final output = _i1.ByteOutput(codec.sizeHint(this));
    codec.encodeTo(this, output);
    return output.toBytes();
  }

  int sizeHint() {
    return codec.sizeHint(this);
  }

  Map<String, Map<String, dynamic>> toJson();
}

class $RuntimeCall {
  const $RuntimeCall();

  System system(_i3.Call value0) {
    return System(value0);
  }

  Timestamp timestamp(_i4.Call value0) {
    return Timestamp(value0);
  }

  Balances balances(_i5.Call value0) {
    return Balances(value0);
  }

  Sudo sudo(_i6.Call value0) {
    return Sudo(value0);
  }

  Staking staking(_i7.Call value0) {
    return Staking(value0);
  }

  Session session(_i8.Call value0) {
    return Session(value0);
  }

  Babe babe(_i9.Call value0) {
    return Babe(value0);
  }

  Grandpa grandpa(_i10.Call value0) {
    return Grandpa(value0);
  }

  Vesting vesting(_i11.Call value0) {
    return Vesting(value0);
  }

  AiPredictions aiPredictions(_i12.Call value0) {
    return AiPredictions(value0);
  }

  RewardReserve rewardReserve(_i13.Call value0) {
    return RewardReserve(value0);
  }

  Multisig multisig(_i14.Call value0) {
    return Multisig(value0);
  }

  Proxy proxy(_i15.Call value0) {
    return Proxy(value0);
  }

  Assets assets(_i16.Call value0) {
    return Assets(value0);
  }

  Nfts nfts(_i17.Call value0) {
    return Nfts(value0);
  }

  EraWorlds eraWorlds(_i18.Call value0) {
    return EraWorlds(value0);
  }

  SecurityBudget securityBudget(_i19.Call value0) {
    return SecurityBudget(value0);
  }

  FounderCustody founderCustody(_i20.Call value0) {
    return FounderCustody(value0);
  }

  Amm amm(_i21.Call value0) {
    return Amm(value0);
  }

  EquivocationPenalties equivocationPenalties(_i22.Call value0) {
    return EquivocationPenalties(value0);
  }

  EraV14AssetAllocator eraV14AssetAllocator(_i23.Call value0) {
    return EraV14AssetAllocator(value0);
  }
}

class $RuntimeCallCodec with _i1.Codec<RuntimeCall> {
  const $RuntimeCallCodec();

  @override
  RuntimeCall decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return System._decode(input);
      case 1:
        return Timestamp._decode(input);
      case 2:
        return Balances._decode(input);
      case 4:
        return Sudo._decode(input);
      case 10:
        return Staking._decode(input);
      case 5:
        return Session._decode(input);
      case 7:
        return Babe._decode(input);
      case 8:
        return Grandpa._decode(input);
      case 11:
        return Vesting._decode(input);
      case 12:
        return AiPredictions._decode(input);
      case 13:
        return RewardReserve._decode(input);
      case 14:
        return Multisig._decode(input);
      case 15:
        return Proxy._decode(input);
      case 16:
        return Assets._decode(input);
      case 17:
        return Nfts._decode(input);
      case 18:
        return EraWorlds._decode(input);
      case 20:
        return SecurityBudget._decode(input);
      case 22:
        return FounderCustody._decode(input);
      case 24:
        return Amm._decode(input);
      case 26:
        return EquivocationPenalties._decode(input);
      case 27:
        return EraV14AssetAllocator._decode(input);
      default:
        throw Exception('RuntimeCall: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(RuntimeCall value, _i1.Output output) {
    switch (value.runtimeType) {
      case System:
        (value as System).encodeTo(output);
        break;
      case Timestamp:
        (value as Timestamp).encodeTo(output);
        break;
      case Balances:
        (value as Balances).encodeTo(output);
        break;
      case Sudo:
        (value as Sudo).encodeTo(output);
        break;
      case Staking:
        (value as Staking).encodeTo(output);
        break;
      case Session:
        (value as Session).encodeTo(output);
        break;
      case Babe:
        (value as Babe).encodeTo(output);
        break;
      case Grandpa:
        (value as Grandpa).encodeTo(output);
        break;
      case Vesting:
        (value as Vesting).encodeTo(output);
        break;
      case AiPredictions:
        (value as AiPredictions).encodeTo(output);
        break;
      case RewardReserve:
        (value as RewardReserve).encodeTo(output);
        break;
      case Multisig:
        (value as Multisig).encodeTo(output);
        break;
      case Proxy:
        (value as Proxy).encodeTo(output);
        break;
      case Assets:
        (value as Assets).encodeTo(output);
        break;
      case Nfts:
        (value as Nfts).encodeTo(output);
        break;
      case EraWorlds:
        (value as EraWorlds).encodeTo(output);
        break;
      case SecurityBudget:
        (value as SecurityBudget).encodeTo(output);
        break;
      case FounderCustody:
        (value as FounderCustody).encodeTo(output);
        break;
      case Amm:
        (value as Amm).encodeTo(output);
        break;
      case EquivocationPenalties:
        (value as EquivocationPenalties).encodeTo(output);
        break;
      case EraV14AssetAllocator:
        (value as EraV14AssetAllocator).encodeTo(output);
        break;
      default:
        throw Exception(
          'RuntimeCall: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(RuntimeCall value) {
    switch (value.runtimeType) {
      case System:
        return (value as System)._sizeHint();
      case Timestamp:
        return (value as Timestamp)._sizeHint();
      case Balances:
        return (value as Balances)._sizeHint();
      case Sudo:
        return (value as Sudo)._sizeHint();
      case Staking:
        return (value as Staking)._sizeHint();
      case Session:
        return (value as Session)._sizeHint();
      case Babe:
        return (value as Babe)._sizeHint();
      case Grandpa:
        return (value as Grandpa)._sizeHint();
      case Vesting:
        return (value as Vesting)._sizeHint();
      case AiPredictions:
        return (value as AiPredictions)._sizeHint();
      case RewardReserve:
        return (value as RewardReserve)._sizeHint();
      case Multisig:
        return (value as Multisig)._sizeHint();
      case Proxy:
        return (value as Proxy)._sizeHint();
      case Assets:
        return (value as Assets)._sizeHint();
      case Nfts:
        return (value as Nfts)._sizeHint();
      case EraWorlds:
        return (value as EraWorlds)._sizeHint();
      case SecurityBudget:
        return (value as SecurityBudget)._sizeHint();
      case FounderCustody:
        return (value as FounderCustody)._sizeHint();
      case Amm:
        return (value as Amm)._sizeHint();
      case EquivocationPenalties:
        return (value as EquivocationPenalties)._sizeHint();
      case EraV14AssetAllocator:
        return (value as EraV14AssetAllocator)._sizeHint();
      default:
        throw Exception(
          'RuntimeCall: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class System extends RuntimeCall {
  const System(this.value0);

  factory System._decode(_i1.Input input) {
    return System(_i3.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<System, Runtime>
  final _i3.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'System': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i3.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is System && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Timestamp extends RuntimeCall {
  const Timestamp(this.value0);

  factory Timestamp._decode(_i1.Input input) {
    return Timestamp(_i4.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Timestamp, Runtime>
  final _i4.Call value0;

  @override
  Map<String, Map<String, Map<String, BigInt>>> toJson() => {
    'Timestamp': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i4.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(1, output);
    _i4.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Timestamp && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Balances extends RuntimeCall {
  const Balances(this.value0);

  factory Balances._decode(_i1.Input input) {
    return Balances(_i5.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Balances, Runtime>
  final _i5.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Balances': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i5.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i5.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Balances && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Sudo extends RuntimeCall {
  const Sudo(this.value0);

  factory Sudo._decode(_i1.Input input) {
    return Sudo(_i6.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Sudo, Runtime>
  final _i6.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Sudo': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i6.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i6.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Sudo && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Staking extends RuntimeCall {
  const Staking(this.value0);

  factory Staking._decode(_i1.Input input) {
    return Staking(_i7.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Staking, Runtime>
  final _i7.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Staking': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i7.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(10, output);
    _i7.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Staking && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Session extends RuntimeCall {
  const Session(this.value0);

  factory Session._decode(_i1.Input input) {
    return Session(_i8.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Session, Runtime>
  final _i8.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Session': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i8.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    _i8.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Babe extends RuntimeCall {
  const Babe(this.value0);

  factory Babe._decode(_i1.Input input) {
    return Babe(_i9.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Babe, Runtime>
  final _i9.Call value0;

  @override
  Map<String, Map<String, Map<String, Map<String, dynamic>>>> toJson() => {
    'Babe': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i9.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(7, output);
    _i9.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Babe && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Grandpa extends RuntimeCall {
  const Grandpa(this.value0);

  factory Grandpa._decode(_i1.Input input) {
    return Grandpa(_i10.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Grandpa, Runtime>
  final _i10.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Grandpa': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i10.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(8, output);
    _i10.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Grandpa && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Vesting extends RuntimeCall {
  const Vesting(this.value0);

  factory Vesting._decode(_i1.Input input) {
    return Vesting(_i11.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Vesting, Runtime>
  final _i11.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Vesting': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i11.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(11, output);
    _i11.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Vesting && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class AiPredictions extends RuntimeCall {
  const AiPredictions(this.value0);

  factory AiPredictions._decode(_i1.Input input) {
    return AiPredictions(_i12.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<AiPredictions, Runtime>
  final _i12.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'AiPredictions': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i12.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(12, output);
    _i12.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiPredictions && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class RewardReserve extends RuntimeCall {
  const RewardReserve(this.value0);

  factory RewardReserve._decode(_i1.Input input) {
    return RewardReserve(_i13.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<RewardReserve, Runtime>
  final _i13.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'RewardReserve': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i13.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(13, output);
    _i13.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardReserve && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Multisig extends RuntimeCall {
  const Multisig(this.value0);

  factory Multisig._decode(_i1.Input input) {
    return Multisig(_i14.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Multisig, Runtime>
  final _i14.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Multisig': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i14.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(14, output);
    _i14.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Multisig && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Proxy extends RuntimeCall {
  const Proxy(this.value0);

  factory Proxy._decode(_i1.Input input) {
    return Proxy(_i15.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Proxy, Runtime>
  final _i15.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Proxy': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i15.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(15, output);
    _i15.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Proxy && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Assets extends RuntimeCall {
  const Assets(this.value0);

  factory Assets._decode(_i1.Input input) {
    return Assets(_i16.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Assets, Runtime>
  final _i16.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Assets': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i16.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(16, output);
    _i16.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Assets && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Nfts extends RuntimeCall {
  const Nfts(this.value0);

  factory Nfts._decode(_i1.Input input) {
    return Nfts(_i17.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Nfts, Runtime>
  final _i17.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Nfts': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i17.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(17, output);
    _i17.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Nfts && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class EraWorlds extends RuntimeCall {
  const EraWorlds(this.value0);

  factory EraWorlds._decode(_i1.Input input) {
    return EraWorlds(_i18.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<EraWorlds, Runtime>
  final _i18.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'EraWorlds': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i18.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(18, output);
    _i18.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EraWorlds && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class SecurityBudget extends RuntimeCall {
  const SecurityBudget(this.value0);

  factory SecurityBudget._decode(_i1.Input input) {
    return SecurityBudget(_i19.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<SecurityBudget, Runtime>
  final _i19.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {
    'SecurityBudget': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i19.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(20, output);
    _i19.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityBudget && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class FounderCustody extends RuntimeCall {
  const FounderCustody(this.value0);

  factory FounderCustody._decode(_i1.Input input) {
    return FounderCustody(_i20.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<FounderCustody, Runtime>
  final _i20.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'FounderCustody': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i20.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(22, output);
    _i20.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FounderCustody && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Amm extends RuntimeCall {
  const Amm(this.value0);

  factory Amm._decode(_i1.Input input) {
    return Amm(_i21.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<Amm, Runtime>
  final _i21.Call value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Amm': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i21.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(24, output);
    _i21.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Amm && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class EquivocationPenalties extends RuntimeCall {
  const EquivocationPenalties(this.value0);

  factory EquivocationPenalties._decode(_i1.Input input) {
    return EquivocationPenalties(_i22.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<EquivocationPenalties, Runtime>
  final _i22.Call value0;

  @override
  Map<String, Map<String, Map<String, int>>> toJson() => {
    'EquivocationPenalties': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i22.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(26, output);
    _i22.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquivocationPenalties && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class EraV14AssetAllocator extends RuntimeCall {
  const EraV14AssetAllocator(this.value0);

  factory EraV14AssetAllocator._decode(_i1.Input input) {
    return EraV14AssetAllocator(_i23.Call.codec.decode(input));
  }

  /// self::sp_api_hidden_includes_construct_runtime::hidden_include::dispatch
  ///::CallableCallFor<EraV14AssetAllocator, Runtime>
  final _i23.Call value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'EraV14AssetAllocator': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i23.Call.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(27, output);
    _i23.Call.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraV14AssetAllocator && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}
