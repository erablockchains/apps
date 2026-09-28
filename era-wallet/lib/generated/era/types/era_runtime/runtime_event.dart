// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:typed_data' as _i2;

import 'package:polkadart/scale_codec.dart' as _i1;

import '../era_v14_custody_governance/active/pallet/event.dart' as _i22;
import '../era_validator_security/observation/pallet/event.dart' as _i21;
import '../frame_system/pallet/event.dart' as _i3;
import '../pallet_ai_predictions/pallet/event.dart' as _i12;
import '../pallet_assets/pallet/event.dart' as _i16;
import '../pallet_balances/pallet/event.dart' as _i4;
import '../pallet_era_worlds/pallet/event.dart' as _i18;
import '../pallet_grandpa/pallet/event.dart' as _i10;
import '../pallet_multisig/pallet/event.dart' as _i14;
import '../pallet_nfts/pallet/event.dart' as _i17;
import '../pallet_proxy/pallet/event.dart' as _i15;
import '../pallet_reward_reserve/pallet/event.dart' as _i13;
import '../pallet_security_budget/pallet/event.dart' as _i20;
import '../pallet_session/historical/pallet/event.dart' as _i9;
import '../pallet_session/pallet/event.dart' as _i8;
import '../pallet_staking/pallet/pallet/event.dart' as _i7;
import '../pallet_sudo/pallet/event.dart' as _i6;
import '../pallet_transaction_payment/pallet/event.dart' as _i5;
import '../pallet_vesting/pallet/event.dart' as _i11;
import 'issuance_cap/pallet/event.dart' as _i19;
import 'v14_allocator/pallet/event.dart' as _i25;
import 'v14_amm/pallet/event.dart' as _i23;
import 'v14_penalties/pallet/event.dart' as _i24;

abstract class RuntimeEvent {
  const RuntimeEvent();

  factory RuntimeEvent.decode(_i1.Input input) {
    return codec.decode(input);
  }

  static const $RuntimeEventCodec codec = $RuntimeEventCodec();

  static const $RuntimeEvent values = $RuntimeEvent();

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

class $RuntimeEvent {
  const $RuntimeEvent();

  System system(_i3.Event value0) {
    return System(value0);
  }

  Balances balances(_i4.Event value0) {
    return Balances(value0);
  }

  TransactionPayment transactionPayment(_i5.Event value0) {
    return TransactionPayment(value0);
  }

  Sudo sudo(_i6.Event value0) {
    return Sudo(value0);
  }

  Staking staking(_i7.Event value0) {
    return Staking(value0);
  }

  Session session(_i8.Event value0) {
    return Session(value0);
  }

  Historical historical(_i9.Event value0) {
    return Historical(value0);
  }

  Grandpa grandpa(_i10.Event value0) {
    return Grandpa(value0);
  }

  Vesting vesting(_i11.Event value0) {
    return Vesting(value0);
  }

  AiPredictions aiPredictions(_i12.Event value0) {
    return AiPredictions(value0);
  }

  RewardReserve rewardReserve(_i13.Event value0) {
    return RewardReserve(value0);
  }

  Multisig multisig(_i14.Event value0) {
    return Multisig(value0);
  }

  Proxy proxy(_i15.Event value0) {
    return Proxy(value0);
  }

  Assets assets(_i16.Event value0) {
    return Assets(value0);
  }

  Nfts nfts(_i17.Event value0) {
    return Nfts(value0);
  }

  EraWorlds eraWorlds(_i18.Event value0) {
    return EraWorlds(value0);
  }

  IssuanceCap issuanceCap(_i19.Event value0) {
    return IssuanceCap(value0);
  }

  SecurityBudget securityBudget(_i20.Event value0) {
    return SecurityBudget(value0);
  }

  ValidatorSecurity validatorSecurity(_i21.Event value0) {
    return ValidatorSecurity(value0);
  }

  FounderCustody founderCustody(_i22.Event value0) {
    return FounderCustody(value0);
  }

