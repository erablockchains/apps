import 'dart:convert';
import 'dart:typed_data';

import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' as scale;
import 'package:polkadart_keyring/polkadart_keyring.dart';

import '../generated/era/era.dart' as era_api;
import '../generated/era/types/era_runtime/runtime_call.dart' as runtime_call;
import '../generated/era/types/pallet_nfts/types/price_direction.dart'
    as price_direction;
import '../generated/era/types/pallet_nfts/types/price_with_direction.dart'
    as nft_price;
import '../generated/era/types/pallet_staking/validator_prefs.dart'
    as validator_prefs;
import '../generated/era/types/sp_staking/exposure.dart' as staking_exposure;
import '../generated/era/types/sp_staking/paged_exposure_metadata.dart'
    as paged_exposure;
import '../generated/era/types/sp_runtime/multiaddress/multi_address.dart'
    as multi_address;
import 'approved_nft_metadata.dart';

class V14NftSnapshot {
  final String finalizedHead;
  final int collection;
  final int? item;
  final String owner;
  final bool ownedBySelectedAccount;
  final String metadataUri;
  final VerifiedNftMetadata metadata;
  final BigInt? price;
  final String? whitelistedBuyer;
  final Map<String, Object?>? pendingSwap;

  const V14NftSnapshot({
    required this.finalizedHead,
    required this.collection,
    required this.item,
    required this.owner,
    required this.ownedBySelectedAccount,
    required this.metadataUri,
    required this.metadata,
    this.price,
    this.whitelistedBuyer,
    this.pendingSwap,
  });
}

class V14NftReader {
  final polkadart.Provider provider;
  final era_api.Era api;
  final ApprovedNftMetadataResolver resolver;
  final Keyring keyring;

  V14NftReader({
    required this.provider,
    required this.api,
    ApprovedNftMetadataResolver? resolver,
    Keyring? keyring,
  }) : resolver = resolver ?? ApprovedNftMetadataResolver(),
       keyring = keyring ?? Keyring();

  Future<V14NftSnapshot> read({
    required int collection,
    int? item,
    String? selectedAccount,
  }) async {
    final finalizedHead = await _finalizedHead(provider);
    final at = _hashBytes(finalizedHead);
    if (item == null) {
      final results = await Future.wait([
        api.query.nfts.collection(collection, at: at),
        api.query.nfts.collectionMetadataOf(collection, at: at),
      ]);
      final details = results[0] as dynamic;
      final metadataRecord = results[1] as dynamic;
      if (details == null) throw StateError('NFT collection does not exist.');
      if (metadataRecord == null) {
        throw StateError('NFT collection has no metadata reference.');
      }
      final owner = keyring.encodeAddress(
        Uint8List.fromList((details.owner as List<int>)),
      );
      final uri = utf8.decode(
        List<int>.from(metadataRecord.data as List),
        allowMalformed: false,
      );
      return V14NftSnapshot(
        finalizedHead: finalizedHead,
        collection: collection,
        item: null,
        owner: owner,
        ownedBySelectedAccount: owner == selectedAccount,
        metadataUri: uri,
        metadata: await resolver.resolve(uri),
      );
    }

    final results = await Future.wait([
      api.query.nfts.item(collection, item, at: at),
      api.query.nfts.itemMetadataOf(collection, item, at: at),
      api.query.nfts.itemPriceOf(collection, item, at: at),
      api.query.nfts.pendingSwapOf(collection, item, at: at),
    ]);
    final details = results[0] as dynamic;
    final metadataRecord = results[1] as dynamic;
    final priceRecord = results[2] as dynamic;
    final swapRecord = results[3] as dynamic;
    if (details == null) throw StateError('NFT item does not exist.');
    if (metadataRecord == null) {
      throw StateError('NFT item has no metadata reference.');
    }
    final owner = keyring.encodeAddress(
      Uint8List.fromList((details.owner as List<int>)),
    );
    final uri = utf8.decode(
      List<int>.from(metadataRecord.data as List),
      allowMalformed: false,
    );
    String? buyer;
    if (priceRecord?.value1 != null) {
      buyer = keyring.encodeAddress(
        Uint8List.fromList(priceRecord.value1 as List<int>),
      );
    }
    return V14NftSnapshot(
      finalizedHead: finalizedHead,
      collection: collection,
      item: item,
      owner: owner,
      ownedBySelectedAccount: owner == selectedAccount,
      metadataUri: uri,
      metadata: await resolver.resolve(uri),
      price: priceRecord?.value0 as BigInt?,
      whitelistedBuyer: buyer,
      pendingSwap: swapRecord == null
          ? null
          : Map<String, Object?>.from(swapRecord.toJson() as Map),
    );
  }
}

