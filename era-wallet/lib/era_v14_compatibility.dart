import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' show decodeHex;
import 'package:substrate_metadata/substrate_metadata.dart';

const String kEraPublicName = 'ERA';
// Exact value returned by system_chain on the deployed production network.
// User-facing copy may still describe this network as ERA-MAINNET.
const String kEraChainDisplayName = 'ERA';
const String kEraGenesisHash =
    '0x0abc2c3d8db5815541050b73da4d81267ebf14d90dbee8d7258155b667ea112e';
const String kEraSpecName = 'era';
const int kEraSpecVersion = 16;
const int kEraTransactionVersion = 1;
const String kEraTokenSymbol = 'ETKN';
const int kEraTokenDecimals = 18;
const int kEraSs58Prefix = 42;
const int kEraMetadataVersion = 14;
const String kEraMetadataSha256 =
    '574931f693241cb62e1ad2990eda55e2250c36c9c0de852b0380eac480c8496a';
const String kEraRuntimeWasmSha256 =
    'bc0085ce268f447760403a3049c9e9e64b0150bdd79c0ee20490f6fab36b2b85';

const String kEraStakingRewardNotice =
    'ERA staking, nomination and validator selection are active. V14 rewards '
    'use the custom SecurityBudget reward-page route. A claim is never '
    'submitted automatically and must pass the finalized eligibility checks.';

const String kEraPlannedValidatorThresholdNotice =
    'Reward eligibility is determined from finalized V14 SecurityBudget and '
    'staking state. Eligibility does not guarantee an active validator seat.';

class EraV14CompatibilityException implements Exception {
  final String message;

  const EraV14CompatibilityException(this.message);

  @override
  String toString() => 'ERA V14 compatibility check failed: $message';
}

class EraV14RuntimeIdentity {
  final String chainName;
  final String genesisHash;
  final String specName;
  final int specVersion;
  final int transactionVersion;
  final String tokenSymbol;
  final int tokenDecimals;
  final int ss58Prefix;

  const EraV14RuntimeIdentity({
    required this.chainName,
    required this.genesisHash,
    required this.specName,
    required this.specVersion,
    required this.transactionVersion,
    required this.tokenSymbol,
    required this.tokenDecimals,
    required this.ss58Prefix,
  });

  void verify() {
    final mismatches = <String>[];
    if (chainName != kEraChainDisplayName) {
      mismatches.add('chain=$chainName');
    }
    if (_normalizeHash(genesisHash) != _normalizeHash(kEraGenesisHash)) {
      mismatches.add('genesis=$genesisHash');
    }
    if (specName != kEraSpecName) mismatches.add('specName=$specName');
    if (specVersion != kEraSpecVersion) {
      mismatches.add('specVersion=$specVersion');
    }
    if (transactionVersion != kEraTransactionVersion) {
      mismatches.add('transactionVersion=$transactionVersion');
    }
    if (tokenSymbol != kEraTokenSymbol) {
      mismatches.add('tokenSymbol=$tokenSymbol');
    }
    if (tokenDecimals != kEraTokenDecimals) {
      mismatches.add('tokenDecimals=$tokenDecimals');
    }
    if (ss58Prefix != kEraSs58Prefix) {
      mismatches.add('ss58Prefix=$ss58Prefix');
    }
    if (mismatches.isNotEmpty) {
      throw EraV14CompatibilityException(
        'the connected network is unsupported (${mismatches.join(', ')}).',
      );
    }
  }
}

class EraV14MetadataSurface {
  final int version;
  final String sha256;
  final Map<String, Set<String>> calls;
  final Map<String, Set<String>> storage;

  EraV14MetadataSurface({
    required this.version,
    required this.sha256,
    required Map<String, Set<String>> calls,
    required Map<String, Set<String>> storage,
  }) : calls = Map.unmodifiable({
         for (final entry in calls.entries)
           entry.key: Set.unmodifiable(entry.value),
       }),
       storage = Map.unmodifiable({
         for (final entry in storage.entries)
           entry.key: Set.unmodifiable(entry.value),
       });
}

class EraV14CompatibilitySnapshot {
  final String finalizedHead;
  final EraV14RuntimeIdentity identity;
  final EraV14MetadataSurface metadata;

  const EraV14CompatibilitySnapshot({
    required this.finalizedHead,
    required this.identity,
    required this.metadata,
  });
}

