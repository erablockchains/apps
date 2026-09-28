// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i29;

import 'package:polkadart/polkadart.dart' as _i1;

import 'pallets/ai_predictions.dart' as _i13;
import 'pallets/amm.dart' as _i25;
import 'pallets/assets.dart' as _i17;
import 'pallets/authorship.dart' as _i11;
import 'pallets/babe.dart' as _i9;
import 'pallets/balances.dart' as _i4;
import 'pallets/equivocation_penalties.dart' as _i27;
import 'pallets/era_v14_amm.dart' as _i26;
import 'pallets/era_v14_asset_allocator.dart' as _i28;
import 'pallets/era_worlds.dart' as _i19;
import 'pallets/founder_custody.dart' as _i23;
import 'pallets/fresh_genesis.dart' as _i24;
import 'pallets/grandpa.dart' as _i10;
import 'pallets/issuance_cap.dart' as _i20;
import 'pallets/multisig.dart' as _i15;
import 'pallets/nfts.dart' as _i18;
import 'pallets/proxy.dart' as _i16;
import 'pallets/reward_reserve.dart' as _i14;
import 'pallets/security_budget.dart' as _i21;
import 'pallets/session.dart' as _i8;
import 'pallets/staking.dart' as _i7;
import 'pallets/sudo.dart' as _i6;
import 'pallets/system.dart' as _i2;
import 'pallets/timestamp.dart' as _i3;
import 'pallets/transaction_payment.dart' as _i5;
import 'pallets/validator_security.dart' as _i22;
import 'pallets/vesting.dart' as _i12;

class Queries {
  Queries(_i1.StateApi api)
    : system = _i2.Queries(api),
      timestamp = _i3.Queries(api),
      balances = _i4.Queries(api),
      transactionPayment = _i5.Queries(api),
      sudo = _i6.Queries(api),
      staking = _i7.Queries(api),
      session = _i8.Queries(api),
      babe = _i9.Queries(api),
      grandpa = _i10.Queries(api),
      authorship = _i11.Queries(api),
      vesting = _i12.Queries(api),
      aiPredictions = _i13.Queries(api),
      rewardReserve = _i14.Queries(api),
      multisig = _i15.Queries(api),
      proxy = _i16.Queries(api),
      assets = _i17.Queries(api),
      nfts = _i18.Queries(api),
      eraWorlds = _i19.Queries(api),
      issuanceCap = _i20.Queries(api),
      securityBudget = _i21.Queries(api),
      validatorSecurity = _i22.Queries(api),
      founderCustody = _i23.Queries(api),
      freshGenesis = _i24.Queries(api),
      amm = _i25.Queries(api),
      eraV14Amm = _i26.Queries(api),
      equivocationPenalties = _i27.Queries(api),
      eraV14AssetAllocator = _i28.Queries(api);

  final _i2.Queries system;

  final _i3.Queries timestamp;

  final _i4.Queries balances;

  final _i5.Queries transactionPayment;

  final _i6.Queries sudo;

  final _i7.Queries staking;

  final _i8.Queries session;

  final _i9.Queries babe;

  final _i10.Queries grandpa;

  final _i11.Queries authorship;

  final _i12.Queries vesting;

  final _i13.Queries aiPredictions;

  final _i14.Queries rewardReserve;

  final _i15.Queries multisig;

  final _i16.Queries proxy;

  final _i17.Queries assets;

  final _i18.Queries nfts;

  final _i19.Queries eraWorlds;

  final _i20.Queries issuanceCap;

  final _i21.Queries securityBudget;

  final _i22.Queries validatorSecurity;

  final _i23.Queries founderCustody;

  final _i24.Queries freshGenesis;

  final _i25.Queries amm;

  final _i26.Queries eraV14Amm;

  final _i27.Queries equivocationPenalties;

  final _i28.Queries eraV14AssetAllocator;
}

class Extrinsics {
  Extrinsics();

  final _i2.Txs system = _i2.Txs();

  final _i3.Txs timestamp = _i3.Txs();

  final _i4.Txs balances = _i4.Txs();

  final _i6.Txs sudo = _i6.Txs();

  final _i7.Txs staking = _i7.Txs();

  final _i8.Txs session = _i8.Txs();

  final _i9.Txs babe = _i9.Txs();

  final _i10.Txs grandpa = _i10.Txs();

  final _i12.Txs vesting = _i12.Txs();

  final _i13.Txs aiPredictions = _i13.Txs();

  final _i14.Txs rewardReserve = _i14.Txs();

  final _i15.Txs multisig = _i15.Txs();

  final _i16.Txs proxy = _i16.Txs();

  final _i17.Txs assets = _i17.Txs();

  final _i18.Txs nfts = _i18.Txs();

  final _i19.Txs eraWorlds = _i19.Txs();

  final _i21.Txs securityBudget = _i21.Txs();

  final _i23.Txs founderCustody = _i23.Txs();

  final _i25.Txs amm = _i25.Txs();

  final _i27.Txs equivocationPenalties = _i27.Txs();

  final _i28.Txs eraV14AssetAllocator = _i28.Txs();
}

class Constants {
  Constants();

  final _i2.Constants system = _i2.Constants();

  final _i3.Constants timestamp = _i3.Constants();

  final _i4.Constants balances = _i4.Constants();

  final _i5.Constants transactionPayment = _i5.Constants();

  final _i7.Constants staking = _i7.Constants();

  final _i9.Constants babe = _i9.Constants();

  final _i10.Constants grandpa = _i10.Constants();

  final _i12.Constants vesting = _i12.Constants();

  final _i13.Constants aiPredictions = _i13.Constants();

  final _i14.Constants rewardReserve = _i14.Constants();

  final _i15.Constants multisig = _i15.Constants();

  final _i16.Constants proxy = _i16.Constants();

  final _i17.Constants assets = _i17.Constants();

  final _i18.Constants nfts = _i18.Constants();

  final _i19.Constants eraWorlds = _i19.Constants();

  final _i21.Constants securityBudget = _i21.Constants();

  final _i22.Constants validatorSecurity = _i22.Constants();

  final _i23.Constants founderCustody = _i23.Constants();
}

class Rpc {
  const Rpc({required this.state, required this.system});

  final _i1.StateApi state;

  final _i1.SystemApi system;
}

class Registry {
  Registry();

  final int extrinsicVersion = 4;

  List getSignedExtensionTypes() {
    return ['CheckMortality', 'CheckNonce', 'ChargeTransactionPayment'];
  }

  List getSignedExtensionExtra() {
    return [
      'CheckSpecVersion',
      'CheckTxVersion',
      'CheckGenesis',
      'CheckMortality',
    ];
  }
}

class Era {
  Era._(this._provider, this.rpc)
    : query = Queries(rpc.state),
      constant = Constants(),
      tx = Extrinsics(),
      registry = Registry();

  factory Era(_i1.Provider provider) {
    final rpc = Rpc(
      state: _i1.StateApi(provider),
      system: _i1.SystemApi(provider),
    );
    return Era._(provider, rpc);
  }

  factory Era.url(Uri url) {
    final provider = _i1.Provider.fromUri(url);
    return Era(provider);
  }

  final _i1.Provider _provider;

  final Queries query;

  final Constants constant;

  final Rpc rpc;

  final Extrinsics tx;

  final Registry registry;

  _i29.Future connect() async {
    return await _provider.connect();
  }

  _i29.Future disconnect() async {
    return await _provider.disconnect();
  }
}