class SecurityBudgetClaimSnapshot {
  final String finalizedHead;
  final bool active;
  final bool allocationPaused;
  final int? activeEra;
  final int? firstEligibleEra;
  final int era;
  final String validator;
  final int page;
  final int eligiblePoints;
  final BigInt eraBudget;
  final BigInt eraLiability;
  final BigInt exposureTotal;
  final BigInt exposureOwn;
  final int pageCount;
  final BigInt commissionPerbill;
  final bool claimed;
  final bool expired;

  const SecurityBudgetClaimSnapshot({
    required this.finalizedHead,
    required this.active,
    required this.allocationPaused,
    required this.activeEra,
    required this.firstEligibleEra,
    required this.era,
    required this.validator,
    required this.page,
    required this.eligiblePoints,
    required this.eraBudget,
    required this.eraLiability,
    required this.exposureTotal,
    required this.exposureOwn,
    required this.pageCount,
    required this.commissionPerbill,
    required this.claimed,
    required this.expired,
  });

  bool get eligible =>
      active &&
      !allocationPaused &&
      firstEligibleEra != null &&
      era >= firstEligibleEra! &&
      activeEra != null &&
      era < activeEra! &&
      eligiblePoints > 0 &&
      eraBudget > BigInt.zero &&
      eraLiability > BigInt.zero &&
      exposureTotal > BigInt.zero &&
      page >= 0 &&
      page < pageCount &&
      !claimed &&
      !expired;
}

class SecurityBudgetReader {
  final polkadart.Provider provider;
  final era_api.Era api;
  final Keyring keyring;

  SecurityBudgetReader({
    required this.provider,
    required this.api,
    Keyring? keyring,
  }) : keyring = keyring ?? Keyring();

  Future<SecurityBudgetClaimSnapshot> inspect({
    required int era,
    required String validator,
    required int page,
  }) async {
    if (era < 0 || page < 0) {
      throw ArgumentError('Era and page must be unsigned.');
    }
    final validatorBytes = Uint8List.fromList(keyring.decodeAddress(validator));
    final finalizedHead = await _finalizedHead(provider);
    final at = _hashBytes(finalizedHead);
    final mapReader = FinalizedTwox64ConcatMapReader(api.rpc.state);
    final values = await Future.wait([
      api.query.securityBudget.active(at: at),
      api.query.securityBudget.allocationPaused(at: at),
      api.query.securityBudget.firstEligibleEra(at: at),
      api.query.securityBudget.eraBudgets(era, at: at),
      api.query.securityBudget.eraLiability(era, at: at),
      api.query.securityBudget.expiredEras(era, at: at),
      api.query.staking.activeEra(at: at),
    ]);
    final mapValues = await Future.wait([
      mapReader.read(
        prefix: api.query.securityBudget.eligibleValidatorPointsMapPrefix(era),
        encodedKey: validatorBytes,
        at: at,
      ),
      mapReader.read(
        prefix: api.query.securityBudget.claimedPagesMapPrefix(era),
        encodedKey: Uint8List.fromList([
          ...validatorBytes,
          ..._u32LittleEndian(page),
        ]),
        at: at,
      ),
      mapReader.read(
        prefix: api.query.staking.erasStakersOverviewMapPrefix(era),
        encodedKey: validatorBytes,
        at: at,
      ),
      mapReader.read(
        prefix: api.query.staking.erasStakersClippedMapPrefix(era),
        encodedKey: validatorBytes,
        at: at,
      ),
      mapReader.read(
        prefix: api.query.staking.erasValidatorPrefsMapPrefix(era),
        encodedKey: validatorBytes,
        at: at,
      ),
    ]);
    final budget = values[3] as dynamic;
    final eligiblePoints = mapValues[0] == null
        ? 0
        : scale.U32Codec.codec.decode(scale.ByteInput(mapValues[0]!));
    final overview = mapValues[2] == null
        ? null
        : paged_exposure.PagedExposureMetadata.codec.decode(
            scale.ByteInput(mapValues[2]!),
          );
    final clipped = mapValues[3] == null
        ? null
        : staking_exposure.Exposure.codec.decode(
            scale.ByteInput(mapValues[3]!),
          );
    final prefs = mapValues[4] == null
        ? validator_prefs.ValidatorPrefs(
            commission: BigInt.zero,
            blocked: false,
          )
        : validator_prefs.ValidatorPrefs.codec.decode(
            scale.ByteInput(mapValues[4]!),
          );
    final exposureTotal = overview?.total ?? clipped?.total ?? BigInt.zero;
    final exposureOwn = overview?.own ?? clipped?.own ?? BigInt.zero;
    final pageCount = overview == null
        ? (clipped == null ? 0 : 1)
        : (overview.pageCount == 0 && overview.own > BigInt.zero
              ? 1
              : overview.pageCount);
    return SecurityBudgetClaimSnapshot(
      finalizedHead: finalizedHead,
      active: values[0] as bool,
      allocationPaused: values[1] as bool,
      firstEligibleEra: values[2] as int?,
      activeEra: (values[6] as dynamic)?.index as int?,
      era: era,
      validator: validator,
      page: page,
      eligiblePoints: eligiblePoints,
      eraBudget: (budget?.total as BigInt?) ?? BigInt.zero,
      eraLiability: values[4] as BigInt,
      exposureTotal: exposureTotal,
      exposureOwn: exposureOwn,
      pageCount: pageCount,
      commissionPerbill: prefs.commission,
      claimed: mapValues[1] != null,
      expired: values[5] != null,
    );
  }
}

