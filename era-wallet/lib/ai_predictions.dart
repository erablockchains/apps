import 'dart:async';
import 'dart:math' as math;

import 'package:bip39/bip39.dart' as bip39;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:provider/provider.dart' as flutter_provider;

import 'accounts_flow.dart';
import 'auth_flow.dart';
import 'config.dart';
import 'era_chain.dart';
import 'era_scaffold.dart';
import 'generated/era/era.dart' as era_api;
import 'phase6b/runtime_compatibility.dart';
import 'phase6b/runtime_probe.dart';
import 'transfer_history.dart';

const _stakeCallName = 'stake_on_prediction_outcome_side';
const _unstakeCallName = 'unstake_from_prediction_outcome_side';
const _claimCallName = 'claim_prediction_market_payout';

bool _isReviewedParticipantRuntime(String specName, int specVersion) =>
    specName == Phase6bRuntimeCompatibility.approvedSpecName &&
    specVersion == Phase6bRuntimeCompatibility.approvedSpecVersion;

enum PredictionOutcomeSide {
  yes,
  no;

  String get label => this == PredictionOutcomeSide.yes ? 'YES' : 'NO';

  MapEntry<String, dynamic> toCallValue([List<String> variants = const []]) {
    final normalized = name;
    final variant = variants.firstWhere(
      (value) => _normalizeMetadataName(value) == normalized,
      orElse: () => this == PredictionOutcomeSide.yes ? 'Yes' : 'No',
    );
    return MapEntry(variant, null);
  }
}

class AiPredictionAmountFormatter {
  static String format(BigInt? value) => formatEra(value);
  static BigInt? parse(String input) => parseEraToUnits(input);
}

String eraWalletChainDisplayName(String rawName) {
  final trimmed = rawName.trim();
  final normalized = _normalizeMetadataName(trimmed);
  if (normalized == 'eramainnet') return 'ERA-MAINNET';
  if (normalized == 'era') return 'ERA';
  return trimmed.isEmpty ? 'ERA-MAINNET' : trimmed;
}

class EraRuntimeCapabilities {
  final String endpoint;
  final String chainName;
  final String specName;
  final int specVersion;
  final bool aiPredictionsAvailable;
  final bool sideMarketsAvailable;
  final bool settlementAvailable;
  final bool marketFeesAvailable;
  final DateTime metadataRefreshedAt;
  final AiPredictionPalletMetadata? aiPallet;
  final List<String> metadataWarnings;

  const EraRuntimeCapabilities({
    required this.endpoint,
    required this.chainName,
    required this.specName,
    required this.specVersion,
    required this.aiPredictionsAvailable,
    required this.sideMarketsAvailable,
    required this.settlementAvailable,
    required this.marketFeesAvailable,
    required this.metadataRefreshedAt,
    required this.aiPallet,
    this.metadataWarnings = const [],
  });

  bool get runtimeReady => _isReviewedParticipantRuntime(specName, specVersion);

  String get unavailableReason {
    if (!runtimeReady) {
      return 'AI Prediction features are not available on this runtime yet.';
    }
    if (aiPallet == null) {
      return 'AI Prediction features are not available on this runtime yet.';
    }
    return 'AI Prediction features are available for testing.';
  }
}

class AiPredictionPalletMetadata {
  final String name;
  final String storagePrefix;
  final int index;
  final Map<String, AiRuntimeCall> callsByNormalizedName;
  final Map<String, AiRuntimeStorage> storageByNormalizedName;

  const AiPredictionPalletMetadata({
    required this.name,
    required this.storagePrefix,
    required this.index,
    required this.callsByNormalizedName,
    required this.storageByNormalizedName,
  });

  AiRuntimeCall? call(String name) =>
      callsByNormalizedName[_normalizeMetadataName(name)];

  AiRuntimeStorage? storage(String name) =>
      storageByNormalizedName[_normalizeMetadataName(name)];

  bool get hasStake => call(_stakeCallName) != null;
  bool get hasUnstake => call(_unstakeCallName) != null;
  bool get hasClaim => call(_claimCallName) != null;

  List<String> get callNames =>
      callsByNormalizedName.values.map((call) => call.name).toList();

  List<String> get storageNames =>
      storageByNormalizedName.values.map((storage) => storage.name).toList();

  AiRuntimeStorage? findStorage(Iterable<String> names) {
    for (final name in names) {
      final item = storage(name);
      if (item != null) return item;
    }
    return null;
  }

  List<AiRuntimeStorage> findStoragesByHint(Iterable<String> hints) {
    final normalizedHints = hints.map(_normalizeMetadataName).toList();
    return storageByNormalizedName.values.where((storage) {
      final normalized = _normalizeMetadataName(storage.name);
      return normalizedHints.any(normalized.contains);
    }).toList();
  }
}

class AiRuntimeCall {
  final String name;
  final List<AiRuntimeCallArg> args;

  const AiRuntimeCall({required this.name, required this.args});
}

class AiRuntimeCallArg {
  final String name;
  final int typeId;
  final String typeName;
  final List<String> variantNames;

  const AiRuntimeCallArg({
    required this.name,
    required this.typeId,
    required this.typeName,
    this.variantNames = const [],
  });
}

class AiRuntimeStorage {
  final String name;
  final String prefix;
  final String? valueTypeName;
  final String? keyTypeName;
  final String? hasherName;
  final bool isMap;

  const AiRuntimeStorage({
    required this.name,
    required this.prefix,
    this.valueTypeName,
    this.keyTypeName,
    this.hasherName,
    this.isMap = false,
  });
}

class AiModel {
  final int id;
  final String title;
  final String status;
  final String rawSummary;

  const AiModel({
    required this.id,
    this.title = 'AI model',
    this.status = 'Unknown',
    this.rawSummary = '',
  });
}

class AiPrediction {
  final int id;
  final int? modelId;
  final String title;
  final String description;
  final String status;
  final String settlementStatus;
  final BigInt? yesTotal;
  final BigInt? noTotal;
  final BigInt? userYesStake;
  final BigInt? userNoStake;
  final String rawSummary;
  final Map<String, dynamic> decodedFields;

  const AiPrediction({
    required this.id,
    this.modelId,
    this.title = 'Prediction market',
    this.description = '',
    this.status = 'Unknown',
    this.settlementStatus = 'Unknown',
    this.yesTotal,
    this.noTotal,
    this.userYesStake,
    this.userNoStake,
    this.rawSummary = '',
    this.decodedFields = const {},
  });

  AiPrediction copyWith({BigInt? userYesStake, BigInt? userNoStake}) {
    return AiPrediction(
      id: id,
      modelId: modelId,
      title: title,
      description: description,
      status: status,
      settlementStatus: settlementStatus,
      yesTotal: yesTotal,
      noTotal: noTotal,
      userYesStake: userYesStake ?? this.userYesStake,
      userNoStake: userNoStake ?? this.userNoStake,
      rawSummary: rawSummary,
      decodedFields: decodedFields,
    );
  }
}

class UserPredictionPosition {
  final int predictionId;
  final PredictionOutcomeSide side;
  final BigInt stakedAmount;
  final BigInt unstakedAmount;
  final bool claimed;

  UserPredictionPosition({
    required this.predictionId,
    required this.side,
    required this.stakedAmount,
    BigInt? unstakedAmount,
    this.claimed = false,
  }) : unstakedAmount = unstakedAmount ?? BigInt.zero;

  BigInt get netAmount {
    final net = stakedAmount - unstakedAmount;
    return net > BigInt.zero ? net : BigInt.zero;
  }
}

class PredictionClaimStatus {
  final int predictionId;
  final bool claimable;
  final bool claimed;
  final BigInt? estimatedPayout;

  const PredictionClaimStatus({
    required this.predictionId,
    this.claimable = false,
    this.claimed = false,
    this.estimatedPayout,
  });
}

class MarketEconomicsConfig {
  final bool unstakeAllowedBeforeSettlement;
  final String rawSummary;

  const MarketEconomicsConfig({
    this.unstakeAllowedBeforeSettlement = true,
    this.rawSummary = '',
  });
}

class MarketFeeConfig {
  final String rawSummary;
  const MarketFeeConfig({this.rawSummary = ''});
}

class MarketAccounting {
  final BigInt? feesCollected;
  final BigInt? treasuryAmount;
  const MarketAccounting({this.feesCollected, this.treasuryAmount});
}

class AiPredictionsSnapshot {
  final EraRuntimeCapabilities capabilities;
  final List<AiPrediction> predictions;
  final List<AiModel> models;
  final List<UserPredictionPosition> positions;
  final List<PredictionClaimStatus> claims;

