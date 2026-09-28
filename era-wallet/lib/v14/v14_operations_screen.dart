import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:polkadart/polkadart.dart' as polkadart;
import 'package:polkadart/scale_codec.dart' show decodeHex;
import 'package:polkadart_keyring/polkadart_keyring.dart';

import '../era_chain.dart' show formatEra, parseEraToUnits;
import '../era_scaffold.dart';
import '../generated/era/era.dart' as era_api;
import '../phase6b/transaction_lifecycle.dart';
import 'v14_chain_services.dart';
import 'v14_transaction_executor.dart';

final BigInt _approvedOperationFeeCeiling = BigInt.from(5000000000);

enum _NftAction { setPrice, buyItem, createSwap, claimSwap }

class V14OperationsScreen extends StatefulWidget {
  final polkadart.Provider provider;
  final era_api.Era api;
  final String selectedAccount;
  final V14AuthenticateAndLoadMnemonic authenticateAndLoadMnemonic;

  const V14OperationsScreen({
    super.key,
    required this.provider,
    required this.api,
    required this.selectedAccount,
    required this.authenticateAndLoadMnemonic,
  });

  @override
  State<V14OperationsScreen> createState() => _V14OperationsScreenState();
}

class _V14OperationsScreenState extends State<V14OperationsScreen> {
  final _collection = TextEditingController(text: '1');
  final _item = TextEditingController();
  final _secondCollection = TextEditingController(text: '1');
  final _secondItem = TextEditingController();
  final _amount = TextEditingController();
  final _counterparty = TextEditingController();
  final _duration = TextEditingController(text: '100');
  final _rewardEra = TextEditingController();
  final _rewardValidator = TextEditingController();
  final _rewardPage = TextEditingController(text: '0');

  _NftAction _action = _NftAction.setPrice;
  bool _priceSentByOfferer = true;
  bool _busy = false;
  String? _status;
  V14NftSnapshot? _nft;
  SecurityBudgetClaimSnapshot? _reward;