/// Reads a finalized `Twox64Concat` map value by its encoded key suffix.
///
/// Polkadart 0.7.1 reconstructs the eight-byte hash for AccountId32 keys
/// differently from the deployed ERA runtime. Prefix pagination plus the exact
/// encoded suffix keeps these safety-critical reads pinned to the real key.
class FinalizedTwox64ConcatMapReader {
  final polkadart.StateApi state;

  const FinalizedTwox64ConcatMapReader(this.state);

  Future<Uint8List?> read({
    required Uint8List prefix,
    required Uint8List encodedKey,
    required polkadart.BlockHash at,
    int maximumEntries = 1024,
  }) async {
    if (maximumEntries < 1 || maximumEntries > 1024) {
      throw ArgumentError.value(maximumEntries, 'maximumEntries');
    }
    final expectedLength = prefix.length + 8 + encodedKey.length;
    Uint8List? match;
    Uint8List? startKey;
    var scanned = 0;
    while (true) {
      final remaining = maximumEntries - scanned;
      final count = remaining < 128 ? remaining : 128;
      final keys = await state.getKeysPaged(
        key: prefix,
        count: count,
        startKey: startKey,
        at: at,
      );
      if (keys.isEmpty) break;
      var leftPrefix = false;
      for (final key in keys) {
        if (!_startsWith(key, prefix)) {
          leftPrefix = true;
          break;
        }
        scanned++;
        if (key.length == expectedLength && _endsWith(key, encodedKey)) {
          if (match != null) {
            throw StateError('Ambiguous finalized Twox64Concat storage key.');
          }
          match = key;
        }
      }
      if (leftPrefix || keys.length < count) break;
      startKey = keys.last;
      if (scanned >= maximumEntries) {
        final next = await state.getKeysPaged(
          key: prefix,
          count: 1,
          startKey: startKey,
          at: at,
        );
        if (next.isNotEmpty && _startsWith(next.first, prefix)) {
          throw StateError('Finalized Twox64Concat map exceeds safety bound.');
        }
        break;
      }
    }
    return match == null ? null : state.getStorage(match, at: at);
  }
}

class V14CallPlan {
  final String pallet;
  final String callName;
  final String purpose;
  final Map<String, Object?> arguments;
  final runtime_call.RuntimeCall call;

  const V14CallPlan({
    required this.pallet,
    required this.callName,
    required this.purpose,
    required this.arguments,
    required this.call,
  });
}

class V14CallFactory {
  final era_api.Era api;
  final Keyring keyring;

  V14CallFactory(this.api, {Keyring? keyring}) : keyring = keyring ?? Keyring();

  V14CallPlan setPrice({
    required int collection,
    required int item,
    required BigInt? price,
    String? whitelistedBuyer,
  }) {
    final buyer = whitelistedBuyer == null || whitelistedBuyer.trim().isEmpty
        ? null
        : multi_address.Id(
            Uint8List.fromList(keyring.decodeAddress(whitelistedBuyer.trim())),
          );
    return V14CallPlan(
      pallet: 'Nfts',
      callName: 'set_price',
      purpose: price == null
          ? 'Remove the NFT sale listing'
          : 'List the NFT for sale',
      arguments: {
        'collection': collection,
        'item': item,
        'price': price?.toString(),
        'whitelistedBuyer': whitelistedBuyer?.trim(),
      },
      call: api.tx.nfts.setPrice(
        collection: collection,
        item: item,
        price: price,
        whitelistedBuyer: buyer,
      ),
    );
  }