  const AiPredictionsSnapshot({
    required this.capabilities,
    this.predictions = const [],
    this.models = const [],
    this.positions = const [],
    this.claims = const [],
  });
}

class EraRuntimeCapabilitiesService {
  final polkadart.Provider provider;
  final era_api.Era api;

  const EraRuntimeCapabilitiesService({
    required this.provider,
    required this.api,
  });

  Future<EraRuntimeCapabilities> load() async {
    final chainResponse = await provider.send('system_chain', const []);
    final chainName = eraWalletChainDisplayName(
      chainResponse.result?.toString() ?? 'ERA',
    );
    final runtimeVersion = await api.rpc.state.getRuntimeVersion();
    final metadata = await api.rpc.state.getMetadata();
    final inspector = AiPredictionMetadataInspector(metadata);
    final aiPallet = inspector.findAiPredictionPallet();
    final runtimeReady = _isReviewedParticipantRuntime(
      runtimeVersion.specName,
      runtimeVersion.specVersion,
    );

    final metadataWarnings = <String>[];
    if (aiPallet == null) {
      metadataWarnings.add(
        'AI prediction pallet was not found in live metadata.',
      );
    } else {
      for (final requiredCall in const [
        _stakeCallName,
        _unstakeCallName,
        _claimCallName,
      ]) {
        if (aiPallet.call(requiredCall) == null) {
          metadataWarnings.add('Missing AI prediction call: $requiredCall');
        }
      }
    }

    return EraRuntimeCapabilities(
      endpoint: kDefaultEraWsEndpoint,
      chainName: chainName,
      specName: runtimeVersion.specName,
      specVersion: runtimeVersion.specVersion,
      aiPredictionsAvailable:
          runtimeReady &&
          aiPallet != null &&
          aiPallet.hasStake &&
          aiPallet.hasClaim,
      sideMarketsAvailable:
          runtimeReady && aiPallet != null && aiPallet.hasStake,
      settlementAvailable:
          runtimeReady && aiPallet != null && aiPallet.hasClaim,
      marketFeesAvailable:
          runtimeReady &&
          aiPallet != null &&
          (aiPallet.call('set_market_fee_config') != null ||
              aiPallet.findStoragesByHint(const [
                'fee',
                'treasury',
                'accounting',
              ]).isNotEmpty),
      metadataRefreshedAt: DateTime.now(),
      aiPallet: aiPallet,
      metadataWarnings: metadataWarnings,
    );
  }
}

class AiPredictionMetadataInspector {
  final polkadart.RuntimeMetadata metadata;
  late final Map<String, dynamic> _json =
      _normalizeMetadataValue(metadata.metadata) as Map<String, dynamic>;

  AiPredictionMetadataInspector(this.metadata);

  AiPredictionPalletMetadata? findAiPredictionPallet() {
    final pallets = _json['pallets'];
    if (pallets is! List) return null;

    AiPredictionPalletMetadata? best;
    var bestScore = 0;

    for (final rawPallet in pallets) {
      if (rawPallet is! Map) continue;
      final pallet = Map<String, dynamic>.from(rawPallet);
      final parsed = _parsePallet(pallet);
      if (parsed == null) continue;

      final normalizedName = _normalizeMetadataName(parsed.name);
      var score = 0;
      if (normalizedName.contains('ai')) score += 3;
      if (normalizedName.contains('prediction')) score += 5;
      if (parsed.call(_stakeCallName) != null) score += 12;
      if (parsed.call(_unstakeCallName) != null) score += 8;
      if (parsed.call(_claimCallName) != null) score += 8;
      if (parsed.findStoragesByHint(const ['prediction']).isNotEmpty) {
        score += 4;
      }
      if (parsed.findStoragesByHint(const ['model']).isNotEmpty) {
        score += 2;
      }

      if (score > bestScore) {
        bestScore = score;
        best = parsed;
      }
    }

    return bestScore >= 8 ? best : null;
  }

  AiPredictionPalletMetadata? _parsePallet(Map<String, dynamic> pallet) {
    final name = pallet['name']?.toString();
    if (name == null || name.isEmpty) return null;

    final callsByNormalizedName = <String, AiRuntimeCall>{};
    final calls = pallet['calls'];
    final callTypeId = calls is Map ? calls['type'] : null;
    if (callTypeId is int) {
      final callType = _lookupTypeById(callTypeId);
      final variants = _variantDefinitions(callType);
      for (final variant in variants) {
        final callName = variant['name']?.toString();
        if (callName == null || callName.isEmpty) continue;
        final args = <AiRuntimeCallArg>[];
        final fields = variant['fields'];
        if (fields is List) {
          for (var index = 0; index < fields.length; index++) {
            final rawField = fields[index];
            if (rawField is! Map) continue;
            final field = Map<String, dynamic>.from(rawField);
            final typeId = field['type'];
            if (typeId is! int) continue;
            final argName =
                field['name']?.toString() ??
                field['typeName']?.toString() ??
                'arg$index';
            args.add(
              AiRuntimeCallArg(
                name: argName,
                typeId: typeId,
                typeName: _typeNameForId(typeId),
                variantNames: _variantNamesForTypeId(typeId),
              ),
            );
          }
        }

        callsByNormalizedName[_normalizeMetadataName(callName)] = AiRuntimeCall(
          name: callName,
          args: args,
        );
      }
    }

    final storageByNormalizedName = <String, AiRuntimeStorage>{};
    final storage = pallet['storage'];
    final storagePrefix = storage is Map
        ? storage['prefix']?.toString() ?? name
        : name;
    final storageItems = storage is Map ? storage['items'] : null;
    if (storageItems is List) {
      for (final rawItem in storageItems) {
        if (rawItem is! Map) continue;
        final item = Map<String, dynamic>.from(rawItem);
        final storageName = item['name']?.toString();
        if (storageName == null || storageName.isEmpty) continue;
        storageByNormalizedName[_normalizeMetadataName(storageName)] =
            _parseStorageItem(storageName, storagePrefix, item);
      }
    }

    return AiPredictionPalletMetadata(
      name: name,
      storagePrefix: storagePrefix,
      index: pallet['index'] is int ? pallet['index'] as int : 0,
      callsByNormalizedName: callsByNormalizedName,
      storageByNormalizedName: storageByNormalizedName,
    );
  }

  AiRuntimeStorage _parseStorageItem(
    String name,
    String prefix,
    Map<String, dynamic> item,
  ) {
    final type = item['type'];
    if (type is Map) {
      final plain = type['Plain'];
      if (plain is int) {
        return AiRuntimeStorage(
          name: name,
          prefix: prefix,
          valueTypeName: _typeNameForId(plain),
        );
      }

      final map = type['Map'];
      if (map is Map) {
        final valueType = map['value'];
        final keyType = map['key'];
        final hashers = map['hashers'];
        final hasher =
            map['hasher']?.toString() ??
            (hashers is List && hashers.isNotEmpty
                ? hashers.first.toString()
                : null);

        return AiRuntimeStorage(
          name: name,
          prefix: prefix,
          valueTypeName: valueType is int ? _typeNameForId(valueType) : null,
          keyTypeName: keyType is int ? _typeNameForId(keyType) : null,
          hasherName: hasher,
          isMap: true,
        );
      }
    }

    return AiRuntimeStorage(name: name, prefix: prefix);
  }