  @override
  void dispose() {
    for (final controller in [
      _collection,
      _item,
      _secondCollection,
      _secondItem,
      _amount,
      _counterparty,
      _duration,
      _rewardEra,
      _rewardValidator,
      _rewardPage,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _readNft() async {
    await _run(() async {
      final collection = _requiredU32(_collection.text, 'Collection');
      final item = _optionalU32(_item.text, 'Item');
      final snapshot =
          await V14NftReader(provider: widget.provider, api: widget.api).read(
            collection: collection,
            item: item,
            selectedAccount: widget.selectedAccount,
          );
      if (!mounted) return;
      setState(() {
        _nft = snapshot;
        _status =
            'Verified metadata at finalized head ${snapshot.finalizedHead}.';
      });
    });
  }

  Future<void> _inspectReward() async {
    await _run(() async {
      final snapshot =
          await SecurityBudgetReader(
            provider: widget.provider,
            api: widget.api,
          ).inspect(
            era: _requiredU32(_rewardEra.text, 'Era'),
            validator: _requiredText(_rewardValidator.text, 'Validator'),
            page: _requiredU32(_rewardPage.text, 'Page'),
          );
      if (!mounted) return;
      setState(() {
        _reward = snapshot;
        _status = snapshot.eligible
            ? 'This finalized reward page passes the native eligibility gate.'
            : 'This finalized reward page is not currently eligible.';
      });
    });
  }

  Future<void> _reviewNftAction() async {
    await _run(() async {
      final plan = _buildNftPlan();
      await _reviewAndSubmit(plan, _nftPostStateVerifier(plan));
    });
  }

  Future<void> _reviewRewardClaim() async {
    await _run(() async {
      final snapshot =
          await SecurityBudgetReader(
            provider: widget.provider,
            api: widget.api,
          ).inspect(
            era: _requiredU32(_rewardEra.text, 'Era'),
            validator: _requiredText(_rewardValidator.text, 'Validator'),
            page: _requiredU32(_rewardPage.text, 'Page'),
          );
      if (!snapshot.eligible) {
        throw StateError('The fresh finalized reward-page gate did not pass.');
      }
      if (mounted) setState(() => _reward = snapshot);
      final plan = V14CallFactory(widget.api).claimRewardPage(
        era: snapshot.era,
        validator: snapshot.validator,
        page: snapshot.page,
      );
      await _reviewAndSubmit(plan, (_) async {
        final after =
            await SecurityBudgetReader(
              provider: widget.provider,
              api: widget.api,
            ).inspect(
              era: snapshot.era,
              validator: snapshot.validator,
              page: snapshot.page,
            );
        return PostStateVerification(
          status: after.claimed
              ? PostStateVerificationStatus.confirmed
              : PostStateVerificationStatus.inconclusive,
          checkedAt: DateTime.now().toUtc(),
          details: {
            'finalizedHead': after.finalizedHead,
            'claimed': after.claimed,
            'eraLiability': after.eraLiability.toString(),
          },
        );
      });
    });
  }

  V14CallPlan _buildNftPlan() {
    final calls = V14CallFactory(widget.api);
    final collection = _requiredU32(_collection.text, 'Collection');
    final item = _requiredU32(_item.text, 'Item');
    return switch (_action) {
      _NftAction.setPrice => calls.setPrice(
        collection: collection,
        item: item,
        price: _optionalEra(_amount.text, 'Price'),
        whitelistedBuyer: _counterparty.text.trim().isEmpty
            ? null
            : _counterparty.text.trim(),
      ),
      _NftAction.buyItem => calls.buyItem(
        collection: collection,
        item: item,
        bidPrice: _requiredEra(_amount.text, 'Bid price'),
      ),
      _NftAction.createSwap => calls.createSwap(
        offeredCollection: collection,
        offeredItem: item,
        desiredCollection: _requiredU32(
          _secondCollection.text,
          'Desired collection',
        ),
        desiredItem: _optionalU32(_secondItem.text, 'Desired item'),
        price: _optionalEra(_amount.text, 'Swap amount'),
        priceSentByOfferer: _priceSentByOfferer,
        duration: _requiredU32(_duration.text, 'Duration'),
      ),
      _NftAction.claimSwap => calls.claimSwap(
        sendCollection: collection,
        sendItem: item,
        receiveCollection: _requiredU32(
          _secondCollection.text,
          'Receive collection',
        ),
        receiveItem: _requiredU32(_secondItem.text, 'Receive item'),
        witnessPrice: _optionalEra(_amount.text, 'Witness amount'),
        priceSentByOfferer: _priceSentByOfferer,
      ),
    };
  }

  TransactionPostStateVerifier _nftPostStateVerifier(V14CallPlan plan) {
    return (_) async {
      final atText = await _finalizedHead();
      final at = _hashBytes(atText);
      final args = plan.arguments;
      bool confirmed = false;
      final details = <String, Object?>{'finalizedHead': atText};
      if (plan.callName == 'set_price') {
        final price = await widget.api.query.nfts.itemPriceOf(
          args['collection']! as int,
          args['item']! as int,
          at: at,
        );
        final expected = args['price'] as String?;
        confirmed = expected == null
            ? price == null
            : price?.value0.toString() == expected;
        details['price'] = price?.value0.toString();
      } else if (plan.callName == 'buy_item') {
        final item = await widget.api.query.nfts.item(
          args['collection']! as int,
          args['item']! as int,
          at: at,
        );
        final owner = item == null
            ? null
            : Keyring().encodeAddress(Uint8List.fromList(item.owner));
        confirmed = owner == widget.selectedAccount;
        details['owner'] = owner;
      } else if (plan.callName == 'create_swap') {
        final swap = await widget.api.query.nfts.pendingSwapOf(
          args['offeredCollection']! as int,
          args['offeredItem']! as int,
          at: at,
        );
        confirmed = swap != null;
        details['pendingSwap'] = swap?.toJson();
      } else if (plan.callName == 'claim_swap') {
        final item = await widget.api.query.nfts.item(
          args['receiveCollection']! as int,
          args['receiveItem']! as int,
          at: at,
        );
        final owner = item == null
            ? null
            : Keyring().encodeAddress(Uint8List.fromList(item.owner));
        final pending = await widget.api.query.nfts.pendingSwapOf(
          args['receiveCollection']! as int,
          args['receiveItem']! as int,
          at: at,
        );
        confirmed = owner == widget.selectedAccount && pending == null;
        details['receivedOwner'] = owner;
        details['pendingSwapCleared'] = pending == null;
      }
      return PostStateVerification(
        status: confirmed
            ? PostStateVerificationStatus.confirmed
            : PostStateVerificationStatus.inconclusive,
        checkedAt: DateTime.now().toUtc(),
        details: details,
      );
    };
  }

  Future<void> _reviewAndSubmit(
    V14CallPlan plan,
    TransactionPostStateVerifier postState,
  ) async {
    final executor = V14TransactionExecutor(
      provider: widget.provider,
      api: widget.api,
    );
    final review = await executor.prepareReview(
      plan: plan,
      signer: widget.selectedAccount,
      authenticateAndLoadMnemonic: widget.authenticateAndLoadMnemonic,
    );
    if (review == null || !mounted) return;
    if (review.estimatedFee > _approvedOperationFeeCeiling) {
      throw StateError(
        'Estimated fee exceeds the approved 0.000000005 ETKN ceiling.',
      );
    }
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review exact ERA V14 transaction'),
        content: SingleChildScrollView(
          child: SelectableText(
            '${review.plan.purpose}\n\n'
            '${review.plan.pallet}.${review.plan.callName}\n'
            '${const JsonEncoder.withIndent('  ').convert(review.plan.arguments)}\n\n'
            'Signer: ${review.signer}\n'
            'Estimated fee: ${formatEra(review.estimatedFee)} ETKN\n'
            'Tip: 0 ETKN\n'
            'Call: ${review.encodedCallHex}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Authenticate and sign once'),
          ),
        ],
      ),
    );
    if (approved != true || !mounted) return;
    final record = await executor.submitReviewed(
      review: review,
      maximumFee: _approvedOperationFeeCeiling,
      authenticateAndLoadMnemonic: widget.authenticateAndLoadMnemonic,
      verifyPostState: postState,
      onUpdate: (record) {
        if (!mounted) return;
        setState(() => _status = 'Transaction state: ${record.state.name}');
      },
    );
    if (!mounted) return;
    setState(() {
      _status = record.state == TransactionLifecycleState.succeeded
          ? 'Finalized and verified: ${record.txHash}'
          : 'Transaction requires reconciliation: ${record.state.name} '
                '${record.txHash ?? ''}';
    });
  }

