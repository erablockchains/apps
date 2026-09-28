import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:era_wallet/config.dart';
import 'package:era_wallet/era_v14_compatibility.dart';
import 'package:era_wallet/generated/era/era.dart' as era_api;
import 'package:polkadart/polkadart.dart';
import 'package:polkadart/scale_codec.dart' show decodeHex;

Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 || arguments.single != '--live') {
    throw ArgumentError(
      'The read-only live gate requires exactly: '
      'dart run tool/era_v14_live_gate.dart --live',
    );
  }

  final provider = Provider.fromUri(
    validateEraWsEndpoint(kOfficialEraWsEndpoint),
  );
  try {
    final compatibility = await EraV14RuntimeGuard(provider).verify();
    final api = era_api.Era(provider);
    final finalizedAt = _decodeHash(compatibility.finalizedHead);
    final validatorCount = await api.query.staking.validatorCount(
      at: finalizedAt,
    );
    final validators = await api.query.session.validators(at: finalizedAt);
    final minValidatorBond = await api.query.staking.minValidatorBond(
      at: finalizedAt,
    );
    final currentEra = await api.query.staking.currentEra(at: finalizedAt);
    final activeEra = await api.query.staking.activeEra(at: finalizedAt);
    if (currentEra == null || activeEra == null) {
      throw StateError('Staking era progression is unavailable.');
    }

    final firstCompletedEra = activeEra.index - 1;
    final completedEras = <Map<String, Object?>>[];
    for (
      var era = firstCompletedEra;
      era >= 0 && era > firstCompletedEra - 4;
      era--
    ) {
      final reward = await api.query.staking.erasValidatorReward(
        era,
        at: finalizedAt,
      );
      final points = await api.query.staking.erasRewardPoints(
        era,
        at: finalizedAt,
      );
      completedEras.add({
        'era': era,
        'validatorRewardBaseUnits': (reward ?? BigInt.zero).toString(),
        'authoredRewardPoints': points.total,
      });
    }

    if (validatorCount != 4 || validators.length != 4) {
      throw StateError(
        'Expected four selected validators, observed configured='
        '$validatorCount/session=${validators.length}.',
      );
    }
    final expectedMinValidatorBond =
        BigInt.from(10000) * BigInt.from(10).pow(kEraTokenDecimals);
    if (minValidatorBond != expectedMinValidatorBond) {
      throw StateError(
        'MinValidatorBond is $minValidatorBond; expected the V14 '
        '10,000 ETKN threshold $expectedMinValidatorBond.',
      );
    }
    if (completedEras.any(
      (entry) => entry['validatorRewardBaseUnits'] != '0',
    )) {
      throw StateError('A completed-era validator reward is non-zero.');
    }

    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'endpoint': kOfficialEraWsEndpoint,
        'chainName': compatibility.identity.chainName,
        'genesisHash': compatibility.identity.genesisHash,
        'specName': compatibility.identity.specName,
        'specVersion': compatibility.identity.specVersion,
        'transactionVersion': compatibility.identity.transactionVersion,
        'tokenSymbol': compatibility.identity.tokenSymbol,
        'tokenDecimals': compatibility.identity.tokenDecimals,
        'ss58Prefix': compatibility.identity.ss58Prefix,
        'metadataVersion': compatibility.metadata.version,
        'metadataSha256': compatibility.metadata.sha256,
        'finalizedHead': compatibility.finalizedHead,
        'configuredValidatorCount': validatorCount,
        'selectedValidators': validators.length,
        'minValidatorBondBaseUnits': minValidatorBond.toString(),
        'currentEra': currentEra,
        'activeEra': activeEra.index,
        'completedEras': completedEras,
        'eraPayoutConfiguration': '()',
        'chainActions': 0,
      }),
    );
  } finally {
    if (provider.isConnected()) await provider.disconnect();
  }
}

Uint8List _decodeHash(String value) {
  final normalized = value.replaceFirst(RegExp(r'^0x'), '');
  return Uint8List.fromList(decodeHex(normalized));
}