  Map<String, dynamic>? _lookupTypeById(int id) {
    final lookup = _json['lookup'];
    final types = lookup is Map ? lookup['types'] : null;
    if (types is! List) return null;

    if (id >= 0 && id < types.length && types[id] is Map) {
      final candidate = Map<String, dynamic>.from(types[id] as Map);
      if (candidate['id'] == id || candidate['id'] == null) {
        return candidate;
      }
    }

    for (final raw in types) {
      if (raw is Map && raw['id'] == id) {
        return Map<String, dynamic>.from(raw);
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _variantDefinitions(
    Map<String, dynamic>? typeEntry,
  ) {
    final type = typeEntry?['type'];
    final def = type is Map ? type['def'] : null;
    final variant = def is Map ? def['Variant'] : null;
    final variants = variant is Map ? variant['variants'] : null;
    if (variants is! List) return const [];
    return variants
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<String> _variantNamesForTypeId(int id) {
    return _variantDefinitions(_lookupTypeById(id))
        .map((variant) => variant['name']?.toString())
        .whereType<String>()
        .toList();
  }

  String _typeNameForId(int id) {
    final item = _lookupTypeById(id);
    if (item == null) return 'Type$id';
    final type = item['type'];
    if (type is! Map) return 'Type$id';
    final path = type['path'] is List ? type['path'] as List : const [];
    final def = type['def'];
    if (def is! Map) return path.isNotEmpty ? path.last.toString() : 'Type$id';

    final primitive = def['Primitive'];
    if (primitive != null) return primitive.toString();

    final sequence = def['Sequence'];
    if (sequence is Map && sequence['type'] is int) {
      return 'Vec<${_typeNameForId(sequence['type'] as int)}>';
    }

    final array = def['Array'];
    if (array is Map && array['type'] is int) {
      return '[${_typeNameForId(array['type'] as int)}; ${array['len']}]';
    }

    final compact = def['Compact'];
    if (compact is Map && compact['type'] is int) {
      return 'Compact<${_typeNameForId(compact['type'] as int)}>';
    }

    final tuple = def['Tuple'];
    if (tuple is List) {
      if (tuple.isEmpty) return 'Null';
      return '(${tuple.whereType<int>().map(_typeNameForId).join(', ')})';
    }

    final variant = def['Variant'];
    if (variant is Map) {
      final firstPath = path.isNotEmpty ? path.first.toString() : '';
      if (firstPath == 'Option') {
        final params = type['params'];
        final subType = params is List && params.isNotEmpty
            ? params.first['type']
            : null;
        return subType is int ? 'Option<${_typeNameForId(subType)}>' : 'Option';
      }
      if (firstPath == 'Result') return 'Result';
      if (path.isNotEmpty) return path.last.toString();
      return 'Enum$id';
    }

    final composite = def['Composite'];
    if (composite is Map) {
      final fields = composite['fields'];
      if (path.isNotEmpty) return path.last.toString();
      if (fields is List && fields.length == 1) {
        final field = fields.first;
        if (field is Map && field['type'] is int) {
          return _typeNameForId(field['type'] as int);
        }
      }
      return 'Composite$id';
    }

    return path.isNotEmpty ? path.last.toString() : 'Type$id';
  }
}

class AiPredictionRepository {
  final polkadart.Provider provider;
  final era_api.Era api;

  const AiPredictionRepository({required this.provider, required this.api});

  Future<AiPredictionsSnapshot> loadSnapshot({
    required List<TransferHistoryEntry> localHistory,
  }) async {
    final capabilities = await EraRuntimeCapabilitiesService(
      provider: provider,
      api: api,
    ).load();
    final positions = buildLocalPositions(localHistory);
    final claims = positions
        .map(
          (position) => PredictionClaimStatus(
            predictionId: position.predictionId,
            claimed: position.claimed,
          ),
        )
        .toList();

    if (!capabilities.aiPredictionsAvailable) {
      return AiPredictionsSnapshot(
        capabilities: capabilities,
        positions: positions,
        claims: claims,
      );
    }

    final predictions = await fetchPredictions(
      capabilities: capabilities,
      localPositions: positions,
    );
    final models = await fetchModels(capabilities: capabilities);

    return AiPredictionsSnapshot(
      capabilities: capabilities,
      predictions: predictions,
      models: models,
      positions: positions,
      claims: claims,
    );
  }

  Future<List<AiPrediction>> fetchPredictions({
    required EraRuntimeCapabilities capabilities,
    List<UserPredictionPosition> localPositions = const [],
    int limit = 25,
  }) async {
    final pallet = capabilities.aiPallet;
    if (pallet == null) return const [];

    final metadata = await api.rpc.state.getMetadata();
    final predictionStorage =
        pallet.findStorage(const [
          'Predictions',
          'PredictionById',
          'PredictionInfo',
          'PredictionDetails',
        ]) ??
        _bestStorageByHints(pallet, const ['prediction']);
    if (predictionStorage == null) return const [];

    final nextId = await _readNextId(
      pallet.findStorage(const ['NextPredictionId', 'NextPredictionID']),
      metadata,
    );
    final predictions = <AiPrediction>[];
    if (nextId != null && nextId > 0 && predictionStorage.isMap) {
      final max = math.min(nextId, limit);
      for (var id = 0; id < max; id++) {
        final storageKey = _storageKeyForId(predictionStorage, id);
        if (storageKey == null) continue;
        final raw = await api.rpc.state.getStorage(storageKey);
        if (raw == null) continue;
        predictions.add(
          _predictionFromStorage(
            id: id,
            raw: raw,
            storage: predictionStorage,
            metadata: metadata,
            localPositions: localPositions,
          ),
        );
      }
      return predictions;
    }

    final prefix = _storageEntryPrefix(predictionStorage);
    final keys = await api.rpc.state.getKeysPaged(key: prefix, count: limit);
    for (var index = 0; index < keys.length; index++) {
      final raw = await api.rpc.state.getStorage(keys[index]);
      if (raw == null) continue;
      final parsedId = _tryExtractIdFromKey(prefix, keys[index]) ?? index;
      predictions.add(
        _predictionFromStorage(
          id: parsedId,
          raw: raw,
          storage: predictionStorage,
          metadata: metadata,
          localPositions: localPositions,
        ),
      );
    }
    return predictions;
  }

  Future<List<AiModel>> fetchModels({
    required EraRuntimeCapabilities capabilities,
    int limit = 25,
  }) async {
    final pallet = capabilities.aiPallet;
    if (pallet == null) return const [];

    final metadata = await api.rpc.state.getMetadata();
    final modelStorage =
        pallet.findStorage(const [
          'Models',
          'AiModels',
          'AIModels',
          'ModelRegistry',
        ]) ??
        _bestStorageByHints(pallet, const ['model']);
    if (modelStorage == null) return const [];

    final nextId = await _readNextId(
      pallet.findStorage(const ['NextModelId', 'NextModelID']),
      metadata,
    );
    final models = <AiModel>[];
    if (nextId != null && nextId > 0 && modelStorage.isMap) {
      final max = math.min(nextId, limit);
      for (var id = 0; id < max; id++) {
        final storageKey = _storageKeyForId(modelStorage, id);
        if (storageKey == null) continue;
        final raw = await api.rpc.state.getStorage(storageKey);
        if (raw == null) continue;
        models.add(_modelFromStorage(id, raw, modelStorage, metadata));
      }
      return models;
    }

    final prefix = _storageEntryPrefix(modelStorage);
    final keys = await api.rpc.state.getKeysPaged(key: prefix, count: limit);
    for (var index = 0; index < keys.length; index++) {
      final raw = await api.rpc.state.getStorage(keys[index]);
      if (raw == null) continue;
      final parsedId = _tryExtractIdFromKey(prefix, keys[index]) ?? index;
      models.add(_modelFromStorage(parsedId, raw, modelStorage, metadata));
    }
    return models;
  }

  static List<UserPredictionPosition> buildLocalPositions(
    List<TransferHistoryEntry> history,
  ) {
    final grouped = <String, _MutableLocalPosition>{};
    final claimedPredictionIds = <int>{};
    for (final entry in history) {
      if (!entry.kind.isAiPrediction) continue;
      final ref = parsePredictionHistoryRef(entry.counterpartyAddress);
      if (ref == null) continue;
      if (entry.kind == TransferHistoryKind.aiPredictionClaim) {
        claimedPredictionIds.add(ref.predictionId);
        continue;
      }
      final side = ref.side;
      if (side == null) continue;
      final key = '${ref.predictionId}:${side.name}';
      final position = grouped.putIfAbsent(
        key,
        () => _MutableLocalPosition(ref.predictionId, side),
      );
      if (entry.kind == TransferHistoryKind.aiPredictionStake) {
        position.staked += entry.amount;
      } else if (entry.kind == TransferHistoryKind.aiPredictionUnstake) {
        position.unstaked += entry.amount;
      }
    }

    return grouped.values
        .map(
          (position) => UserPredictionPosition(
            predictionId: position.predictionId,
            side: position.side,
            stakedAmount: position.staked,
            unstakedAmount: position.unstaked,
            claimed: claimedPredictionIds.contains(position.predictionId),
          ),
        )
        .where((position) => position.netAmount > BigInt.zero)
        .toList()
      ..sort((a, b) => a.predictionId.compareTo(b.predictionId));
  }

  Future<int?> _readNextId(
    AiRuntimeStorage? storage,
    polkadart.RuntimeMetadata metadata,
  ) async {
    if (storage == null) return null;
    final raw = await api.rpc.state.getStorage(_storageEntryPrefix(storage));
    if (raw == null) return null;
    final decoded = _decodeStorageValue(storage, raw, metadata);
    final intValue = _dynamicToInt(decoded);
    if (intValue != null) return intValue;
    if (raw.length >= 4) {
      return U32Codec.codec.decode(ByteInput(raw));
    }
    return null;
  }

  AiRuntimeStorage? _bestStorageByHints(
    AiPredictionPalletMetadata pallet,
    Iterable<String> hints,
  ) {
    final matches = pallet
        .findStoragesByHint(hints)
        .where((item) => !item.name.toLowerCase().contains('position'))
        .where((item) => !item.name.toLowerCase().contains('claim'))
        .toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => a.name.length.compareTo(b.name.length));
    return matches.first;
  }

  AiPrediction _predictionFromStorage({
    required int id,
    required Uint8List raw,
    required AiRuntimeStorage storage,
    required polkadart.RuntimeMetadata metadata,
    required List<UserPredictionPosition> localPositions,
  }) {
    final decoded = _decodeStorageValue(storage, raw, metadata);
    final fields = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    final title =
        _firstText(fields, const [
          'title',
          'question',
          'prompt',
          'description',
          'metadata',
        ]) ??
        'Prediction #$id';
    final description =
        _firstText(fields, const ['details', 'description', 'metadata']) ?? '';
    final status = _firstText(fields, const ['status', 'state']) ?? 'Unknown';
    final settlementStatus =
        _firstText(fields, const ['settlement', 'result', 'outcome']) ??
        'Unsettled or unknown';

    final yesPosition = localPositions
        .where(
          (position) =>
              position.predictionId == id &&
              position.side == PredictionOutcomeSide.yes,
        )
        .fold<BigInt>(BigInt.zero, (sum, position) => sum + position.netAmount);
    final noPosition = localPositions
        .where(
          (position) =>
              position.predictionId == id &&
              position.side == PredictionOutcomeSide.no,
        )
        .fold<BigInt>(BigInt.zero, (sum, position) => sum + position.netAmount);

    return AiPrediction(
      id: id,
      modelId: _firstInt(fields, const ['modelId', 'model']),
      title: title,
      description: description,
      status: status,
      settlementStatus: settlementStatus,
      yesTotal: _firstAmount(fields, const ['yesTotal', 'yesStake', 'yes']),
      noTotal: _firstAmount(fields, const ['noTotal', 'noStake', 'no']),
      userYesStake: yesPosition > BigInt.zero ? yesPosition : null,
      userNoStake: noPosition > BigInt.zero ? noPosition : null,
      rawSummary: _shortHex(raw),
      decodedFields: fields,
    );
  }

  AiModel _modelFromStorage(
    int id,
    Uint8List raw,
    AiRuntimeStorage storage,
    polkadart.RuntimeMetadata metadata,
  ) {
    final decoded = _decodeStorageValue(storage, raw, metadata);
    final fields = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{};
    final title =
        _firstText(fields, const ['title', 'name', 'metadata']) ?? 'Model #$id';
    final status = _firstText(fields, const ['status', 'state']) ?? 'Unknown';
    return AiModel(
      id: id,
      title: title,
      status: status,
      rawSummary: _shortHex(raw),
    );
  }
}

class AiPredictionTransactionService {
  final polkadart.Provider provider;
  final era_api.Era api;

  const AiPredictionTransactionService({
    required this.provider,
    required this.api,
  });

  Future<BigInt?> estimateFee({
    required String fromMnemonic,
    required EraRuntimeCapabilities capabilities,
    required String callName,
    required int predictionId,
    PredictionOutcomeSide? side,
    BigInt? amount,
  }) async {
    try {
      final keyring = Keyring();
      final wallet = await keyring.fromMnemonic(fromMnemonic.trim());
      final encodedCall = await _encodeAiCall(
        capabilities: capabilities,
        callName: callName,
        predictionId: predictionId,
        side: side,
        amount: amount,
      );
      final extrinsic = await _signedExtrinsicBytes(
        wallet: wallet,
        encodedCall: encodedCall,
        endpoint: capabilities.endpoint,
      );
      final resp = await provider.send('payment_queryInfo', [
        '0x${encodeHex(extrinsic)}',
      ]);
      final result = resp.result;
      if (result is! Map) return null;
      final partial = result['partialFee'];
      if (partial == null) return null;
      final feeText = partial.toString();
      if (feeText.startsWith('0x')) {
        return BigInt.parse(feeText.substring(2), radix: 16);
      }
      return BigInt.tryParse(feeText);
    } catch (e) {
      debugPrint('AI_PREDICTIONS: fee estimate failed: $e');
      return null;
    }
  }

  Future<String> submit({
    required String fromMnemonic,
    required EraRuntimeCapabilities capabilities,
    required String callName,
    required int predictionId,
    PredictionOutcomeSide? side,
    BigInt? amount,
  }) async {
    final keyring = Keyring();
    final wallet = await keyring.fromMnemonic(fromMnemonic.trim());
    final encodedCall = await _encodeAiCall(
      capabilities: capabilities,
      callName: callName,
      predictionId: predictionId,
      side: side,
      amount: amount,
    );
    final extrinsic = await _signedExtrinsicBytes(
      wallet: wallet,
      encodedCall: encodedCall,
      endpoint: capabilities.endpoint,
    );
    final author = polkadart.AuthorApi(provider);
    final hash = await author.submitExtrinsic(Uint8List.fromList(extrinsic));
    return '0x${encodeHex(hash)}';
  }

  Future<Uint8List> encodeTransactionCallForTest({
    required EraRuntimeCapabilities capabilities,
    required String callName,
    required int predictionId,
    PredictionOutcomeSide? side,
    BigInt? amount,
  }) {
    return _encodeAiCall(
      capabilities: capabilities,
      callName: callName,
      predictionId: predictionId,
      side: side,
      amount: amount,
    );
  }

  Future<Uint8List> _encodeAiCall({
    required EraRuntimeCapabilities capabilities,
    required String callName,
    required int predictionId,
    PredictionOutcomeSide? side,
    BigInt? amount,
  }) async {
    final pallet = capabilities.aiPallet;
    if (pallet == null) {
      throw StateError('AI prediction pallet is not available.');
    }
    final call = pallet.call(callName);
    if (call == null) {
      throw StateError('AI prediction call is unavailable: $callName');
    }
    final metadata = await api.rpc.state.getMetadata();
    final args = _buildCallArguments(
      call,
      predictionId: predictionId,
      side: side,
      amount: amount,
    );
    final output = ByteOutput();
    metadata.chainInfo.scaleCodec.encodeTo(
      'Call',
      MapEntry(pallet.name, MapEntry(call.name, args)),
      output,
    );
    return output.toBytes(copy: false);
  }

  Map<String, dynamic> _buildCallArguments(
    AiRuntimeCall call, {
    required int predictionId,
    PredictionOutcomeSide? side,
    BigInt? amount,
  }) {
    final args = <String, dynamic>{};
    for (final arg in call.args) {
      final normalized = _normalizeMetadataName(arg.name);
      if (normalized.contains('prediction') && normalized.contains('id')) {
        args[arg.name] = _coerceIntegerForType(predictionId, arg.typeName);
      } else if (normalized == 'id' || normalized.endsWith('id')) {
        args[arg.name] = _coerceIntegerForType(predictionId, arg.typeName);
      } else if (normalized.contains('side') ||
          normalized.contains('outcome')) {
        if (side == null) {
          throw ArgumentError('Outcome side is required for ${call.name}.');
        }
        args[arg.name] = side.toCallValue(arg.variantNames);
      } else if (normalized.contains('amount') ||
          normalized.contains('stake') ||
          normalized.contains('value')) {
        if (amount == null) {
          throw ArgumentError('Amount is required for ${call.name}.');
        }
        args[arg.name] = amount;
      } else if (call.args.length == 1) {
        args[arg.name] = _coerceIntegerForType(predictionId, arg.typeName);
      } else {
        throw ArgumentError(
          'Cannot infer argument ${arg.name} for AI prediction call ${call.name}.',
        );
      }
    }
    return args;
  }

  Future<Uint8List> _signedExtrinsicBytes({
    required dynamic wallet,
    required Uint8List encodedCall,
    required String endpoint,
  }) async {
    final diagnostics = await Phase6bRuntimeProbe(
      provider: provider,
      api: api,
      endpoint: endpoint,
    ).refresh(activeAccount: wallet.address.toString());
    AiPredictionRuntimeSigningGuard.requireParticipantSigningEnabled(
      diagnostics.compatibility,
    );

    final runtimeVersion = await api.rpc.state.getRuntimeVersion();
    final metadata = await api.rpc.state.getMetadata();
    final registry = metadata.chainInfo.scaleCodec.registry;
    final currentBlockNumber = (await api.query.system.number()) - 1;
    final currentBlockHash = await api.query.system.blockHash(
      currentBlockNumber,
    );
    final genesisHash = await api.query.system.blockHash(0);
    final nonce = await api.rpc.system.accountNextIndex(wallet.address);

    final payload = polkadart.SigningPayload(
      method: encodedCall,
      specVersion: runtimeVersion.specVersion,
      transactionVersion: runtimeVersion.transactionVersion,
      genesisHash: encodeHex(genesisHash),
      blockHash: encodeHex(currentBlockHash),
      blockNumber: currentBlockNumber,
      eraPeriod: 64,
      nonce: nonce,
      tip: 0,
    ).encode(registry);

    final signature = wallet.sign(payload);

    return polkadart.ExtrinsicPayload(
      signer: wallet.bytes(),
      method: encodedCall,
      signature: signature,
      eraPeriod: 64,
      blockNumber: currentBlockNumber,
      nonce: nonce,
      tip: 0,
    ).encode(registry, polkadart.SignatureType.sr25519);
  }
}

class AiPredictionRuntimeSigningGuard {
  const AiPredictionRuntimeSigningGuard._();

  static void requireParticipantSigningEnabled(
    RuntimeCompatibilityResult compatibility,
  ) {
    if (compatibility.participantSigningEnabled &&
        compatibility.metadataCompatible &&
        !compatibility.metadataDriftDetected) {
      return;
    }

    final issueCodes = compatibility.issues
        .map((issue) => issue.code)
        .where((code) => code.trim().isNotEmpty)
        .join(', ');
    throw StateError(
      'AI Prediction signing blocked: the connected ERA runtime did not pass '
      'the reviewed participant-signing compatibility gate'
      '${issueCodes.isEmpty ? '.' : ' ($issueCodes).'}',
    );
  }
}

class AiPredictionErrorMapper {
  static String map(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('signing blocked') ||
        message.contains('participant-signing compatibility')) {
      return 'AI prediction signing is disabled because the connected ERA '
          'runtime did not pass the reviewed compatibility checks.';
    }
    if (message.contains('insufficient')) {
      return 'Insufficient balance for this AI prediction transaction.';
    }
    if (message.contains('prediction') && message.contains('notfound')) {
      return 'Prediction not found.';
    }
    if (message.contains('market') && message.contains('enabled')) {
      return 'This prediction market is not enabled.';
    }
    if (message.contains('outcome') || message.contains('side')) {
      return 'Invalid outcome side.';
    }
    if (message.contains('unstake')) {
      return 'Unstake is not allowed for this prediction right now.';
    }
    if (message.contains('settled')) {
      return 'This prediction is already settled.';
    }
    if (message.contains('claim') && message.contains('already')) {
      return 'This payout has already been claimed.';
    }
    if (message.contains('claim')) {
      return 'Claim is not available for this prediction yet.';
    }
    if (message.contains('badorigin') || message.contains('not authorized')) {
      return 'This action is not authorized for the connected account.';
    }
    if (message.contains('rejected') || message.contains('cancel')) {
      return 'Transaction rejected by user.';
    }
    if (message.contains('socket') || message.contains('rpc')) {
      return 'RPC disconnected. Check the ERA endpoint and try again.';
    }
    return 'AI prediction transaction failed: $error';
  }
}

class AiPredictionsScreen extends StatefulWidget {
  const AiPredictionsScreen({super.key});

  @override
  State<AiPredictionsScreen> createState() => _AiPredictionsScreenState();
}

class _AiPredictionsScreenState extends State<AiPredictionsScreen> {
  Future<AiPredictionsSnapshot>? _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<AiPredictionsSnapshot> _load() async {
    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final history = flutter_provider.Provider.of<TransferHistoryStore>(
      context,
      listen: false,
    );
    final accountManager = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final connected = await chain.ensureConnected();
    if (!connected || chain.provider == null || chain.api == null) {
      throw StateError('Not connected to ERA node');
    }
    return AiPredictionRepository(
      provider: chain.provider!,
      api: chain.api!,
    ).loadSnapshot(
      localHistory: history.forAccount(accountManager.active?.address),
    );
  }

  void _refresh() {
    setState(() {
      _loadFuture = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(kEraIconPath, width: 28, height: 28),
            const SizedBox(width: 8),
            const Text('AI Predictions'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh AI Predictions',
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<AiPredictionsSnapshot>(
        future: _loadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorPanel(
              message: 'AI Predictions could not load: ${snapshot.error}',
              onRetry: _refresh,
            );
          }
          final data = snapshot.requireData;
          return ListView(
            children: [
              const _ExperimentalBanner(),
              const SizedBox(height: 12),
              _RuntimeSummaryCard(capabilities: data.capabilities),
              const SizedBox(height: 12),
              _StatsCard(snapshot: data),
              const SizedBox(height: 12),
              _AiPredictionNavigationCard(snapshot: data, onRefresh: _refresh),
              if (!data.capabilities.aiPredictionsAvailable) ...[
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(data.capabilities.unavailableReason),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class PredictionMarketsListScreen extends StatefulWidget {
  final EraRuntimeCapabilities capabilities;

  const PredictionMarketsListScreen({super.key, required this.capabilities});

  @override
  State<PredictionMarketsListScreen> createState() =>
      _PredictionMarketsListScreenState();
}

class _PredictionMarketsListScreenState
    extends State<PredictionMarketsListScreen> {
  Future<List<AiPrediction>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<AiPrediction>> _load() async {
    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final history = flutter_provider.Provider.of<TransferHistoryStore>(
      context,
      listen: false,
    );
    final accountManager = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    return AiPredictionRepository(
      provider: chain.provider!,
      api: chain.api!,
    ).fetchPredictions(
      capabilities: widget.capabilities,
      localPositions: AiPredictionRepository.buildLocalPositions(
        history.forAccount(accountManager.active?.address),
      ),
    );
  }

  void _refresh() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(
        title: const Text('Prediction Markets'),
        actions: [
          IconButton(
            tooltip: 'Refresh markets',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: FutureBuilder<List<AiPrediction>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorPanel(
              message: 'Prediction markets could not load: ${snapshot.error}',
              onRetry: _refresh,
            );
          }
          final predictions = snapshot.requireData;
          if (predictions.isEmpty) {
            return const _EmptyPanel(
              message:
                  'No prediction markets were discovered from runtime storage.',
            );
          }
          return ListView.separated(
            itemCount: predictions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final prediction = predictions[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('#${prediction.id}')),
                  title: Text(prediction.title),
                  subtitle: Text(
                    'Model ${prediction.modelId ?? '-'} - ${prediction.status}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PredictionDetailScreen(
                          capabilities: widget.capabilities,
                          prediction: prediction,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PredictionDetailScreen extends StatefulWidget {
  final EraRuntimeCapabilities capabilities;
  final AiPrediction prediction;

  const PredictionDetailScreen({
    super.key,
    required this.capabilities,
    required this.prediction,
  });

  @override
  State<PredictionDetailScreen> createState() => _PredictionDetailScreenState();
}

class _PredictionDetailScreenState extends State<PredictionDetailScreen> {
  final _stakeAmountController = TextEditingController();
  final _unstakeAmountController = TextEditingController();
  bool _submitting = false;
  String? _lastStatus;

  @override
  void dispose() {
    _stakeAmountController.dispose();
    _unstakeAmountController.dispose();
    super.dispose();
  }

  Future<void> _submit({
    required String callName,
    PredictionOutcomeSide? side,
    BigInt? amount,
  }) async {
    if (_submitting) return;
    final messenger = ScaffoldMessenger.of(context);
    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final accountManager = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final history = flutter_provider.Provider.of<TransferHistoryStore>(
      context,
      listen: false,
    );
    final account = accountManager.active;
    if (account == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No active account selected')),
      );
      return;
    }

    final connected = await chain.ensureConnected();
    if (!connected || chain.provider == null || chain.api == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Not connected to ERA node')),
      );
      return;
    }

    if (amount != null && amount <= BigInt.zero) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Enter an amount greater than 0')),
      );
      return;
    }

    if (callName == _stakeCallName && amount != null) {
      final free = await _loadFreeBalance(chain.api!, account.address);
      if (free != null && free < amount) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Insufficient balance')),
        );
        return;
      }
    }

    if (!mounted) return;
    final auth = await authenticateWalletForSensitiveAction(
      context,
      reason: 'Authenticate to submit an AI prediction transaction',
    );
    if (!mounted || !auth.success) return;

    final mnemonic = await accountManager.loadMnemonicForAccount(account.id);
    final trimmedMnemonic = mnemonic?.trim();
    if (trimmedMnemonic == null || trimmedMnemonic.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('No mnemonic stored for this account on this device.'),
        ),
      );
      return;
    }
    if (!bip39.validateMnemonic(trimmedMnemonic)) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Stored seed phrase is not a valid BIP39 mnemonic.'),
        ),
      );
      return;
    }

    final keyring = Keyring();
    final wallet = await keyring.fromMnemonic(trimmedMnemonic);
    if (wallet.address != account.address) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Stored mnemonic does not match the active account.'),
        ),
      );
      return;
    }

    final txService = AiPredictionTransactionService(
      provider: chain.provider!,
      api: chain.api!,
    );
    final fee = await txService.estimateFee(
      fromMnemonic: trimmedMnemonic,
      capabilities: widget.capabilities,
      callName: callName,
      predictionId: widget.prediction.id,
      side: side,
      amount: amount,
    );

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm AI Prediction Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prediction ID: ${widget.prediction.id}'),
            if (side != null) Text('Side: ${side.label}'),
            if (amount != null)
              Text('Amount: ${formatEra(amount)} $kTokenSymbol'),
            Text(
              'Estimated fee: ${fee == null ? 'Unavailable' : '${formatEra(fee)} $kTokenSymbol'}',
            ),
            const SizedBox(height: 12),
            const Text('Use small amounts while testing.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _submitting = true;
      _lastStatus = 'Submitting...';
    });

    try {
      final hash = await txService.submit(
        fromMnemonic: trimmedMnemonic,
        capabilities: widget.capabilities,
        callName: callName,
        predictionId: widget.prediction.id,
        side: side,
        amount: amount,
      );
      if (!mounted) return;
      final kind = switch (callName) {
        _stakeCallName => TransferHistoryKind.aiPredictionStake,
        _unstakeCallName => TransferHistoryKind.aiPredictionUnstake,
        _claimCallName => TransferHistoryKind.aiPredictionClaim,
        _ => TransferHistoryKind.aiPredictionStake,
      };
      await history.recordSubmittedAiPrediction(
        accountAddress: account.address,
        predictionId: widget.prediction.id,
        side: side?.name,
        amount: amount ?? BigInt.zero,
        txHash: hash,
        kind: kind,
      );
      setState(() => _lastStatus = 'Submitted: $hash');
      messenger.showSnackBar(SnackBar(content: Text('Submitted: $hash')));
    } catch (e) {
      if (!mounted) return;
      final mapped = AiPredictionErrorMapper.map(e);
      setState(() => _lastStatus = mapped);
      messenger.showSnackBar(SnackBar(content: Text(mapped)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _stake(PredictionOutcomeSide side) async {
    final amount = parseEraToUnits(_stakeAmountController.text.trim());
    if (amount == null || amount <= BigInt.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid stake amount')),
      );
      return;
    }
    await _submit(callName: _stakeCallName, side: side, amount: amount);
  }

  Future<void> _unstake(PredictionOutcomeSide side) async {
    final amount = parseEraToUnits(_unstakeAmountController.text.trim());
    if (amount == null || amount <= BigInt.zero) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid unstake amount')),
      );
      return;
    }
    await _submit(callName: _unstakeCallName, side: side, amount: amount);
  }

  Future<void> _claim() async {
    await _submit(callName: _claimCallName);
  }

  @override
  Widget build(BuildContext context) {
    final prediction = widget.prediction;
    final canStake = widget.capabilities.aiPallet?.hasStake == true;
    final canUnstake = widget.capabilities.aiPallet?.hasUnstake == true;
    final canClaim = widget.capabilities.aiPallet?.hasClaim == true;

    return EraScaffold(
      appBar: AppBar(title: Text('Prediction #${prediction.id}')),
      body: ListView(
        children: [
          const _ExperimentalBanner(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prediction.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (prediction.description.isNotEmpty)
                    Text(prediction.description),
                  const SizedBox(height: 12),
                  _InfoRow('Prediction ID', prediction.id.toString()),
                  _InfoRow('Model ID', prediction.modelId?.toString() ?? '-'),
                  _InfoRow('Status', prediction.status),
                  _InfoRow('Settlement', prediction.settlementStatus),
                  _InfoRow(
                    'YES total',
                    '${formatEra(prediction.yesTotal)} $kTokenSymbol',
                  ),
                  _InfoRow(
                    'NO total',
                    '${formatEra(prediction.noTotal)} $kTokenSymbol',
                  ),
                  _InfoRow(
                    'Your YES stake',
                    '${formatEra(prediction.userYesStake)} $kTokenSymbol',
                  ),
                  _InfoRow(
                    'Your NO stake',
                    '${formatEra(prediction.userNoStake)} $kTokenSymbol',
                  ),
                  if (prediction.rawSummary.isNotEmpty)
                    _InfoRow('Raw storage', prediction.rawSummary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Market Actions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _stakeAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Stake amount (ETKN)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _SideActionButtons(
                    submitting: _submitting,
                    enabled: canStake,
                    yesLabel: 'Stake YES',
                    noLabel: 'Stake NO',
                    yesIcon: Icons.thumb_up,
                    noIcon: Icons.thumb_down,
                    onYes: () => _stake(PredictionOutcomeSide.yes),
                    onNo: () => _stake(PredictionOutcomeSide.no),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _unstakeAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Unstake amount (ETKN)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unstaking may be unavailable after settlement or when market rules disallow it.',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                  ),
                  const SizedBox(height: 8),
                  _SideActionButtons(
                    submitting: _submitting,
                    enabled: canUnstake,
                    yesLabel: 'Unstake YES',
                    noLabel: 'Unstake NO',
                    yesIcon: Icons.remove_circle_outline,
                    noIcon: Icons.remove_circle_outline,
                    onYes: () => _unstake(PredictionOutcomeSide.yes),
                    onNo: () => _unstake(PredictionOutcomeSide.no),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.redeem),
                    label: Text(
                      _submitting ? 'Submitting...' : 'Check / Claim',
                    ),
                    onPressed: _submitting || !canClaim ? null : _claim,
                  ),
                  if (_lastStatus != null) ...[
                    const SizedBox(height: 12),
                    SelectableText(
                      _lastStatus!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MyPredictionPositionsScreen extends StatelessWidget {
  const MyPredictionPositionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountManager = flutter_provider.Provider.of<AccountManager>(
      context,
    );
    final history = flutter_provider.Provider.of<TransferHistoryStore>(context);
    final positions = AiPredictionRepository.buildLocalPositions(
      history.forAccount(accountManager.active?.address),
    );
    return EraScaffold(
      appBar: AppBar(title: const Text('My AI Positions')),
      body: positions.isEmpty
          ? const _EmptyPanel(
              message: 'No AI prediction positions recorded by this wallet.',
            )
          : ListView.separated(
              itemCount: positions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final position = positions[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      position.side == PredictionOutcomeSide.yes
                          ? Icons.thumb_up
                          : Icons.thumb_down,
                    ),
                    title: Text(
                      'Prediction #${position.predictionId} - ${position.side.label}',
                    ),
                    subtitle: Text(
                      'Locked locally: ${formatEra(position.netAmount)} $kTokenSymbol',
                    ),
                    trailing: position.claimed
                        ? const Chip(label: Text('Claimed'))
                        : const Chip(label: Text('Open')),
                  ),
                );
              },
            ),
    );
  }
}

class MyPredictionClaimsScreen extends StatelessWidget {
  const MyPredictionClaimsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accountManager = flutter_provider.Provider.of<AccountManager>(
      context,
    );
    final history = flutter_provider.Provider.of<TransferHistoryStore>(context);
    final positions = AiPredictionRepository.buildLocalPositions(
      history.forAccount(accountManager.active?.address),
    );
    final ids =
        positions.map((position) => position.predictionId).toSet().toList()
          ..sort();
    return EraScaffold(
      appBar: AppBar(title: const Text('My AI Claims')),
      body: ids.isEmpty
          ? const _EmptyPanel(
              message: 'No claim candidates recorded by this wallet.',
            )
          : ListView.separated(
              itemCount: ids.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final predictionId = ids[index];
                final claimed = positions
                    .where((position) => position.predictionId == predictionId)
                    .any((position) => position.claimed);
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.redeem),
                    title: Text('Prediction #$predictionId'),
                    subtitle: Text(
                      claimed
                          ? 'Claim recorded locally.'
                          : 'Open the market detail to check claim eligibility.',
                    ),
                    trailing: Chip(label: Text(claimed ? 'Claimed' : 'Check')),
                  ),
                );
              },
            ),
    );
  }
}

class AiModelsScreen extends StatefulWidget {
  final EraRuntimeCapabilities capabilities;