  V14CallPlan buyItem({
    required int collection,
    required int item,
    required BigInt bidPrice,
  }) => V14CallPlan(
    pallet: 'Nfts',
    callName: 'buy_item',
    purpose: 'Buy the listed NFT',
    arguments: {
      'collection': collection,
      'item': item,
      'bidPrice': bidPrice.toString(),
    },
    call: api.tx.nfts.buyItem(
      collection: collection,
      item: item,
      bidPrice: bidPrice,
    ),
  );

  V14CallPlan createSwap({
    required int offeredCollection,
    required int offeredItem,
    required int desiredCollection,
    int? desiredItem,
    BigInt? price,
    bool priceSentByOfferer = true,
    required int duration,
  }) => V14CallPlan(
    pallet: 'Nfts',
    callName: 'create_swap',
    purpose: 'Create an NFT swap offer',
    arguments: {
      'offeredCollection': offeredCollection,
      'offeredItem': offeredItem,
      'desiredCollection': desiredCollection,
      'desiredItem': desiredItem,
      'price': price?.toString(),
      'priceDirection': price == null
          ? null
          : (priceSentByOfferer ? 'Send' : 'Receive'),
      'duration': duration,
    },
    call: api.tx.nfts.createSwap(
      offeredCollection: offeredCollection,
      offeredItem: offeredItem,
      desiredCollection: desiredCollection,
      maybeDesiredItem: desiredItem,
      maybePrice: price == null
          ? null
          : nft_price.PriceWithDirection(
              amount: price,
              direction: priceSentByOfferer
                  ? price_direction.PriceDirection.send
                  : price_direction.PriceDirection.receive,
            ),
      duration: duration,
    ),
  );

  V14CallPlan claimSwap({
    required int sendCollection,
    required int sendItem,
    required int receiveCollection,
    required int receiveItem,
    BigInt? witnessPrice,
    bool priceSentByOfferer = true,
  }) => V14CallPlan(
    pallet: 'Nfts',
    callName: 'claim_swap',
    purpose: 'Claim the reviewed NFT swap offer',
    arguments: {
      'sendCollection': sendCollection,
      'sendItem': sendItem,
      'receiveCollection': receiveCollection,
      'receiveItem': receiveItem,
      'witnessPrice': witnessPrice?.toString(),
      'priceDirection': witnessPrice == null
          ? null
          : (priceSentByOfferer ? 'Send' : 'Receive'),
    },
    call: api.tx.nfts.claimSwap(
      sendCollection: sendCollection,
      sendItem: sendItem,
      receiveCollection: receiveCollection,
      receiveItem: receiveItem,
      witnessPrice: witnessPrice == null
          ? null
          : nft_price.PriceWithDirection(
              amount: witnessPrice,
              direction: priceSentByOfferer
                  ? price_direction.PriceDirection.send
                  : price_direction.PriceDirection.receive,
            ),
    ),
  );

  V14CallPlan claimRewardPage({
    required int era,
    required String validator,
    required int page,
  }) => V14CallPlan(
    pallet: 'SecurityBudget',
    callName: 'claim_reward_page',
    purpose: 'Claim one eligible V14 SecurityBudget reward page',
    arguments: {'era': era, 'validator': validator, 'page': page},
    call: api.tx.securityBudget.claimRewardPage(
      era: era,
      validator: Uint8List.fromList(keyring.decodeAddress(validator)),
      page: page,
    ),
  );
}

Future<String> _finalizedHead(polkadart.Provider provider) async {
  final response = await provider.send('chain_getFinalizedHead', const []);
  if (response.error != null || response.result is! String) {
    throw StateError('The finalized ERA head is unavailable.');
  }
  return response.result! as String;
}

Uint8List _hashBytes(String value) {
  final normalized = value.startsWith('0x') ? value.substring(2) : value;
  return Uint8List.fromList(scale.decodeHex(normalized));
}

Uint8List _u32LittleEndian(int value) {
  if (value < 0 || value > 0xffffffff) {
    throw ArgumentError.value(value, 'value');
  }
  final bytes = Uint8List(4);
  ByteData.sublistView(bytes).setUint32(0, value, Endian.little);
  return bytes;
}

bool _startsWith(List<int> value, List<int> prefix) {
  if (value.length < prefix.length) return false;
  for (var index = 0; index < prefix.length; index++) {
    if (value[index] != prefix[index]) return false;
  }
  return true;
}

bool _endsWith(List<int> value, List<int> suffix) {
  if (value.length < suffix.length) return false;
  final offset = value.length - suffix.length;
  for (var index = 0; index < suffix.length; index++) {
    if (value[offset + index] != suffix[index]) return false;
  }
  return true;
}