  Amm amm(_i23.Event value0) {
    return Amm(value0);
  }

  EquivocationPenalties equivocationPenalties(_i24.Event value0) {
    return EquivocationPenalties(value0);
  }

  EraV14AssetAllocator eraV14AssetAllocator(_i25.Event value0) {
    return EraV14AssetAllocator(value0);
  }
}

class $RuntimeEventCodec with _i1.Codec<RuntimeEvent> {
  const $RuntimeEventCodec();

  @override
  RuntimeEvent decode(_i1.Input input) {
    final index = _i1.U8Codec.codec.decode(input);
    switch (index) {
      case 0:
        return System._decode(input);
      case 2:
        return Balances._decode(input);
      case 3:
        return TransactionPayment._decode(input);
      case 4:
        return Sudo._decode(input);
      case 10:
        return Staking._decode(input);
      case 5:
        return Session._decode(input);
      case 6:
        return Historical._decode(input);
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
      case 19:
        return IssuanceCap._decode(input);
      case 20:
        return SecurityBudget._decode(input);
      case 21:
        return ValidatorSecurity._decode(input);
      case 22:
        return FounderCustody._decode(input);
      case 24:
        return Amm._decode(input);
      case 26:
        return EquivocationPenalties._decode(input);
      case 27:
        return EraV14AssetAllocator._decode(input);
      default:
        throw Exception('RuntimeEvent: Invalid variant index: "$index"');
    }
  }

  @override
  void encodeTo(RuntimeEvent value, _i1.Output output) {
    switch (value.runtimeType) {
      case System:
        (value as System).encodeTo(output);
        break;
      case Balances:
        (value as Balances).encodeTo(output);
        break;
      case TransactionPayment:
        (value as TransactionPayment).encodeTo(output);
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
      case Historical:
        (value as Historical).encodeTo(output);
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
      case IssuanceCap:
        (value as IssuanceCap).encodeTo(output);
        break;
      case SecurityBudget:
        (value as SecurityBudget).encodeTo(output);
        break;
      case ValidatorSecurity:
        (value as ValidatorSecurity).encodeTo(output);
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
          'RuntimeEvent: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }

  @override
  int sizeHint(RuntimeEvent value) {
    switch (value.runtimeType) {
      case System:
        return (value as System)._sizeHint();
      case Balances:
        return (value as Balances)._sizeHint();
      case TransactionPayment:
        return (value as TransactionPayment)._sizeHint();
      case Sudo:
        return (value as Sudo)._sizeHint();
      case Staking:
        return (value as Staking)._sizeHint();
      case Session:
        return (value as Session)._sizeHint();
      case Historical:
        return (value as Historical)._sizeHint();
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
      case IssuanceCap:
        return (value as IssuanceCap)._sizeHint();
      case SecurityBudget:
        return (value as SecurityBudget)._sizeHint();
      case ValidatorSecurity:
        return (value as ValidatorSecurity)._sizeHint();
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
          'RuntimeEvent: Unsupported "$value" of type "${value.runtimeType}"',
        );
    }
  }
}

class System extends RuntimeEvent {
  const System(this.value0);

  factory System._decode(_i1.Input input) {
    return System(_i3.Event.codec.decode(input));
  }