class EraV14RuntimeGuard {
  static const Map<String, Set<String>> requiredCalls = {
    'Balances': {'transfer_allow_death', 'transfer_keep_alive'},
    'Staking': {
      'bond',
      'bond_extra',
      'nominate',
      'unbond',
      'withdraw_unbonded',
    },
    'AiPredictions': {
      'register_model',
      'approve_model',
      'suspend_model',
      'reject_model',
      'set_model_submitter',
      'submit_prediction',
      'tokenize_prediction',
      'validate_prediction',
      'close_prediction',
      'stake_on_prediction_outcome_side',
      'unstake_from_prediction_outcome_side',
      'propose_prediction_outcome',
      'finalize_prediction_outcome_after_dispute_window',
      'admin_finalize_prediction_outcome',
      'claim_prediction_market_payout',
    },
    'Nfts': {'set_price', 'buy_item', 'create_swap', 'claim_swap'},
    'SecurityBudget': {'claim_reward_page'},
    'EraV14AssetAllocator': {'create_collection', 'mint_item'},
  };

  static const Map<String, Set<String>> requiredStorage = {
    'System': {'Account', 'Number', 'BlockHash', 'Events'},
    'TransactionPayment': {'NextFeeMultiplier'},
    'Session': {'Validators'},
    'Staking': {
      'ValidatorCount',
      'Bonded',
      'MinValidatorBond',
      'Ledger',
      'Validators',
      'Nominators',
      'CurrentEra',
      'ActiveEra',
      'ErasValidatorReward',
      'ErasRewardPoints',
    },
    'AiPredictions': {
      'Models',
      'Predictions',
      'ModelOnboardingConfig',
      'PredictionTokens',
      'StakingConfig',
      'PredictionTokenSideStakes',
      'PredictionTokenSideTotals',
      'PredictionTokenSidePayoutClaims',
      'PredictionTokenMarketLocked',
      'PredictionTokenMarketAccounting',
    },
    'Nfts': {
      'Collection',
      'Item',
      'CollectionMetadataOf',
      'ItemMetadataOf',
      'ItemPriceOf',
      'PendingSwapOf',
    },
    'SecurityBudget': {
      'Active',
      'FirstEligibleEra',
      'EraBudgets',
      'EligibleValidatorPoints',
      'ClaimedPages',
      'ExpiredEras',
      'EraLiability',
      'StakingPaidTotal',
      'AllocationPaused',
    },
    'EraV14AssetAllocator': {
      'SchemaVersion',
      'NextCollectionId',
      'NextItemId',
      'NextCollectionCreator',
    },
  };

  final polkadart.Provider provider;

  const EraV14RuntimeGuard(this.provider);

  Future<EraV14CompatibilitySnapshot> verify() async {
    final finalizedHead = _requiredString(
      await provider.send('chain_getFinalizedHead', const []),
      'chain_getFinalizedHead',
    );
    final responses = await Future.wait([
      provider.send('system_chain', const []),
      provider.send('chain_getBlockHash', const [0]),
      provider.send('state_getRuntimeVersion', [finalizedHead]),
      provider.send('system_properties', const []),
      provider.send('state_getMetadata', [finalizedHead]),
      provider.send('rpc_methods', const []),
    ]);

    final runtime = _requiredMap(responses[2], 'state_getRuntimeVersion');
    final properties = _requiredMap(responses[3], 'system_properties');
    final identity = EraV14RuntimeIdentity(
      chainName: _requiredString(responses[0], 'system_chain'),
      genesisHash: _requiredString(responses[1], 'chain_getBlockHash(0)'),
      specName: runtime['specName']?.toString() ?? '',
      specVersion: _rpcInt(runtime['specVersion'], 'specVersion'),
      transactionVersion: _rpcInt(
        runtime['transactionVersion'],
        'transactionVersion',
      ),
      tokenSymbol: _singleProperty(properties['tokenSymbol']),
      tokenDecimals: _rpcInt(
        _singlePropertyValue(properties['tokenDecimals']),
        'tokenDecimals',
      ),
      ss58Prefix: _rpcInt(properties['ss58Format'], 'ss58Format'),
    );
    identity.verify();

    final rpcMethods = _requiredMap(responses[5], 'rpc_methods')['methods'];
    if (rpcMethods is! List || !rpcMethods.contains('payment_queryInfo')) {
      throw const EraV14CompatibilityException(
        'the node does not expose the required payment_queryInfo fee RPC.',
      );
    }

    final metadataHex = _requiredString(responses[4], 'state_getMetadata');
    final metadata = await inspectMetadata(_decodeRpcHex(metadataHex));
    return EraV14CompatibilitySnapshot(
      finalizedHead: finalizedHead,
      identity: identity,
      metadata: metadata,
    );
  }