  Future<String> _finalizedHead() async {
    final response = await widget.provider.send(
      'chain_getFinalizedHead',
      const [],
    );
    if (response.error != null || response.result is! String) {
      throw StateError('The finalized ERA head is unavailable.');
    }
    return response.result! as String;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _status = 'Stopped safely: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: EraScaffold(
        appBar: AppBar(
          title: const Text('ERA V14 Assets & Rewards'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'NFT read'),
              Tab(text: 'NFT actions'),
              Tab(text: 'Rewards'),
            ],
          ),
        ),
        body: Column(
          children: [
            if (_status != null)
              MaterialBanner(
                content: SelectableText(_status!),
                actions: [
                  TextButton(
                    onPressed: () => setState(() => _status = null),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            Expanded(
              child: TabBarView(
                children: [_nftReadTab(), _nftActionTab(), _rewardTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nftReadTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Reads ownership and metadata at one finalized block. Only the four '
        'approved IPFS objects are accepted, fetched over HTTPS, length-checked '
        'and SHA-256 verified.',
      ),
      const SizedBox(height: 12),
      _numberField(_collection, 'Collection'),
      const SizedBox(height: 8),
      _numberField(_item, 'Item (leave blank for collection metadata)'),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _busy ? null : _readNft,
        child: const Text('Read finalized NFT'),
      ),
      if (_nft != null) ...[
        const SizedBox(height: 16),
        SelectableText(
          'Owner: ${_nft!.owner}\n'
          'Selected account owns it: ${_nft!.ownedBySelectedAccount}\n'
          'URI: ${_nft!.metadataUri}\n'
          'SHA-256: ${_nft!.metadata.sha256}\n'
          'Metadata:\n${const JsonEncoder.withIndent('  ').convert(_nft!.metadata.json)}',
        ),
      ],
    ],
  );

  Widget _nftActionTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      DropdownButtonFormField<_NftAction>(
        initialValue: _action,
        decoration: const InputDecoration(labelText: 'Approved NFT action'),
        items: _NftAction.values
            .map(
              (value) =>
                  DropdownMenuItem(value: value, child: Text(value.name)),
            )
            .toList(),
        onChanged: _busy
            ? null
            : (value) => setState(() => _action = value ?? _action),
      ),
      const SizedBox(height: 8),
      _numberField(_collection, 'Collection / send collection'),
      const SizedBox(height: 8),
      _numberField(_item, 'Item / send item'),
      if (_action == _NftAction.createSwap ||
          _action == _NftAction.claimSwap) ...[
        const SizedBox(height: 8),
        _numberField(_secondCollection, 'Desired / receive collection'),
        const SizedBox(height: 8),
        _numberField(_secondItem, 'Desired / receive item'),
      ],
      const SizedBox(height: 8),
      TextField(
        controller: _amount,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          labelText:
              'Price / bid / witness amount in ETKN (optional where allowed)',
        ),
      ),
      if (_action == _NftAction.setPrice) ...[
        const SizedBox(height: 8),
        TextField(
          controller: _counterparty,
          decoration: const InputDecoration(
            labelText: 'Whitelisted buyer (optional)',
          ),
        ),
      ],
      if (_action == _NftAction.createSwap) ...[
        const SizedBox(height: 8),
        _numberField(_duration, 'Swap duration in blocks'),
      ],
      if (_action == _NftAction.createSwap || _action == _NftAction.claimSwap)
        SwitchListTile(
          title: const Text('Price is sent by the offerer'),
          value: _priceSentByOfferer,
          onChanged: _busy
              ? null
              : (value) => setState(() => _priceSentByOfferer = value),
        ),
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _busy ? null : _reviewNftAction,
        child: const Text('Estimate, review and sign once'),
      ),
    ],
  );

  Widget _rewardTab() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const Text(
        'Uses SecurityBudget.claim_reward_page. It does not use '
        'Staking.payout_stakers and it never selects recipients.',
      ),
      const SizedBox(height: 12),
      _numberField(_rewardEra, 'Completed era'),
      const SizedBox(height: 8),
      TextField(
        controller: _rewardValidator,
        decoration: const InputDecoration(labelText: 'Historical validator'),
      ),
      const SizedBox(height: 8),
      _numberField(_rewardPage, 'Exposure page'),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: _busy ? null : _inspectReward,
        child: const Text('Inspect finalized eligibility'),
      ),
      if (_reward != null) ...[
        const SizedBox(height: 12),
        SelectableText(
          'Eligible: ${_reward!.eligible}\n'
          'Points: ${_reward!.eligiblePoints}\n'
          'Page count: ${_reward!.pageCount}\n'
          'Era liability: ${formatEra(_reward!.eraLiability)} ETKN\n'
          'Claimed: ${_reward!.claimed}\nExpired: ${_reward!.expired}',
        ),
      ],
      const SizedBox(height: 12),
      FilledButton(
        onPressed: _busy ? null : _reviewRewardClaim,
        child: const Text('Recheck, review and claim once'),
      ),
    ],
  );

  TextField _numberField(TextEditingController controller, String label) =>
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label),
      );
}