  const AiModelsScreen({super.key, required this.capabilities});

  @override
  State<AiModelsScreen> createState() => _AiModelsScreenState();
}

class _AiModelsScreenState extends State<AiModelsScreen> {
  Future<List<AiModel>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<AiModel>> _load() {
    final chain = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    return AiPredictionRepository(
      provider: chain.provider!,
      api: chain.api!,
    ).fetchModels(capabilities: widget.capabilities);
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(title: const Text('AI Models')),
      body: FutureBuilder<List<AiModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorPanel(
              message: 'AI models could not load: ${snapshot.error}',
              onRetry: () => setState(() => _future = _load()),
            );
          }
          final models = snapshot.requireData;
          if (models.isEmpty) {
            return const _EmptyPanel(
              message: 'No AI models were discovered from runtime storage.',
            );
          }
          return ListView.separated(
            itemCount: models.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final model = models[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('#${model.id}')),
                  title: Text(model.title),
                  subtitle: Text('Status: ${model.status}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RuntimeStatusScreen extends StatelessWidget {
  final EraRuntimeCapabilities capabilities;

  const RuntimeStatusScreen({super.key, required this.capabilities});

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(title: const Text('Runtime Status')),
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow('Endpoint', capabilities.endpoint),
                  _InfoRow('Chain name', capabilities.chainName),
                  _InfoRow('Spec name', capabilities.specName),
                  _InfoRow('Spec version', capabilities.specVersion.toString()),
                  _InfoRow('Token symbol', kTokenSymbol),
                  _InfoRow('Decimals', kEraDecimals.toString()),
                  _InfoRow(
                    'AI Predictions',
                    capabilities.aiPredictionsAvailable ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    'Market staking',
                    capabilities.sideMarketsAvailable ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    'Fee accounting',
                    capabilities.marketFeesAvailable ? 'Yes' : 'No',
                  ),
                  _InfoRow(
                    'Metadata refreshed',
                    capabilities.metadataRefreshedAt.toIso8601String(),
                  ),
                ],
              ),
            ),
          ),
          if (capabilities.aiPallet != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow('AI pallet', capabilities.aiPallet!.name),
                    _InfoRow(
                      'User calls',
                      capabilities.aiPallet!.callNames
                          .where(
                            (name) =>
                                const [
                                      _stakeCallName,
                                      _unstakeCallName,
                                      _claimCallName,
                                    ]
                                    .map(_normalizeMetadataName)
                                    .contains(_normalizeMetadataName(name)),
                          )
                          .join(', '),
                    ),
                    _InfoRow(
                      'Storage',
                      capabilities.aiPallet!.storageNames.join(', '),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (capabilities.metadataWarnings.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Metadata Review Notes',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    for (final warning in capabilities.metadataWarnings)
                      Text('- $warning'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiPredictionNavigationCard extends StatelessWidget {
  final AiPredictionsSnapshot snapshot;
  final VoidCallback onRefresh;

  const _AiPredictionNavigationCard({
    required this.snapshot,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _NavigationTile(
              icon: Icons.insights,
              title: 'Prediction Markets',
              subtitle: '${snapshot.predictions.length} visible markets',
              onTap: snapshot.capabilities.aiPallet == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PredictionMarketsListScreen(
                          capabilities: snapshot.capabilities,
                        ),
                      ),
                    ),
            ),
            _NavigationTile(
              icon: Icons.account_balance_wallet,
              title: 'My Positions',
              subtitle: '${snapshot.positions.length} local positions',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyPredictionPositionsScreen(),
                ),
              ),
            ),
            _NavigationTile(
              icon: Icons.redeem,
              title: 'My Claims',
              subtitle: '${snapshot.claims.length} claim candidates',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MyPredictionClaimsScreen(),
                ),
              ),
            ),
            _NavigationTile(
              icon: Icons.memory,
              title: 'AI Models',
              subtitle: '${snapshot.models.length} visible models',
              onTap: snapshot.capabilities.aiPallet == null
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AiModelsScreen(capabilities: snapshot.capabilities),
                      ),
                    ),
            ),
            _NavigationTile(
              icon: Icons.health_and_safety,
              title: 'Runtime Status',
              subtitle:
                  '${snapshot.capabilities.specName} v${snapshot.capabilities.specVersion}',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      RuntimeStatusScreen(capabilities: snapshot.capabilities),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final AiPredictionsSnapshot snapshot;

  const _StatsCard({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.insights, size: 16),
              label: Text('${snapshot.predictions.length} markets'),
            ),
            Chip(
              avatar: const Icon(Icons.account_balance_wallet, size: 16),
              label: Text('${snapshot.positions.length} positions'),
            ),
            Chip(
              avatar: const Icon(Icons.redeem, size: 16),
              label: Text('${snapshot.claims.length} claims'),
            ),
            Chip(
              avatar: const Icon(Icons.memory, size: 16),
              label: Text('${snapshot.models.length} models'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuntimeSummaryCard extends StatelessWidget {
  final EraRuntimeCapabilities capabilities;

  const _RuntimeSummaryCard({required this.capabilities});

  @override
  Widget build(BuildContext context) {
    final available = capabilities.aiPredictionsAvailable;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  available ? Icons.check_circle : Icons.warning_amber,
                  color: available ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    available
                        ? 'ERA AI Predictions available'
                        : capabilities.unavailableReason,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(
              'Runtime',
              '${capabilities.specName} v${capabilities.specVersion}',
            ),
            _InfoRow('Chain', capabilities.chainName),
            _InfoRow(
              'Market staking',
              capabilities.sideMarketsAvailable ? 'Yes' : 'No',
            ),
            _InfoRow(
              'Settlement claims',
              capabilities.settlementAvailable ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExperimentalBanner extends StatelessWidget {
  const _ExperimentalBanner();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.withValues(alpha: 0.12),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Prediction risk notice',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text('AI predictions may be incorrect.'),
            Text('Blockchain transactions are irreversible after finality.'),
            Text('Payouts and profits are not guaranteed.'),
            Text('Use only amounts you can afford to lose.'),
          ],
        ),
      ),
    );
  }
}

class _NavigationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _NavigationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      enabled: onTap != null,
      onTap: onTap,
    );
  }
}