  /// frame_system::Event<Runtime>
  final _i3.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'System': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i3.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(0, output);
    _i3.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is System && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Balances extends RuntimeEvent {
  const Balances(this.value0);

  factory Balances._decode(_i1.Input input) {
    return Balances(_i4.Event.codec.decode(input));
  }

  /// pallet_balances::Event<Runtime>
  final _i4.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Balances': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i4.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(2, output);
    _i4.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Balances && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class TransactionPayment extends RuntimeEvent {
  const TransactionPayment(this.value0);

  factory TransactionPayment._decode(_i1.Input input) {
    return TransactionPayment(_i5.Event.codec.decode(input));
  }

  /// pallet_transaction_payment::Event<Runtime>
  final _i5.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'TransactionPayment': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i5.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(3, output);
    _i5.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionPayment && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Sudo extends RuntimeEvent {
  const Sudo(this.value0);

  factory Sudo._decode(_i1.Input input) {
    return Sudo(_i6.Event.codec.decode(input));
  }

  /// pallet_sudo::Event<Runtime>
  final _i6.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Sudo': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i6.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(4, output);
    _i6.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Sudo && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Staking extends RuntimeEvent {
  const Staking(this.value0);

  factory Staking._decode(_i1.Input input) {
    return Staking(_i7.Event.codec.decode(input));
  }

  /// pallet_staking::Event<Runtime>
  final _i7.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Staking': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i7.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(10, output);
    _i7.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Staking && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Session extends RuntimeEvent {
  const Session(this.value0);

  factory Session._decode(_i1.Input input) {
    return Session(_i8.Event.codec.decode(input));
  }

  /// pallet_session::Event<Runtime>
  final _i8.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Session': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i8.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(5, output);
    _i8.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Session && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Historical extends RuntimeEvent {
  const Historical(this.value0);

  factory Historical._decode(_i1.Input input) {
    return Historical(_i9.Event.codec.decode(input));
  }

  /// pallet_session::historical::Event<Runtime>
  final _i9.Event value0;

  @override
  Map<String, Map<String, Map<String, int>>> toJson() => {
    'Historical': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i9.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(6, output);
    _i9.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Historical && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Grandpa extends RuntimeEvent {
  const Grandpa(this.value0);

  factory Grandpa._decode(_i1.Input input) {
    return Grandpa(_i10.Event.codec.decode(input));
  }

  /// pallet_grandpa::Event
  final _i10.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'Grandpa': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i10.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(8, output);
    _i10.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Grandpa && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Vesting extends RuntimeEvent {
  const Vesting(this.value0);

  factory Vesting._decode(_i1.Input input) {
    return Vesting(_i11.Event.codec.decode(input));
  }

  /// pallet_vesting::Event<Runtime>
  final _i11.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Vesting': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i11.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(11, output);
    _i11.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Vesting && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class AiPredictions extends RuntimeEvent {
  const AiPredictions(this.value0);

  factory AiPredictions._decode(_i1.Input input) {
    return AiPredictions(_i12.Event.codec.decode(input));
  }

  /// pallet_ai_predictions::Event<Runtime>
  final _i12.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'AiPredictions': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i12.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(12, output);
    _i12.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiPredictions && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class RewardReserve extends RuntimeEvent {
  const RewardReserve(this.value0);

  factory RewardReserve._decode(_i1.Input input) {
    return RewardReserve(_i13.Event.codec.decode(input));
  }

  /// pallet_reward_reserve::Event<Runtime>
  final _i13.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'RewardReserve': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i13.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(13, output);
    _i13.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RewardReserve && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Multisig extends RuntimeEvent {
  const Multisig(this.value0);

  factory Multisig._decode(_i1.Input input) {
    return Multisig(_i14.Event.codec.decode(input));
  }

  /// pallet_multisig::Event<Runtime>
  final _i14.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Multisig': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i14.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(14, output);
    _i14.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Multisig && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Proxy extends RuntimeEvent {
  const Proxy(this.value0);

  factory Proxy._decode(_i1.Input input) {
    return Proxy(_i15.Event.codec.decode(input));
  }

  /// pallet_proxy::Event<Runtime>
  final _i15.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Proxy': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i15.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(15, output);
    _i15.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Proxy && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Assets extends RuntimeEvent {
  const Assets(this.value0);

  factory Assets._decode(_i1.Input input) {
    return Assets(_i16.Event.codec.decode(input));
  }

  /// pallet_assets::Event<Runtime>
  final _i16.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Assets': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i16.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(16, output);
    _i16.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Assets && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Nfts extends RuntimeEvent {
  const Nfts(this.value0);

  factory Nfts._decode(_i1.Input input) {
    return Nfts(_i17.Event.codec.decode(input));
  }

  /// pallet_nfts::Event<Runtime>
  final _i17.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Nfts': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i17.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(17, output);
    _i17.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Nfts && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class EraWorlds extends RuntimeEvent {
  const EraWorlds(this.value0);

  factory EraWorlds._decode(_i1.Input input) {
    return EraWorlds(_i18.Event.codec.decode(input));
  }

  /// pallet_era_worlds::Event<Runtime>
  final _i18.Event value0;

  @override
  Map<String, Map<String, dynamic>> toJson() => {'EraWorlds': value0.toJson()};

  int _sizeHint() {
    int size = 1;
    size = size + _i18.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(18, output);
    _i18.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is EraWorlds && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class IssuanceCap extends RuntimeEvent {
  const IssuanceCap(this.value0);

  factory IssuanceCap._decode(_i1.Input input) {
    return IssuanceCap(_i19.Event.codec.decode(input));
  }

  /// issuance_cap::Event<Runtime>
  final _i19.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'IssuanceCap': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i19.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(19, output);
    _i19.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is IssuanceCap && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class SecurityBudget extends RuntimeEvent {
  const SecurityBudget(this.value0);

  factory SecurityBudget._decode(_i1.Input input) {
    return SecurityBudget(_i20.Event.codec.decode(input));
  }

  /// pallet_security_budget::Event<Runtime>
  final _i20.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'SecurityBudget': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i20.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(20, output);
    _i20.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SecurityBudget && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class ValidatorSecurity extends RuntimeEvent {
  const ValidatorSecurity(this.value0);

  factory ValidatorSecurity._decode(_i1.Input input) {
    return ValidatorSecurity(_i21.Event.codec.decode(input));
  }

  /// era_validator_security::observation::Event<Runtime>
  final _i21.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'ValidatorSecurity': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i21.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(21, output);
    _i21.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ValidatorSecurity && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class FounderCustody extends RuntimeEvent {
  const FounderCustody(this.value0);

  factory FounderCustody._decode(_i1.Input input) {
    return FounderCustody(_i22.Event.codec.decode(input));
  }

  /// era_v14_custody_governance::Event<Runtime>
  final _i22.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'FounderCustody': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i22.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(22, output);
    _i22.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FounderCustody && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class Amm extends RuntimeEvent {
  const Amm(this.value0);

  factory Amm._decode(_i1.Input input) {
    return Amm(_i23.Event.codec.decode(input));
  }

  /// v14_amm::Event<Runtime>
  final _i23.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'Amm': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i23.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(24, output);
    _i23.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Amm && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class EquivocationPenalties extends RuntimeEvent {
  const EquivocationPenalties(this.value0);

  factory EquivocationPenalties._decode(_i1.Input input) {
    return EquivocationPenalties(_i24.Event.codec.decode(input));
  }

  /// v14_penalties::Event<Runtime>
  final _i24.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'EquivocationPenalties': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i24.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(26, output);
    _i24.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EquivocationPenalties && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}

class EraV14AssetAllocator extends RuntimeEvent {
  const EraV14AssetAllocator(this.value0);

  factory EraV14AssetAllocator._decode(_i1.Input input) {
    return EraV14AssetAllocator(_i25.Event.codec.decode(input));
  }

  /// v14_allocator::Event<Runtime>
  final _i25.Event value0;

  @override
  Map<String, Map<String, Map<String, dynamic>>> toJson() => {
    'EraV14AssetAllocator': value0.toJson(),
  };

  int _sizeHint() {
    int size = 1;
    size = size + _i25.Event.codec.sizeHint(value0);
    return size;
  }

  void encodeTo(_i1.Output output) {
    _i1.U8Codec.codec.encodeTo(27, output);
    _i25.Event.codec.encodeTo(value0, output);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EraV14AssetAllocator && other.value0 == value0;

  @override
  int get hashCode => value0.hashCode;
}