String _requiredText(String value, String label) {
  final text = value.trim();
  if (text.isEmpty) throw FormatException('$label is required.');
  return text;
}

int _requiredU32(String value, String label) {
  final parsed = _optionalU32(value, label);
  if (parsed == null) throw FormatException('$label is required.');
  return parsed;
}

int? _optionalU32(String value, String label) {
  final text = value.trim();
  if (text.isEmpty) return null;
  if (!RegExp(r'^(0|[1-9][0-9]*)$').hasMatch(text)) {
    throw FormatException('$label must be an unsigned integer.');
  }
  final number = BigInt.parse(text);
  if (number > BigInt.from(0xffffffff)) {
    throw RangeError('$label exceeds u32.');
  }
  return number.toInt();
}

BigInt _requiredEra(String value, String label) {
  final amount = _optionalEra(value, label);
  if (amount == null || amount <= BigInt.zero) {
    throw FormatException('$label must be greater than zero.');
  }
  return amount;
}

BigInt? _optionalEra(String value, String label) {
  final text = value.trim();
  if (text.isEmpty) return null;
  final amount = parseEraToUnits(text);
  if (amount == null || amount.isNegative) {
    throw FormatException('$label is not a valid ETKN amount.');
  }
  return amount;
}

Uint8List _hashBytes(String value) {
  final normalized = value.startsWith('0x') ? value.substring(2) : value;
  return Uint8List.fromList(decodeHex(normalized));
}