class _SideActionButtons extends StatelessWidget {
  final bool submitting;
  final bool enabled;
  final String yesLabel;
  final String noLabel;
  final IconData yesIcon;
  final IconData noIcon;
  final VoidCallback onYes;
  final VoidCallback onNo;

  const _SideActionButtons({
    required this.submitting,
    required this.enabled,
    required this.yesLabel,
    required this.noLabel,
    required this.yesIcon,
    required this.noIcon,
    required this.onYes,
    required this.onNo,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final yesButton = FilledButton.icon(
          icon: Icon(yesIcon),
          label: Text(submitting ? 'Submitting...' : yesLabel),
          onPressed: submitting || !enabled ? null : onYes,
        );
        final noButton = FilledButton.tonalIcon(
          icon: Icon(noIcon),
          label: Text(submitting ? 'Submitting...' : noLabel),
          onPressed: submitting || !enabled ? null : onNo,
        );

        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [yesButton, const SizedBox(height: 8), noButton],
          );
        }

        return Row(
          children: [
            Expanded(child: yesButton),
            const SizedBox(width: 8),
            Expanded(child: noButton),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 132,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: SelectableText(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorPanel({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String message;

  const _EmptyPanel({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(16), child: Text(message)),
    );
  }
}

class PredictionHistoryRef {
  final int predictionId;
  final PredictionOutcomeSide? side;

  const PredictionHistoryRef(this.predictionId, this.side);
}

class _MutableLocalPosition {
  final int predictionId;
  final PredictionOutcomeSide side;
  BigInt staked = BigInt.zero;
  BigInt unstaked = BigInt.zero;
  bool claimed = false;

  _MutableLocalPosition(this.predictionId, this.side);
}

String predictionHistoryRef({
  required int predictionId,
  PredictionOutcomeSide? side,
}) {
  return 'prediction:$predictionId:${side?.name ?? 'none'}';
}

PredictionHistoryRef? parsePredictionHistoryRef(String value) {
  final parts = value.split(':');
  if (parts.length < 3 || parts.first != 'prediction') return null;
  final predictionId = int.tryParse(parts[1]);
  if (predictionId == null) return null;
  final side = switch (parts[2].toLowerCase()) {
    'yes' => PredictionOutcomeSide.yes,
    'no' => PredictionOutcomeSide.no,
    _ => null,
  };
  return PredictionHistoryRef(predictionId, side);
}

Future<BigInt?> _loadFreeBalance(era_api.Era api, String address) async {
  try {
    final keyring = Keyring();
    final publicKey = keyring.decodeAddress(address);
    final accountInfo = await api.query.system.account(
      Uint8List.fromList(publicKey),
    );
    final dynamic freeRaw = accountInfo.data.free;
    return freeRaw is BigInt ? freeRaw : BigInt.parse(freeRaw.toString());
  } catch (e) {
    debugPrint('AI_PREDICTIONS: balance check failed: $e');
    return null;
  }
}

dynamic _decodeStorageValue(
  AiRuntimeStorage storage,
  Uint8List raw,
  polkadart.RuntimeMetadata metadata,
) {
  final typeName = storage.valueTypeName;
  if (typeName == null || typeName.isEmpty) return null;
  try {
    final decoded = metadata.chainInfo.scaleCodec.decode(
      typeName,
      ByteInput(raw),
    );
    return _normalizeMetadataValue(decoded);
  } catch (e) {
    debugPrint(
      'AI_PREDICTIONS: failed to decode ${storage.name} as $typeName: $e',
    );
    return null;
  }
}

Uint8List _storageEntryPrefix(AiRuntimeStorage storage) {
  return polkadart.StorageValue<dynamic>(
    prefix: storage.prefix,
    storage: storage.name,
    valueCodec: NullCodec.codec,
  ).hashedKey();
}

Uint8List? _storageKeyForId(AiRuntimeStorage storage, int id) {
  if (!storage.isMap || storage.keyTypeName == null) return null;
  final codec = _codecForIntegerType(storage.keyTypeName!);
  if (codec == null) return null;
  final key = _coerceIntegerForType(id, storage.keyTypeName!);
  final hasher = _storageHasher(codec, storage.hasherName);
  if (hasher == null) return null;
  return polkadart.StorageMap<dynamic, dynamic>(
    prefix: storage.prefix,
    storage: storage.name,
    hasher: hasher,
    valueCodec: NullCodec.codec,
  ).hashedKeyFor(key);
}

polkadart.StorageHasher<dynamic>? _storageHasher(
  Codec<dynamic> codec,
  String? hasherName,
) {
  final normalized = _normalizeMetadataName(hasherName ?? 'twox64concat');
  if (normalized.contains('blake2128concat')) {
    return polkadart.StorageHasher<dynamic>.blake2b128Concat(codec);
  }
  if (normalized.contains('blake2128')) {
    return polkadart.StorageHasher<dynamic>.blake2b128(codec);
  }
  if (normalized.contains('blake2256')) {
    return polkadart.StorageHasher<dynamic>.blake2b256(codec);
  }
  if (normalized.contains('twox64concat')) {
    return polkadart.StorageHasher<dynamic>.twoxx64Concat(codec);
  }
  if (normalized.contains('twox64')) {
    return polkadart.StorageHasher<dynamic>.twoxx64(codec);
  }
  if (normalized.contains('twox128concat')) {
    return polkadart.StorageHasher<dynamic>.twoxx128Concat(codec);
  }
  if (normalized.contains('twox128')) {
    return polkadart.StorageHasher<dynamic>.twoxx128(codec);
  }
  if (normalized.contains('identity')) {
    return polkadart.StorageHasher<dynamic>.identity(codec);
  }
  return null;
}

Codec<dynamic>? _codecForIntegerType(String typeName) {
  final normalized = _normalizeMetadataName(typeName);
  if (normalized == 'u8') return U8Codec.codec;
  if (normalized == 'u16') return U16Codec.codec;
  if (normalized == 'u32') return U32Codec.codec;
  if (normalized == 'u64') return U64Codec.codec;
  if (normalized == 'u128') return U128Codec.codec;
  if (normalized.contains('predictionid') || normalized.endsWith('id')) {
    return U32Codec.codec;
  }
  return null;
}

dynamic _coerceIntegerForType(int value, String typeName) {
  final normalized = _normalizeMetadataName(typeName);
  if (normalized == 'u64' || normalized == 'u128') {
    return BigInt.from(value);
  }
  return value;
}

int? _tryExtractIdFromKey(Uint8List prefix, Uint8List key) {
  if (key.length <= prefix.length) return null;
  final suffix = key.sublist(prefix.length);
  if (suffix.length >= 4) {
    try {
      return U32Codec.codec.decode(
        ByteInput(Uint8List.fromList(suffix.sublist(suffix.length - 4))),
      );
    } catch (_) {}
  }
  return null;
}

String? _firstText(Map<String, dynamic> fields, Iterable<String> names) {
  for (final name in names) {
    final value = _findField(fields, name);
    final text = _dynamicToDisplayText(value);
    if (text != null && text.isNotEmpty) return text;
  }
  return '';
}

int? _firstInt(Map<String, dynamic> fields, Iterable<String> names) {
  for (final name in names) {
    final value = _findField(fields, name);
    final parsed = _dynamicToInt(value);
    if (parsed != null) return parsed;
  }
  return null;
}

BigInt? _firstAmount(Map<String, dynamic> fields, Iterable<String> names) {
  for (final name in names) {
    final value = _findField(fields, name);
    final parsed = _dynamicToBigInt(value);
    if (parsed != null) return parsed;
  }
  return null;
}

dynamic _findField(Map<String, dynamic> fields, String name) {
  final normalizedTarget = _normalizeMetadataName(name);
  for (final entry in fields.entries) {
    final normalizedKey = _normalizeMetadataName(entry.key);
    if (normalizedKey == normalizedTarget ||
        normalizedKey.contains(normalizedTarget)) {
      return entry.value;
    }
    final value = entry.value;
    if (value is Map<String, dynamic>) {
      final nested = _findField(value, name);
      if (nested != null) return nested;
    }
  }
  return null;
}

String? _dynamicToDisplayText(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is Map && value.length == 1) {
    final key = value.keys.first.toString();
    final nested = value.values.first;
    if (nested == null) return key;
    return '$key ${_dynamicToDisplayText(nested) ?? nested}';
  }
  if (value is List<int> && value.length == 32) {
    try {
      return Keyring().encodeAddress(value);
    } catch (_) {
      return null;
    }
  }
  if (value is Uint8List && value.length == 32) {
    try {
      return Keyring().encodeAddress(value);
    } catch (_) {
      return null;
    }
  }
  return value.toString();
}

int? _dynamicToInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is BigInt) return value.toInt();
  return int.tryParse(value.toString());
}

BigInt? _dynamicToBigInt(dynamic value) {
  if (value == null) return null;
  if (value is BigInt) return value;
  if (value is int) return BigInt.from(value);
  return BigInt.tryParse(value.toString());
}

String _shortHex(Uint8List raw) {
  final hex = encodeHex(raw);
  if (hex.length <= 40) return '0x$hex';
  return '0x${hex.substring(0, 40)}...';
}

dynamic _normalizeMetadataValue(dynamic value) {
  if (value == null) return null;
  if (_isOptionLike(value)) {
    if (_isOptionNone(value)) return null;
    return _normalizeMetadataValue(_optionValue(value));
  }
  if (value is MapEntry) {
    return <String, dynamic>{
      value.key.toString(): _normalizeMetadataValue(value.value),
    };
  }
  if (value is Map) {
    return <String, dynamic>{
      for (final entry in value.entries)
        entry.key.toString(): _normalizeMetadataValue(entry.value),
    };
  }
  if (value is Uint8List) {
    return value.toList(growable: false);
  }
  if (value is List) {
    return value.map(_normalizeMetadataValue).toList(growable: false);
  }
  return value;
}

bool _isOptionLike(dynamic value) {
  try {
    final isSome = value.isSome;
    final isNone = value.isNone;
    return isSome is bool && isNone is bool;
  } catch (_) {
    return false;
  }
}

bool _isOptionNone(dynamic value) {
  try {
    return value.isNone == true;
  } catch (_) {
    return false;
  }
}

dynamic _optionValue(dynamic value) {
  try {
    return value.value;
  } catch (_) {
    return null;
  }
}

String _normalizeMetadataName(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
}

extension on TransferHistoryKind {
  bool get isAiPrediction {
    return this == TransferHistoryKind.aiPredictionStake ||
        this == TransferHistoryKind.aiPredictionUnstake ||
        this == TransferHistoryKind.aiPredictionClaim;
  }
}