  static Future<EraV14MetadataSurface> inspectMetadata(List<int> bytes) async {
    late final RuntimeMetadataPrefixed prefixed;
    try {
      prefixed = RuntimeMetadataPrefixed.fromBytes(Uint8List.fromList(bytes));
    } on Object {
      throw const EraV14CompatibilityException(
        'metadata cannot be decoded with the supported V14 decoder.',
      );
    }
    final metadata = prefixed.metadata;
    final version = metadata.runtimeMetadataVersion();
    if (version != kEraMetadataVersion) {
      throw EraV14CompatibilityException(
        'metadata V$version is unsupported; expected V$kEraMetadataVersion.',
      );
    }

    final digest = await Sha256().hash(bytes);
    final sha256 = digest.bytes
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
    if (_normalizeHash(sha256) != _normalizeHash(kEraMetadataSha256)) {
      throw EraV14CompatibilityException(
        'metadata is stale or unreviewed (sha256=$sha256).',
      );
    }

    final calls = <String, Set<String>>{};
    final storage = <String, Set<String>>{};
    for (final pallet in metadata.pallets) {
      final callTypeId = pallet.calls?.type;
      if (callTypeId != null) {
        final callType = metadata.typeById(callTypeId).type.typeDef;
        if (callType is! TypeDefVariant) {
          throw EraV14CompatibilityException(
            '${pallet.name} calls are not encoded as a SCALE variant.',
          );
        }
        calls[pallet.name] = {
          for (final variant in callType.variants) variant.name,
        };
      }
      storage[pallet.name] = {
        for (final entry in pallet.storage?.entries ?? const []) entry.name,
      };
    }

    _verifyRequiredSurface('call', calls, requiredCalls);
    _verifyRequiredSurface('storage', storage, requiredStorage);
    return EraV14MetadataSurface(
      version: version,
      sha256: sha256,
      calls: calls,
      storage: storage,
    );
  }

  static void _verifyRequiredSurface(
    String kind,
    Map<String, Set<String>> observed,
    Map<String, Set<String>> required,
  ) {
    for (final pallet in required.entries) {
      final observedItems = observed[pallet.key];
      if (observedItems == null) {
        throw EraV14CompatibilityException(
          'required ${pallet.key} pallet is absent from metadata.',
        );
      }
      final missing = pallet.value.difference(observedItems).toList()..sort();
      if (missing.isNotEmpty) {
        throw EraV14CompatibilityException(
          '${pallet.key} is missing required $kind entries: '
          '${missing.join(', ')}.',
        );
      }
    }
  }
}

Map _requiredMap(polkadart.RpcResponse response, String method) {
  if (response.error != null || response.result is! Map) {
    throw EraV14CompatibilityException('$method returned an invalid response.');
  }
  return response.result! as Map;
}

String _requiredString(polkadart.RpcResponse response, String method) {
  if (response.error != null || response.result is! String) {
    throw EraV14CompatibilityException('$method returned an invalid response.');
  }
  return response.result! as String;
}

int _rpcInt(Object? value, String field) {
  if (value is int) return value;
  if (value is BigInt) return value.toInt();
  final text = value?.toString() ?? '';
  final parsed = text.startsWith('0x')
      ? BigInt.tryParse(text.substring(2), radix: 16)
      : BigInt.tryParse(text);
  if (parsed == null || parsed.isNegative || parsed > BigInt.from(0x7fffffff)) {
    throw EraV14CompatibilityException('$field is missing or invalid.');
  }
  return parsed.toInt();
}

Object? _singlePropertyValue(Object? value) {
  if (value is List && value.length == 1) return value.single;
  return value;
}

String _singleProperty(Object? value) =>
    _singlePropertyValue(value)?.toString() ?? '';

Uint8List _decodeRpcHex(String value) {
  final normalized = value.startsWith('0x') ? value.substring(2) : value;
  if (normalized.length.isOdd) {
    throw const EraV14CompatibilityException('metadata hex is malformed.');
  }
  return Uint8List.fromList(decodeHex(normalized));
}

String _normalizeHash(String value) =>
    value.trim().toLowerCase().replaceFirst(RegExp(r'^0x'), '');
