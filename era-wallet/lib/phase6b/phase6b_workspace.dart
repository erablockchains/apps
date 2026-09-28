import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:polkadart_keyring/polkadart_keyring.dart';
import 'package:polkadart/scale_codec.dart' show decodeHex;
import 'package:provider/provider.dart' as flutter_provider;
import 'package:share_plus/share_plus.dart' show ShareResultStatus;

import '../accounts_flow.dart';
import '../auth_flow.dart';
import '../era_chain.dart';
import '../era_scaffold.dart';
import '../generated/era/era.dart' as era_api;
import '../generated/era/types/pallet_ai_predictions/prediction_domain.dart';
import '../generated/era/types/pallet_ai_predictions/prediction_outcome.dart';
import '../generated/era/types/pallet_ai_predictions/prediction_outcome_side.dart';
import '../generated/era/types/pallet_ai_predictions/settlement_outcome.dart';
import 'chain_reconciliation.dart';
import 'finalized_receipt.dart';
import 'phase6b_actions.dart';
import 'phase6b_data.dart';
import 'phase6b_validation.dart';
import 'report_export.dart';
import 'runtime_compatibility.dart';
import 'runtime_probe.dart';
import 'test_report.dart';
import 'test_session.dart';
import 'transaction_lifecycle.dart';
import 'transaction_runner.dart';

List<String> phase6bWorkspaceSections({
  bool testingToolsEnabled = enablePhase6bTestingTools,
}) => [
  'Overview',
  'Models',
  'Predictions',
  'Markets',
  'My Positions',
  'Claims',
  if (testingToolsEnabled) 'Operator Lab',
  'Diagnostics',
  if (testingToolsEnabled) 'Test Reports',
];

class Phase6bWorkspaceScreen extends StatefulWidget {
  const Phase6bWorkspaceScreen({super.key});

  @override
  State<Phase6bWorkspaceScreen> createState() => _Phase6bWorkspaceScreenState();
}

class _Phase6bWorkspaceScreenState extends State<Phase6bWorkspaceScreen>
    with WidgetsBindingObserver {
  static const _testSessionStorageKey =
      'phase6b_controlled_test_session_checkpoint_v1';

  Phase6bRuntimeDiagnostics? _diagnostics;
  Phase6bChainConfiguration? _configuration;
  Phase6bPage<Phase6bModel>? _models;
  Phase6bPage<Phase6bPrediction>? _predictions;
  Phase6bPage<Phase6bMarket>? _markets;
  Phase6bPage<Phase6bPosition>? _positions;
  Phase6bReconciliationResult? _history;
  List<TransactionLifecycleRecord> _journal = const [];
  TransactionLifecycleRecord? _latestReceipt;
  Phase6bTestSession? _testSession;
  Map<String, BigInt> _sessionStartingBalances = const {};
  Map<String, BigInt> _sessionLatestBalances = const {};
  Phase6bMarketTotalsObservation? _sessionMarketTotals;
  Phase6bMarket? _sessionBaselineMarket;
  Phase6bMarket? _sessionLatestMarket;
  Phase6bPosition? _sessionClaimPosition;
  Phase6bTestReport? _completedReport;
  final Map<String, Phase6bPendingCallEvidence> _pendingSessionEvidence = {};
  Future<void> _sessionCheckpointWriteQueue = Future<void>.value();
  int _sessionCheckpointWritesInFlight = 0;
  String? _sessionPersistenceError;
  String? _sessionModelId;
  String? _sessionPredictionId;
  String? _sessionMarketId;
  bool _exportingReport = false;
  bool _intentFlowActive = false;
  bool _sessionStageTransitionActive = false;
  bool _loading = true;
  String? _error;
  int _modelOffset = 0;
  int _predictionOffset = 0;
  int _marketOffset = 0;
  int _positionOffset = 0;
  String? _positionAccountAddress;
  String _modelStatusFilter = 'All';
  String _modelQuery = '';

  final _modelSearchController = TextEditingController();

  List<String> get _sections => phase6bWorkspaceSections();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _restoreTestSessionCheckpoint();
      if (mounted) await _refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _modelSearchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _modelSearchController.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      unawaited(_persistTestSessionCheckpoint());
    }
  }

  Future<void> _restoreTestSessionCheckpoint() async {
    String? encoded;
    try {
      encoded = await secureStorage.read(key: _testSessionStorageKey);
      if (encoded == null) return;
      final checkpoint = Phase6bTestSessionCheckpoint.decode(encoded);
      if (!mounted) return;
      setState(() {
        _testSession = checkpoint.session;
        _sessionStartingBalances = checkpoint.startingBalances;
        _sessionLatestBalances = checkpoint.latestBalances;
        _sessionModelId = checkpoint.modelId;
        _sessionPredictionId = checkpoint.predictionId;
        _sessionMarketId = checkpoint.marketId;
        _sessionMarketTotals = checkpoint.marketTotals == null
            ? null
            : Phase6bMarketTotalsObservation(
                yesBeforeBaseUnits: checkpoint.marketTotals!.yesBeforeBaseUnits,
                yesAfterBaseUnits: checkpoint.marketTotals!.yesAfterBaseUnits,
                noBeforeBaseUnits: checkpoint.marketTotals!.noBeforeBaseUnits,
                noAfterBaseUnits: checkpoint.marketTotals!.noAfterBaseUnits,
                tokenSymbol: checkpoint.marketTotals!.tokenSymbol,
              );
        _sessionBaselineMarket = checkpoint.baselineMarket == null
            ? null
            : _marketFromCheckpoint(checkpoint.baselineMarket!);
        _sessionLatestMarket = checkpoint.latestMarket == null
            ? null
            : _marketFromCheckpoint(checkpoint.latestMarket!);
        _sessionClaimPosition = checkpoint.claimPosition == null
            ? null
            : _positionFromCheckpoint(checkpoint.claimPosition!);
        _completedReport = checkpoint.completedReport == null
            ? null
            : _reportFromCheckpoint(checkpoint.completedReport!);
        _pendingSessionEvidence
          ..clear()
          ..addEntries(
            checkpoint.pendingCalls.map(
              (pending) => MapEntry(pending.recordId, pending),
            ),
          );
        _sessionPersistenceError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _sessionPersistenceError =
            'Stored controlled-session evidence could not be validated and '
            'was not restored: $error';
      });
    }
  }

  Future<bool> _persistTestSessionCheckpoint() async {
    final session = _testSession;
    if (session == null) return true;
    _sessionCheckpointWritesInFlight++;
    if (mounted) setState(() {});
    try {
      final checkpoint = Phase6bTestSessionCheckpoint(
        savedAt: DateTime.now().toUtc(),
        session: session,
        startingBalances: _sessionStartingBalances,
        latestBalances: _sessionLatestBalances,
        modelId: _sessionModelId,
        predictionId: _sessionPredictionId,
        marketId: _sessionMarketId,
        marketTotals: _sessionMarketTotals == null
            ? null
            : Phase6bPersistedMarketTotals.fromJson(
                _sessionMarketTotals!.toJson(),
              ),
        baselineMarket: _sessionBaselineMarket == null
            ? null
            : Phase6bPersistedMarketEvidence.fromJson(
                _sessionBaselineMarket!.toJson(),
              ),
        latestMarket: _sessionLatestMarket == null
            ? null
            : Phase6bPersistedMarketEvidence.fromJson(
                _sessionLatestMarket!.toJson(),
              ),
        claimPosition: _sessionClaimPosition == null
            ? null
            : Phase6bPersistedPositionEvidence.fromJson(
                _sessionClaimPosition!.toJson(),
              ),
        pendingCalls: _pendingSessionEvidence.values.toList(growable: false),
        completedReport: _completedReport == null
            ? null
            : Phase6bCompletedReportSnapshot.fromJson(
                _completedReport!.toJson(),
              ),
      );
      final encoded = checkpoint.encode();
      final write = _sessionCheckpointWriteQueue.then<void>(
        (_) => secureStorage.write(key: _testSessionStorageKey, value: encoded),
      );
      _sessionCheckpointWriteQueue = write.catchError((Object _) {});
      await write;
      if (mounted && _sessionPersistenceError != null) {
        setState(() => _sessionPersistenceError = null);
      }
      return true;
    } catch (error) {
      if (mounted) {
        setState(() {
          _sessionPersistenceError =
              'Controlled-session evidence is not durably saved. Further '
              'session actions are blocked: $error';
        });
      }
      return false;
    } finally {
      _sessionCheckpointWritesInFlight--;
      if (mounted) setState(() {});
    }
  }

  bool get _sessionCheckpointBusy => _sessionCheckpointWritesInFlight > 0;

  Phase6bMarket _marketFromCheckpoint(Phase6bPersistedMarketEvidence evidence) {
    return Phase6bMarket(
      tokenId: evidence.tokenId,
      predictionId: evidence.predictionId,
      owner: evidence.owner,
      metadataReference: evidence.metadataReference,
      createdAt: evidence.createdAt,
      transferable: evidence.transferable,
      frozen: evidence.frozen,
      burned: evidence.burned,
      locked: evidence.locked,
      yesTotal: evidence.yesTotal,
      noTotal: evidence.noTotal,
      settlementStatus: evidence.settlementStatus,
      proposedOutcome: evidence.proposedOutcome,
      finalOutcome: evidence.finalOutcome,
      disputeUntil: evidence.disputeUntil,
      totalStakeAtFinalization: evidence.totalStakeAtFinalization,
      feesCollected: evidence.feesCollected,
      remaindersCollected: evidence.remaindersCollected,
      totalPaid: evidence.totalPaid,
      totalRefunded: evidence.totalRefunded,
      totalSlashed: evidence.totalSlashed,
      provenance: Phase6bDataProvenance.canonicalStorage,
    );
  }

  Phase6bPosition _positionFromCheckpoint(
    Phase6bPersistedPositionEvidence evidence,
  ) {
    return Phase6bPosition(
      tokenId: evidence.tokenId,
      predictionId: evidence.predictionId,
      account: evidence.account,
      side: evidence.side,
      amount: evidence.amount,
      stakedAt: evidence.stakedAt,
      updatedAt: evidence.updatedAt,
      claimed: evidence.claimed,
      stakeReturned: evidence.stakeReturned,
      rewardPaid: evidence.rewardPaid,
      slashed: evidence.slashed,
      provenance: Phase6bDataProvenance.canonicalStorage,
    );
  }

  Phase6bTestReport _reportFromCheckpoint(
    Phase6bCompletedReportSnapshot snapshot,
  ) {
    final data = snapshot.data;
    Map<String, Object?> objectMap(Object? value) =>
        Map<String, Object?>.from(value! as Map);
    int? optionalInt(String key) => data[key] as int?;
    String? optionalString(String key) => data[key] as String?;
    final balances = (data['balancesBeforeAfter']! as List)
        .map(objectMap)
        .map(
          (item) => Phase6bBalanceObservation(
            publicAddress: item['publicAddress']! as String,
            beforeBaseUnits: BigInt.parse(item['beforeBaseUnits']! as String),
            afterBaseUnits: BigInt.parse(item['afterBaseUnits']! as String),
            tokenSymbol: item['tokenSymbol']! as String,
          ),
        )
        .toList(growable: false);
    final totalsData = data['yesNoTotalsBeforeAfter'];
    final totals = totalsData == null
        ? null
        : Phase6bPersistedMarketTotals.fromJson(totalsData);
    final feeObservations = (data['treasuryAndFeeObservations']! as List)
        .map(objectMap)
        .map(
          (item) => Phase6bTreasuryFeeObservation(
            label: item['label']! as String,
            before: item['before']! as String,
            after: item['after']! as String,
            detail: item['detail']! as String,
          ),
        )
        .toList(growable: false);
    return Phase6bTestReport(
      walletAppVersion: data['walletAppVersion']! as String,
      platform: data['platform']! as String,
      endpoint: data['endpoint']! as String,
      genesisHash: data['genesisHash']! as String,
      runtimeSpecName: data['runtimeSpecName']! as String,
      runtimeSpecVersion: data['runtimeSpecVersion']! as int,
      transactionVersion: optionalInt('transactionVersion'),
      metadataVersion: optionalInt('metadataVersion'),
      metadataFingerprint: data['metadataFingerprint']! as String,
      runtimeWasmHash: optionalString('runtimeWasmHash'),
      aiStorageVersion: optionalInt('aiStorageVersion'),
      aiPalletIndex: optionalInt('aiPalletIndex'),
      testSessionId: data['testSessionId']! as String,
      startedAt: DateTime.parse(data['startTimestamp']! as String),
      endedAt: DateTime.parse(data['endTimestamp']! as String),
      participatingPublicAddresses: List<String>.from(
        data['participatingPublicAddresses']! as List,
      ),
      modelId: optionalString('modelId'),
      predictionId: optionalString('predictionId'),
      marketId: optionalString('marketId'),
      stages: (data['stages']! as List)
          .map(Phase6bStageRecord.fromJson)
          .toList(growable: false),
      balanceObservations: balances,
      marketTotals: totals == null
          ? null
          : Phase6bMarketTotalsObservation(
              yesBeforeBaseUnits: totals.yesBeforeBaseUnits,
              yesAfterBaseUnits: totals.yesAfterBaseUnits,
              noBeforeBaseUnits: totals.noBeforeBaseUnits,
              noAfterBaseUnits: totals.noAfterBaseUnits,
              tokenSymbol: totals.tokenSymbol,
            ),
      treasuryAndFeeObservations: feeObservations,
      settlementResult: data['settlementResult']! as String,
      claimResult: data['claimResult']! as String,
      postStateVerification: data['postStateVerification']! as String,
      warnings: List<String>.from(data['warnings']! as List),
      additionalEvidence: Map<String, Object?>.from(
        data['additionalEvidence']! as Map,
      ),
    );
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final wallet = flutter_provider.Provider.of<EraWalletProvider>(
        context,
        listen: false,
      );
      final accounts = flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      );
      if (!await wallet.ensureConnected() ||
          wallet.provider == null ||
          wallet.api == null) {
        throw StateError(
          wallet.connectionError ?? 'Unable to connect to ERA-MAINNET.',
        );
      }
      final provider = wallet.provider!;
      final api = wallet.api!;
      final active = accounts.active;
      final probe = Phase6bRuntimeProbe(provider: provider, api: api);
      final diagnostics = await probe.refresh(activeAccount: active?.address);
      final journal = Phase6bTransactionJournal(storage: secureStorage);
      final pendingStartup = await journal.prepareStartupReconciliation();
      final allJournal = await journal.load();
      if (!_intentFlowActive && _pendingSessionEvidence.isNotEmpty) {
        final journalIds = allJournal.map((record) => record.id).toSet();
        final unsubmitted = _pendingSessionEvidence.keys
            .where((recordId) => !journalIds.contains(recordId))
            .toList(growable: false);
        if (unsubmitted.isNotEmpty && mounted) {
          setState(() {
            for (final recordId in unsubmitted) {
              _pendingSessionEvidence.remove(recordId);
            }
          });
          await _persistTestSessionCheckpoint();
        }
      }
      final phase6bDataSupported = const {
        Phase6bCapabilityLevel.phase6bParticipant,
        Phase6bCapabilityLevel.phase6bOperator,
      }.contains(diagnostics.compatibility.level);
      if (!phase6bDataSupported) {
        if (!mounted) return;
        setState(() {
          _diagnostics = diagnostics;
          _configuration = null;
          _models = null;
          _predictions = null;
          _markets = null;
          _positions = null;
          _history = null;
          _journal = allJournal;
          _latestReceipt = allJournal.firstOrNull;
          _loading = false;
          _error = pendingStartup.isNotEmpty
              ? '${pendingStartup.length} transaction(s) require chain '
                    'verification before any retry.'
              : null;
        });
        return;
      }
      final repository = Phase6bChainRepository(api);
      if (_positionAccountAddress != active?.address) {
        _positionOffset = 0;
        _positionAccountAddress = active?.address;
      }
      final results = await Future.wait<Object>([
        repository.loadConfiguration(accountAddress: active?.address),
        repository.loadModels(offset: _modelOffset),
        repository.loadPredictions(offset: _predictionOffset),
        repository.loadMarkets(offset: _marketOffset),
        if (active != null)
          repository.loadPositions(
            accountAddress: active.address,
            offset: _positionOffset,
          )
        else
          Future.value(
            const Phase6bPage<Phase6bPosition>(
              items: [],
              offset: 0,
              limit: 25,
              totalAvailable: 0,
            ),
          ),
      ]);
      Phase6bReconciliationResult? history;
      try {
        history = await Phase6bChainReconciler(
          PolkadartPhase6bFinalizedSource(provider: provider, api: api),
        ).reconcile(blockLookback: 60, eventLimit: 150);
      } catch (error) {
        history = Phase6bReconciliationResult(
          events: const [],
          requestedFrom: 0,
          requestedThrough: diagnostics.latestFinalizedBlock,
          unavailableBlocks: [diagnostics.latestFinalizedBlock],
          warnings: ['Finalized event reconciliation failed: $error'],
        );
      }
      if (!mounted) return;
      setState(() {
        _diagnostics = diagnostics;
        _configuration = results[0] as Phase6bChainConfiguration;
        _models = results[1] as Phase6bPage<Phase6bModel>;
        _predictions = results[2] as Phase6bPage<Phase6bPrediction>;
        _markets = results[3] as Phase6bPage<Phase6bMarket>;
        _positions = results[4] as Phase6bPage<Phase6bPosition>;
        _history = history;
        _journal = allJournal;
        _latestReceipt = allJournal.isEmpty ? null : allJournal.first;
        _loading = false;
        if (pendingStartup.isNotEmpty) {
          _error =
              '${pendingStartup.length} transaction(s) require chain '
              'verification before any retry.';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _diagnostics = null;
        _configuration = null;
        _models = null;
        _predictions = null;
        _markets = null;
        _positions = null;
        _history = null;
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataReady =
        _configuration != null &&
        _models != null &&
        _predictions != null &&
        _markets != null &&
        _positions != null;
    return DefaultTabController(
      length: _sections.length,
      child: EraScaffold(
        appBar: AppBar(
          title: const Text('AI Predictions'),
          actions: [
            IconButton(
              tooltip: 'Refresh chain state',
              onPressed: _loading || _intentFlowActive ? null : _refresh,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: dataReady
              ? TabBar(
                  isScrollable: true,
                  tabs: [for (final section in _sections) Tab(text: section)],
                )
              : null,
        ),
        body: Column(
          children: [
            if (enablePhase6bTestingTools) const _ControlledTestingBanner(),
            const _ParticipantRiskBanner(),
            if (_loading) const LinearProgressIndicator(),
            if (_error != null)
              MaterialBanner(
                content: Text(_error!),
                actions: [
                  TextButton(onPressed: _refresh, child: const Text('Refresh')),
                ],
              ),
            Expanded(
              child: _diagnostics == null
                  ? _EmptyState(
                      icon: Icons.cloud_off,
                      title: 'Runtime state unavailable',
                      body: _error ?? 'Connect to ERA-MAINNET and refresh.',
                    )
                  : !dataReady
                  ? _compatibilityUnavailableView()
                  : TabBarView(
                      children: [
                        _overviewTab(),
                        _modelsTab(),
                        _predictionsTab(),
                        _marketsTab(),
                        _positionsTab(),
                        _claimsTab(),
                        if (enablePhase6bTestingTools) _operatorTab(),
                        _diagnosticsTab(),
                        if (enablePhase6bTestingTools) _reportsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compatibilityUnavailableView() {
    final diagnostics = _diagnostics!;
    final legacy =
        diagnostics.compatibility.level ==
        Phase6bCapabilityLevel.phase6aParticipant;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(
          title: legacy
              ? 'Legacy Phase 6A participant runtime'
              : 'Phase 6B signing unavailable',
          rows: {
            'Chain': diagnostics.chainName,
            'Genesis': diagnostics.genesisHash,
            'Runtime': '${diagnostics.specName}/${diagnostics.specVersion}',
            'Metadata SHA-256': diagnostics.metadataHash,
            'Compatibility': diagnostics.compatibility.level.label,
          },
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(diagnostics.compatibility.explanation),
                if (legacy) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'The spec-13 repository is not used on legacy metadata. '
                    'Spec 8 is read-only in this build; legacy transaction '
                    'signing is not exposed.',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _overviewTab() {
    final diagnostics = _diagnostics!;
    final accounts = flutter_provider.Provider.of<AccountManager>(context);
    final unresolved = _journal
        .where(
          (record) =>
              record.state ==
              TransactionLifecycleState.unknownNeedsVerification,
        )
        .length;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _CompatibilityCard(diagnostics: diagnostics),
          _InfoCard(
            title: 'Live ERA runtime',
            rows: {
              'Endpoint': diagnostics.endpoint,
              'Connection': 'Connected',
              'Chain': diagnostics.chainName,
              'Genesis': diagnostics.genesisHash,
              'Runtime':
                  '${diagnostics.specName} v${diagnostics.specVersion} '
                  '(tx ${diagnostics.transactionVersion})',
              'AI pallet':
                  'AiPredictions #12, storage v${diagnostics.aiStorageVersion ?? '?'}',
              'Latest finalized': '${diagnostics.latestFinalizedBlock}',
              'Active account': accounts.active?.address ?? 'None',
              'Account label': accounts.active?.name ?? 'None',
              'ETKN balance':
                  '${formatEra(diagnostics.freeBalance)} $kTokenSymbol',
              'Role assessment': _roleAssessment(accounts.active?.address),
              'Pending / unresolved':
                  '${_journal.where((record) => record.protectsAgainstDuplicate).length} / $unresolved',
            },
          ),
          if (_configuration != null)
            _InfoCard(
              title: 'Phase 6B chain configuration',
              rows: {
                'Model registration': _yesNo(
                  _configuration!.modelRegistrationEnabled,
                ),
                'Public registration': _yesNo(
                  _configuration!.publicModelRegistrationEnabled,
                ),
                'Model approval required': _yesNo(
                  _configuration!.requireModelApproval,
                ),
                'Prediction submission': _yesNo(
                  _configuration!.predictionSubmissionEnabled,
                ),
                'Market creation': _yesNo(
                  _configuration!.marketCreationEnabled,
                ),
                'Tokenization': _yesNo(_configuration!.tokenizationEnabled),
                'Token transfers': _yesNo(_configuration!.transfersEnabled),
                'Settlement': _yesNo(_configuration!.settlementEnabled),
                'Settlement economics': _yesNo(
                  _configuration!.settlementEconomicsEnabled,
                ),
                'Active account validator': _yesNo(
                  _configuration!.signerIsAuthorizedValidator,
                ),
                'Side markets': _yesNo(_configuration!.marketEnabled),
                'Minimum stake':
                    '${formatEra(_configuration!.minimumStake)} ETKN',
                'Market fee': _configuration!.feesEnabled
                    ? '${_configuration!.feeBps} bps'
                    : 'Disabled',
              },
            ),
          if (_latestReceipt != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.receipt_long),
                title: const Text('Latest finalized receipt'),
                subtitle: Text(
                  '${_latestReceipt!.pallet}.${_latestReceipt!.call} — '
                  '${_latestReceipt!.state.name}',
                ),
                onTap: () => _openReceipt(_latestReceipt!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _modelsTab() {
    final page = _models;
    if (page == null) return const SizedBox.shrink();
    final query = _modelQuery.trim().toLowerCase();
    final visible = page.items.where((model) {
      final statusMatch =
          _modelStatusFilter == 'All' ||
          model.governanceStatus == _modelStatusFilter;
      final queryMatch =
          query.isEmpty ||
          model.id.toString() == query ||
          model.owner.toLowerCase().contains(query) ||
          model.metadataReference.toLowerCase().contains(query);
      return statusMatch && queryMatch;
    }).toList();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          TextField(
            controller: _modelSearchController,
            decoration: const InputDecoration(
              labelText: 'Search model ID, owner, or metadata reference',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _modelQuery = value),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final status in const [
                'All',
                'Pending',
                'Approved',
                'Suspended',
                'Rejected',
              ])
                FilterChip(
                  label: Text(status),
                  selected: _modelStatusFilter == status,
                  onSelected: (_) =>
                      setState(() => _modelStatusFilter = status),
                ),
            ],
          ),
          _PageNotice(
            offset: page.offset,
            shown: page.items.length,
            total: page.totalAvailable,
            onPrevious: page.offset == 0
                ? null
                : () {
                    setState(
                      () => _modelOffset = (_modelOffset - page.limit).clamp(
                        0,
                        page.totalAvailable,
                      ),
                    );
                    _refresh();
                  },
            onNext: page.hasMore
                ? () {
                    setState(() => _modelOffset += page.limit);
                    _refresh();
                  }
                : null,
          ),
          if (visible.isEmpty)
            const _EmptyState(
              icon: Icons.memory,
              title: 'No matching models',
              body: 'No canonical model record matches this page and filter.',
            )
          else
            for (final model in visible)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('#${model.id}')),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(_displayReference(model.metadataReference)),
                      ),
                      _StatusChip(model.governanceStatus),
                    ],
                  ),
                  subtitle: Text(
                    '${model.owner}\n${model.activePredictions} active / '
                    '${model.totalPredictions} total predictions',
                  ),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showModel(model),
                ),
              ),
        ],
      ),
    );
  }

  Widget _predictionsTab() {
    final page = _predictions!;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _PageNotice(
            offset: page.offset,
            shown: page.items.length,
            total: page.totalAvailable,
            onPrevious: page.offset == 0
                ? null
                : () {
                    setState(
                      () => _predictionOffset = (_predictionOffset - page.limit)
                          .clamp(0, page.totalAvailable),
                    );
                    _refresh();
                  },
            onNext: page.hasMore
                ? () {
                    setState(() => _predictionOffset += page.limit);
                    _refresh();
                  }
                : null,
          ),
          if (page.items.isEmpty)
            const _EmptyState(
              icon: Icons.insights,
              title: 'No predictions',
              body: 'No canonical prediction records exist on this page.',
            )
          else
            for (final prediction in page.items)
              Card(
                child: ExpansionTile(
                  leading: CircleAvatar(child: Text('#${prediction.id}')),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _displayReference(prediction.metadataReference),
                        ),
                      ),
                      _StatusChip(prediction.status),
                    ],
                  ),
                  subtitle: Text(
                    'Model #${prediction.modelId} • ${prediction.domain} • '
                    '${prediction.isTokenized ? 'Token #${prediction.tokenId}' : 'Not tokenized'}',
                  ),
                  children: [
                    _InfoRows(
                      rows: {
                        'Submitter': prediction.submitter,
                        'Category': prediction.categoryCode,
                        'Confidence': '${prediction.confidence}%',
                        'Created / expires':
                            '${prediction.createdAt} / ${prediction.expiresAt}',
                        'Outcome': prediction.outcome ?? 'None',
                        'Validator': prediction.validator ?? 'None',
                        'Hash': prediction.predictionHashHex,
                      },
                    ),
                    if (enablePhase6bTestingTools)
                      _predictionActions(prediction),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _marketsTab() {
    final page = _markets!;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _PageNotice(
            offset: page.offset,
            shown: page.items.length,
            total: page.totalAvailable,
            onPrevious: page.offset == 0
                ? null
                : () {
                    setState(
                      () => _marketOffset = (_marketOffset - page.limit).clamp(
                        0,
                        page.totalAvailable,
                      ),
                    );
                    _refresh();
                  },
            onNext: page.hasMore
                ? () {
                    setState(() => _marketOffset += page.limit);
                    _refresh();
                  }
                : null,
          ),
          if (page.items.isEmpty)
            const _EmptyState(
              icon: Icons.candlestick_chart,
              title: 'No tokenized markets',
              body: 'No canonical prediction-token markets exist on this page.',
            )
          else
            for (final market in page.items) _marketCard(market),
        ],
      ),
    );
  }

  Widget _positionsTab() {
    final page = _positions!;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _PageNotice(
            offset: page.offset,
            shown: page.coveredCount,
            total: page.totalAvailable,
            onPrevious: page.offset == 0
                ? null
                : () {
                    setState(
                      () => _positionOffset = (_positionOffset - page.limit)
                          .clamp(0, page.totalAvailable),
                    );
                    _refresh();
                  },
            onNext: page.hasMore
                ? () {
                    setState(() => _positionOffset += page.limit);
                    _refresh();
                  }
                : null,
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Reconcile from chain'),
              subtitle: Text(
                page.historyComplete
                    ? 'Canonical storage page reconciled.'
                    : page.limitation ?? 'Chain data is incomplete.',
              ),
              trailing: FilledButton.tonal(
                onPressed: _refresh,
                child: const Text('Reconcile'),
              ),
            ),
          ),
          if (page.items.isEmpty)
            const _EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No chain-derived positions',
              body:
                  'No side stake or payout claim was found in this bounded '
                  'canonical storage scan.',
            )
          else
            for (final position in page.items)
              Card(
                child: ListTile(
                  leading: _StatusChip(position.side),
                  title: Text('Market #${position.tokenId}'),
                  subtitle: Text(
                    '${formatEra(position.amount)} ETKN • '
                    '${position.claimed ? 'Claimed' : 'Unclaimed'}\n'
                    'Canonical chain storage',
                  ),
                  isThreeLine: true,
                ),
              ),
        ],
      ),
    );
  }

  Widget _claimsTab() {
    final positions = _positions!.items;
    final marketById = {
      for (final market in _markets!.items) market.tokenId: market,
    };
    final candidates = positions.where((position) {
      final market = marketById[position.tokenId];
      return position.claimed ||
          (market != null &&
              Phase6bLifecyclePolicy.canClaim(
                market: market,
                position: position,
              ));
    }).toList();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (candidates.isEmpty)
            const _EmptyState(
              icon: Icons.redeem,
              title: 'No chain-derived claims',
              body:
                  'Claims appear after canonical settlement state is finalized.',
            )
          else
            for (final position in candidates)
              Card(
                child: ListTile(
                  leading: Icon(
                    position.claimed ? Icons.done_all : Icons.redeem,
                  ),
                  title: Text('Market #${position.tokenId} • ${position.side}'),
                  subtitle: Text(
                    position.claimed
                        ? 'Returned ${formatEra(position.stakeReturned)} ETKN; '
                              'reward ${formatEra(position.rewardPaid)} ETKN; '
                              'slashed ${formatEra(position.slashed)} ETKN.'
                        : 'Settlement finalized. Chain dispatch remains '
                              'authoritative about payout eligibility.',
                  ),
                  trailing: position.claimed
                      ? const _StatusChip('Claimed')
                      : FilledButton(
                          onPressed: () => _submitIntent(
                            Phase6bCallFactory(
                              _walletApi,
                            ).claim(position.tokenId),
                          ),
                          child: const Text('Claim'),
                        ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _operatorTab() {
    final flags = const Phase6bBuildFlags.fromEnvironment();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const _ControlledTestingBanner(inline: true),
        _InfoCard(
          title: 'Build-time controls',
          rows: {
            'ENABLE_PHASE6B_TESTING_TOOLS': flags.testingToolsEnabled
                .toString(),
            'ENABLE_PHASE6B_GOVERNANCE_ACTIONS': flags.governanceActionsEnabled
                .toString(),
            'Batch live transactions': 'Forbidden',
            'Authentication': 'Required before every operator submission',
          },
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.add_task),
            title: const Text('Model onboarding wizard'),
            subtitle: const Text(
              'Seven reviewed stages using spec-13 register_model fields.',
            ),
            enabled: _canSignOperator,
            onTap: _canSignOperator ? _startModelOnboarding : null,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.add_chart),
            title: const Text('Prediction creation wizard'),
            subtitle: const Text(
              'Selects active eligible owner/delegated models from canonical '
              'configuration.',
            ),
            enabled: _canSignOperator,
            onTap: _canSignOperator ? _startPredictionCreation : null,
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.science_outlined),
            title: const Text('Controlled test session'),
            subtitle: const Text(
              'Fifteen stages; every live call is reviewed and confirmed separately.',
            ),
            enabled:
                !_exportingReport &&
                !_intentFlowActive &&
                !_sessionStageTransitionActive &&
                !_sessionCheckpointBusy &&
                _sessionPersistenceError == null,
            onTap:
                _exportingReport ||
                    _intentFlowActive ||
                    _sessionStageTransitionActive ||
                    _sessionCheckpointBusy ||
                    _sessionPersistenceError != null
                ? null
                : _testSession == null
                ? _startTestSession
                : _restartTestSession,
          ),
        ),
        if (!flags.governanceActionsEnabled)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Governance actions are not compiled into this build. Model '
                'approval, suspension, rejection, delegation changes, and '
                'privileged settlement controls remain hidden.',
              ),
            ),
          ),
      ],
    );
  }

  Widget _diagnosticsTab() {
    final diagnostics = _diagnostics!;
    final unresolved = _journal
        .where(
          (record) =>
              record.state ==
              TransactionLifecycleState.unknownNeedsVerification,
        )
        .length;
    final json = diagnostics.exportJson(
      pendingTransactions: _journal
          .where((record) => record.protectsAgainstDuplicate)
          .length,
      unresolvedTransactions: unresolved,
    );
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => _copyText(json, 'Diagnostics copied.'),
              icon: const Icon(Icons.copy),
              label: const Text('Copy diagnostics'),
            ),
            OutlinedButton.icon(
              onPressed: _refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh metadata'),
            ),
          ],
        ),
        _InfoCard(
          title: 'Runtime fingerprint',
          rows: {
            'Endpoint': diagnostics.endpoint,
            'Chain': diagnostics.chainName,
            'Genesis': diagnostics.genesisHash,
            'Spec': '${diagnostics.specName} ${diagnostics.specVersion}',
            'Transaction version': '${diagnostics.transactionVersion}',
            'Metadata':
                'v${diagnostics.metadataVersion} ${diagnostics.metadataHash}',
            'AI pallet': 'AiPredictions #12',
            'AI storage version': '${diagnostics.aiStorageVersion}',
            'Best / finalized':
                '${diagnostics.latestBestBlock} / ${diagnostics.latestFinalizedBlock}',
            'Peers / syncing':
                '${diagnostics.peerCount} / ${diagnostics.syncing}',
            'Compatibility': diagnostics.compatibility.level.label,
            'Last refresh': diagnostics.refreshedAt.toIso8601String(),
          },
        ),
        _InfoCard(
          title: 'Discovered calls and indices',
          rows: {
            for (final call in diagnostics.discoveredCalls)
              call.split(':').first: call
                  .substring(call.indexOf(':') + 1)
                  .trim(),
          },
        ),
        _InfoCard(
          title: 'Discovered storage',
          rows: {
            for (var i = 0; i < diagnostics.discoveredStorage.length; i++)
              '${i + 1}': diagnostics.discoveredStorage[i],
          },
        ),
        if (_history != null)
          _InfoCard(
            title: 'Finalized history reconciliation',
            rows: {
              'Status': _history!.completenessLabel,
              'Window':
                  '${_history!.requestedFrom}–${_history!.requestedThrough}',
              'AI events': '${_history!.events.length}',
              'Unavailable blocks': _history!.unavailableBlocks.join(', '),
              'Warnings': _history!.warnings.join('\n'),
            },
          ),
        for (final record in _journal.where(
          (record) =>
              const {
                TransactionLifecycleState.submitted,
                TransactionLifecycleState.inBlock,
                TransactionLifecycleState.finalized,
                TransactionLifecycleState.unknownNeedsVerification,
              }.contains(record.state) ||
              _pendingSessionEvidence.containsKey(record.id),
        ))
          Card(
            child: ListTile(
              leading: const Icon(Icons.manage_search),
              title: Text('${record.pallet}.${record.call}'),
              subtitle: Text(
                '${record.state.name} - ${record.txHash ?? 'hash unavailable'}\n'
                'No retry is permitted until this check is conclusive.',
              ),
              isThreeLine: true,
              trailing: FilledButton.tonal(
                onPressed:
                    _intentFlowActive ||
                        _sessionCheckpointBusy ||
                        (_pendingSessionEvidence.containsKey(record.id) &&
                            _sessionPersistenceError != null)
                    ? null
                    : () => _verifyJournalRecord(record),
                child: const Text('Verify'),
              ),
            ),
          ),
        ExpansionTile(
          title: const Text('Technical JSON'),
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(json),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reportsTab() {
    final session = _testSession;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.science_outlined),
            title: Text(
              session == null
                  ? 'No active test session'
                  : 'Session ${session.sessionId}',
            ),
            subtitle: Text(
              session == null
                  ? 'Start a controlled session to collect lifecycle evidence.'
                  : '${session.records.length}/15 stages • '
                        '${session.overallOutcome.label}',
            ),
            trailing: FilledButton.tonal(
              onPressed:
                  _exportingReport ||
                      _intentFlowActive ||
                      _sessionStageTransitionActive ||
                      _sessionCheckpointBusy ||
                      _sessionPersistenceError != null
                  ? null
                  : session == null
                  ? _startTestSession
                  : _restartTestSession,
              child: Text(session == null ? 'Start' : 'Restart'),
            ),
          ),
        ),
        if (_sessionPersistenceError != null)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              leading: const Icon(Icons.lock_clock_outlined),
              title: const Text('Secure session checkpoint unavailable'),
              subtitle: Text(_sessionPersistenceError!),
              trailing: session == null
                  ? null
                  : FilledButton.tonal(
                      onPressed: _sessionCheckpointBusy
                          ? null
                          : _persistTestSessionCheckpoint,
                      child: const Text('Retry save'),
                    ),
            ),
          ),
        for (final definition in Phase6bTestLifecycle.stages)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${definition.number}')),
              title: Text(definition.title),
              subtitle: Text(
                '${definition.actionKind.name} • '
                '${session?.records.where((record) => record.stage == definition.stage).firstOrNull?.outcome.label ?? 'Not run'}\n'
                '${_testStageInstruction(definition)}',
              ),
              isThreeLine: true,
              trailing: session?.nextStage == definition.stage
                  ? _testStageControl(definition)
                  : null,
            ),
          ),
        if (session != null)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (_canFinalizeFailedTestSession)
                FilledButton.icon(
                  onPressed: _sessionStageTransitionActive
                      ? null
                      : () => _runSessionStageTransition(
                          _finalizeFailedTestSessionForExport,
                        ),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Finalize failed run'),
                ),
              FilledButton.icon(
                onPressed: () => _copyText(
                  (_completedReport ?? _buildCurrentReport()).copySummary,
                  'Report summary copied.',
                ),
                icon: const Icon(Icons.copy),
                label: const Text('Copy summary'),
              ),
              OutlinedButton.icon(
                onPressed:
                    _exportingReport ||
                        _intentFlowActive ||
                        _sessionStageTransitionActive ||
                        _sessionCheckpointBusy ||
                        kIsWeb
                    ? null
                    : _saveReport,
                icon: const Icon(Icons.save_alt),
                label: Text(
                  kIsWeb ? 'Save unavailable on web' : 'Save JSON + Markdown',
                ),
              ),
              OutlinedButton.icon(
                onPressed:
                    _exportingReport ||
                        _intentFlowActive ||
                        _sessionStageTransitionActive ||
                        _sessionCheckpointBusy
                    ? null
                    : _shareReport,
                icon: const Icon(Icons.share),
                label: const Text('Share report'),
              ),
            ],
          ),
      ],
    );
  }

  String _testStageInstruction(Phase6bTestStageDefinition definition) =>
      switch (definition.stage) {
        Phase6bTestStage.selectTestAccounts ||
        Phase6bTestStage.verifyBalancesAndRuntime ||
        Phase6bTestStage.refreshAndVerifyAccounting ||
        Phase6bTestStage.verifyFinalBalancesAndTreasury =>
          'Refresh canonical chain state, then record the check.',
        Phase6bTestStage.configureDelegation =>
          'Use AiPredictions.set_model_submitter, or prove it is not required.',
        Phase6bTestStage.onboardModel => 'AiPredictions.register_model',
        Phase6bTestStage.approveModel => 'AiPredictions.approve_model',
        Phase6bTestStage.createPrediction => 'AiPredictions.submit_prediction',
        Phase6bTestStage.createOrTokenizeMarket =>
          'AiPredictions.tokenize_prediction',
        Phase6bTestStage.stakeYesFromAccountA ||
        Phase6bTestStage.stakeNoFromAccountB =>
          'AiPredictions.stake_on_prediction_outcome_side',
        Phase6bTestStage.validateOrClosePrediction =>
          'AiPredictions.validate_prediction or close_prediction',
        Phase6bTestStage.settleMarket =>
          'Finalize only after a separately reviewed proposal/dispute window.',
        Phase6bTestStage.claimWinningPayout =>
          'AiPredictions.claim_prediction_market_payout',
        Phase6bTestStage.exportReport =>
          'Save redacted JSON and Markdown to finish the session.',
      };

  bool get _canFinalizeFailedTestSession {
    final session = _testSession;
    return session != null &&
        !session.isFinished &&
        session.nextStage != null &&
        session.nextStage != Phase6bTestStage.exportReport &&
        session.records.any(
          (record) => record.outcome == Phase6bTestOutcome.fail,
        ) &&
        _pendingSessionEvidence.isEmpty &&
        !_journal.any((record) => record.protectsAgainstDuplicate) &&
        _sessionPersistenceError == null &&
        !_sessionCheckpointBusy;
  }

  Future<void> _finalizeFailedTestSessionForExport() async {
    if (!_canFinalizeFailedTestSession) return;
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Finalize failed session?'),
            content: const Text(
              'This submits no transactions. Every remaining lifecycle stage '
              'before export will be recorded as BLOCKED by the prior failure, '
              'then the redacted final report can be exported.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Record blocked stages'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted || !_canFinalizeFailedTestSession) return;
    final session = _testSession!;
    final recordedAt = DateTime.now().toUtc();
    setState(() {
      var sequence = 0;
      while (session.nextStage != null &&
          session.nextStage != Phase6bTestStage.exportReport) {
        final stage = session.nextStage!;
        final checks = _sessionPrerequisiteChecks(stage);
        session.recordStage(
          Phase6bStageRecord(
            stage: stage,
            prerequisiteChecks: checks.any((check) => !check.passed)
                ? checks
                : [
                    Phase6bPrerequisiteCheck(
                      name: 'Prior controlled-session failure',
                      passed: false,
                      evidence: 'A previous lifecycle stage recorded FAIL.',
                    ),
                  ],
            exactCall: 'Wallet.blocked.${stage.name}',
            confirmation: Phase6bActionConfirmation.notRequired(
              statement: 'No transaction submitted; stage blocked.',
            ),
            chainStateVerification: Phase6bChainStateVerification.notPerformed(
              summary: 'Not performed because a prerequisite stage failed.',
            ),
            outcome: Phase6bTestOutcome.blocked,
            notes: 'Deliberately closed without a transaction after failure.',
            warnings: const [
              'This stage contains no live transaction evidence.',
            ],
            completedAt: recordedAt.add(Duration(microseconds: sequence++)),
          ),
        );
      }
    });
    if (await _persistTestSessionCheckpoint()) {
      _showMessage(
        'Remaining stages were recorded BLOCKED without transactions. '
        'Export stage 15 to freeze the failed-session report.',
      );
    }
  }

  Widget? _testStageControl(Phase6bTestStageDefinition definition) {
    if (definition.actionKind == Phase6bStageActionKind.readOnly) {
      return FilledButton.tonal(
        onPressed:
            _sessionPersistenceError == null &&
                !_sessionCheckpointBusy &&
                !_sessionStageTransitionActive
            ? () => _runSessionStageTransition(
                () => _recordReadOnlyTestStage(definition.stage),
              )
            : null,
        child: const Text('Verify'),
      );
    }
    if (definition.stage == Phase6bTestStage.configureDelegation) {
      return FilledButton.tonal(
        onPressed:
            _sessionPersistenceError == null &&
                !_sessionCheckpointBusy &&
                !_sessionStageTransitionActive
            ? () => _runSessionStageTransition(_recordDelegationNotRequired)
            : null,
        child: const Text('Not needed'),
      );
    }
    if (definition.stage == Phase6bTestStage.approveModel) {
      return FilledButton.tonal(
        onPressed:
            _sessionPersistenceError == null &&
                !_sessionCheckpointBusy &&
                !_sessionStageTransitionActive
            ? () => _runSessionStageTransition(_recordApprovalNotRequired)
            : null,
        child: const Text('Not required'),
      );
    }
    if (definition.stage == Phase6bTestStage.exportReport) {
      return FilledButton.tonal(
        onPressed:
            _exportingReport ||
                _sessionCheckpointBusy ||
                _sessionStageTransitionActive ||
                _sessionPersistenceError != null
            ? null
            : kIsWeb
            ? _shareReport
            : _saveReport,
        child: Text(kIsWeb ? 'Share / download' : 'Export'),
      );
    }
    return const Icon(Icons.arrow_forward);
  }

  Widget _predictionActions(Phase6bPrediction prediction) {
    final factory = Phase6bCallFactory(_walletApi);
    final testingEnabled =
        _diagnostics?.compatibility.testingToolsEnabled == true;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (testingEnabled && prediction.isOpen && !prediction.isTokenized)
            FilledButton.tonal(
              onPressed: () => _tokenizePrediction(prediction),
              child: const Text('Tokenize market'),
            ),
          if (testingEnabled && prediction.isOpen)
            OutlinedButton(
              onPressed: () => _validatePrediction(prediction),
              child: const Text('Validate outcome'),
            ),
          if (testingEnabled && (prediction.isOpen || prediction.isValidated))
            OutlinedButton(
              onPressed: () =>
                  _submitIntent(factory.closePrediction(prediction.id)),
              child: const Text('Close'),
            ),
        ],
      ),
    );
  }

  Widget _marketCard(Phase6bMarket market) {
    final position = _positionFor(market.tokenId);
    final canStake = Phase6bLifecyclePolicy.canStake(
      market: market,
      config: _configuration!,
    );
    final canUnstake = Phase6bLifecyclePolicy.canUnstake(
      market: market,
      config: _configuration!,
      position: position,
    );
    return Card(
      child: ExpansionTile(
        leading: CircleAvatar(child: Text('#${market.tokenId}')),
        title: Row(
          children: [
            Expanded(child: Text('Prediction #${market.predictionId}')),
            _StatusChip(market.settlementStatus),
          ],
        ),
        subtitle: Text(
          'YES ${formatEra(market.yesTotal)} • NO ${formatEra(market.noTotal)} ETKN',
        ),
        children: [
          _InfoRows(
            rows: {
              'Owner': market.owner,
              'Locked': _yesNo(market.locked),
              'Total escrow/stake': '${formatEra(market.totalStake)} ETKN',
              'Final outcome': market.finalOutcome ?? 'Not finalized',
              'Fees collected': '${formatEra(market.feesCollected)} ETKN',
              'Total paid': '${formatEra(market.totalPaid)} ETKN',
              'Total refunded': '${formatEra(market.totalRefunded)} ETKN',
              'Total slashed': '${formatEra(market.totalSlashed)} ETKN',
              'My position': position == null
                  ? 'None'
                  : '${position.side} ${formatEra(position.amount)} ETKN',
            },
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: canStake
                      ? () => _stakeDialog(market, PredictionOutcomeSide.yes)
                      : null,
                  child: const Text('Stake YES'),
                ),
                FilledButton.tonal(
                  onPressed: canStake
                      ? () => _stakeDialog(market, PredictionOutcomeSide.no)
                      : null,
                  child: const Text('Stake NO'),
                ),
                OutlinedButton(
                  onPressed: canUnstake && position != null
                      ? () => _unstakeDialog(market, position)
                      : null,
                  child: const Text('Unstake'),
                ),
                if (Phase6bLifecyclePolicy.canClaim(
                  market: market,
                  position: position,
                ))
                  OutlinedButton(
                    onPressed: () => _submitIntent(
                      Phase6bCallFactory(_walletApi).claim(market.tokenId),
                    ),
                    child: const Text('Claim payout'),
                  ),
                if (_diagnostics?.compatibility.testingToolsEnabled == true &&
                    market.settlementStatus == 'NotStarted')
                  OutlinedButton(
                    onPressed: () =>
                        _chooseSettlementOutcome(market, administrative: false),
                    child: const Text('Propose outcome'),
                  ),
                if (_diagnostics?.compatibility.testingToolsEnabled == true &&
                    const {
                      'OutcomeProposed',
                      'DisputeWindowOpen',
                    }.contains(market.settlementStatus))
                  OutlinedButton(
                    onPressed: () => _submitIntent(
                      Phase6bCallFactory(
                        _walletApi,
                      ).finalizeAfterDisputeWindow(market.tokenId),
                    ),
                    child: const Text('Finalize after window'),
                  ),
                if (_diagnostics?.compatibility.governanceActionsEnabled ==
                        true &&
                    !market.isSettled)
                  OutlinedButton(
                    onPressed: () =>
                        _chooseSettlementOutcome(market, administrative: true),
                    child: const Text('Admin finalize outcome'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validatePrediction(Phase6bPrediction prediction) async {
    final outcome = await showDialog<PredictionOutcome>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Select the verified prediction outcome'),
        children: [
          for (final value in PredictionOutcome.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, value),
              child: Text(value.variantName),
            ),
        ],
      ),
    );
    if (outcome == null || !mounted) return;
    await _submitIntent(
      Phase6bCallFactory(
        _walletApi,
      ).validatePrediction(predictionId: prediction.id, outcome: outcome),
    );
  }

  Future<void> _chooseSettlementOutcome(
    Phase6bMarket market, {
    required bool administrative,
  }) async {
    final evidenceController = TextEditingController();
    var selected = SettlementOutcome.inconclusive;
    String? evidenceError;
    final result =
        await showDialog<({SettlementOutcome outcome, String evidence})>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
              title: Text(
                administrative
                    ? 'Administrative final outcome'
                    : 'Propose settlement outcome',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<SettlementOutcome>(
                    initialValue: selected,
                    decoration: const InputDecoration(
                      labelText: 'Exact outcome',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final value in SettlementOutcome.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.variantName),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selected = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: evidenceController,
                    decoration: const InputDecoration(
                      labelText: 'Evidence URI/reference (required)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (evidenceError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      evidenceError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'Only choose an outcome supported by independently reviewed '
                    'evidence. This affects live ETKN settlement.',
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final evidence = evidenceController.text.trim();
                    try {
                      Phase6bPublicInputSafety.validateEvidenceReference(
                        utf8.encode(evidence),
                      );
                    } on Phase6bValidationException catch (error) {
                      setDialogState(() => evidenceError = error.message);
                      return;
                    }
                    Navigator.pop(dialogContext, (
                      outcome: selected,
                      evidence: evidence,
                    ));
                  },
                  child: const Text('Review exact call'),
                ),
              ],
            ),
          ),
        );
    evidenceController.clear();
    evidenceController.dispose();
    if (result == null || !mounted) return;
    final factory = Phase6bCallFactory(_walletApi);
    await _submitIntent(
      administrative
          ? factory.adminFinalizeOutcome(
              tokenId: market.tokenId,
              outcome: result.outcome,
              evidenceUri: utf8.encode(result.evidence),
            )
          : factory.proposeOutcome(
              tokenId: market.tokenId,
              outcome: result.outcome,
              evidenceUri: utf8.encode(result.evidence),
            ),
    );
  }

  Future<void> _showModel(Phase6bModel model) async {
    final flags = const Phase6bBuildFlags.fromEnvironment();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Phase6bModelDetailScreen(
          model: model,
          governanceActionsEnabled:
              flags.testingToolsEnabled &&
              flags.governanceActionsEnabled &&
              _diagnostics!.compatibility.governanceActionsEnabled,
          onAction: _submitIntent,
          callFactory: Phase6bCallFactory(_walletApi),
        ),
      ),
    );
    await _refresh();
  }

  Future<void> _startModelOnboarding() async {
    final input = await Navigator.of(context).push<ModelRegistrationInput>(
      MaterialPageRoute(
        builder: (_) => ModelOnboardingWizardScreen(
          diagnostics: _diagnostics!,
          activeAccount: _activeAccount,
        ),
      ),
    );
    if (input == null || !mounted) return;
    await _submitIntent(
      Phase6bCallFactory(_walletApi).registerModel(
        modelHash: input.modelHash,
        metadataUri: input.metadataUri,
      ),
    );
  }

  Future<void> _startPredictionCreation() async {
    final requireApproval = _configuration!.requireModelApproval;
    final eligible = _models!.items
        .where(
          (model) => model.canSubmit(
            _activeAccount?.address ?? '',
            requireApproval: requireApproval,
          ),
        )
        .toList();
    final input = await Navigator.of(context).push<_PredictionWizardResult>(
      MaterialPageRoute(
        builder: (_) => PredictionCreationWizardScreen(
          diagnostics: _diagnostics!,
          models: eligible,
          activeAccount: _activeAccount,
          requireModelApproval: requireApproval,
        ),
      ),
    );
    if (input == null || !mounted) return;
    await _submitIntent(
      Phase6bCallFactory(_walletApi).submitPrediction(
        modelId: input.model.id,
        domain: input.domain,
        categoryCode: input.category,
        predictionHash: input.hash,
        metadataUri: input.metadataUri,
        confidence: input.confidence,
        expiresAt: input.expiresAt,
      ),
    );
  }

  Future<void> _tokenizePrediction(Phase6bPrediction prediction) async {
    final metadataUri = prediction.metadataUriBytes.isEmpty
        ? utf8.encode('era-prediction-${prediction.id}')
        : prediction.metadataUriBytes;
    await _submitIntent(
      Phase6bCallFactory(_walletApi).tokenizePrediction(
        predictionId: prediction.id,
        metadataUri: metadataUri,
        transferable: false,
      ),
    );
  }

  Future<void> _stakeDialog(
    Phase6bMarket market,
    PredictionOutcomeSide side,
  ) async {
    final amount = await showDialog<BigInt>(
      context: context,
      builder: (_) => _StakeAmountDialog(
        minimumStake: _configuration!.minimumStake,
        freeBalance: _diagnostics!.freeBalance ?? BigInt.zero,
      ),
    );
    if (amount == null || !mounted) return;
    await _submitIntent(
      Phase6bCallFactory(
        _walletApi,
      ).stake(tokenId: market.tokenId, side: side, amount: amount),
    );
  }

  Future<void> _unstakeDialog(
    Phase6bMarket market,
    Phase6bPosition position,
  ) async {
    final amount = await showDialog<BigInt>(
      context: context,
      builder: (_) => _StakeAmountDialog(
        minimumStake: BigInt.one,
        freeBalance: position.amount,
        title: 'Unstake ${position.side}',
        maximum: position.amount,
      ),
    );
    if (amount == null || !mounted) return;
    await _submitIntent(
      Phase6bCallFactory(_walletApi).unstake(
        tokenId: market.tokenId,
        side: position.side == 'Yes'
            ? PredictionOutcomeSide.yes
            : PredictionOutcomeSide.no,
        amount: amount,
      ),
    );
  }

  Future<void> _submitIntent(Phase6bCallIntent intent) async {
    if (_intentFlowActive ||
        _sessionStageTransitionActive ||
        _exportingReport) {
      _showMessage(
        'Another transaction review is already active. Finish or cancel it '
        'before starting a new action.',
      );
      return;
    }
    if (mounted) setState(() => _intentFlowActive = true);
    try {
      await _submitIntentUnlocked(intent);
    } finally {
      if (mounted) setState(() => _intentFlowActive = false);
    }
  }

  Future<void> _submitIntentUnlocked(Phase6bCallIntent intent) async {
    final account = _activeAccount;
    if (account == null) {
      _showMessage('Select an account before signing.');
      return;
    }
    if (_journal.any((record) => record.protectsAgainstDuplicate)) {
      _showMessage(
        'Resolve every pending or uncertain transaction before signing '
        'another action.',
      );
      return;
    }
    final testSession = _testSession;
    if (testSession != null &&
        (testSession.isFinished || testSession.nextStage == null)) {
      _showMessage(
        'The controlled session is complete and frozen. Export it or '
        'explicitly restart before submitting another live action.',
      );
      return;
    }
    final currentTestStage = testSession?.nextStage;
    if (currentTestStage != null) {
      if (_pendingSessionEvidence.isNotEmpty) {
        _showMessage(
          'A prior controlled transaction still needs its session evidence '
          'reconciled. Use Verify in Diagnostics; do not resubmit.',
        );
        return;
      }
      if (_sessionCheckpointBusy) {
        _showMessage(
          'Wait for the secure session checkpoint to finish before the next '
          'controlled action.',
        );
        return;
      }
      if (_sessionPersistenceError != null) {
        _showMessage(
          'This controlled session is blocked until its public evidence is '
          'saved successfully to secure local storage.',
        );
        return;
      }
      if (!_testSession!.participatingPublicAddresses.contains(
        account.address,
      )) {
        _showMessage(
          'The active account is not one of this controlled session\'s two '
          'approved public signers. Select Account A or Account B.',
        );
        return;
      }
      if (!_intentAllowedDuringStage(currentTestStage, intent)) {
        _showMessage(
          'The active controlled session is waiting for '
          '${Phase6bTestLifecycle.definitionFor(currentTestStage).title}. '
          'This call is out of sequence or targets different session IDs.',
        );
        return;
      }
      final prerequisites = _sessionPrerequisiteChecks(currentTestStage);
      if (prerequisites.any((check) => !check.passed)) {
        _showMessage(
          'This session cannot submit another live transaction because a '
          'prerequisite stage did not pass. Export or restart the session.',
        );
        return;
      }
      final expectedSigner = _expectedSessionSigner(currentTestStage);
      if (expectedSigner != null && account.address != expectedSigner) {
        _showMessage(
          'This test stage requires ${currentTestStage == Phase6bTestStage.stakeYesFromAccountA ? 'Account A' : 'Account B'}: '
          '$expectedSigner',
        );
        return;
      }
    }
    final compatibility = _diagnostics!.compatibility;
    final assessment = Phase6bActionPolicy.assess(
      intent: intent,
      runtimeCompatible: compatibility.metadataCompatible,
      testingToolsEnabled: compatibility.testingToolsEnabled,
      governanceActionsEnabled: compatibility.governanceActionsEnabled,
      accountSelected: true,
    );
    if (!assessment.enabled) {
      _showMessage(assessment.reasons.join('\n'));
      return;
    }

    final wallet = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final accounts = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final signer = EraExtrinsicSigner(
      provider: wallet.provider!,
      api: wallet.api!,
    );
    BigInt? fee;
    final feeAuth = await authenticateWalletForSensitiveAction(
      context,
      reason: 'Authenticate to estimate the live ${intent.callPath} fee',
    );
    if (!feeAuth.success || !mounted) return;
    final mnemonic = await accounts.loadMnemonicForAccount(account.id);
    if (mnemonic == null) {
      _showMessage('Signing material is unavailable for this account.');
      return;
    }
    try {
      final estimateContext = await _runtimeRecheck(intent);
      final estimateExtrinsic = await signer.sign(
        mnemonic: mnemonic,
        call: intent.call,
        expectedContext: estimateContext,
        expectedSignerAddress: account.address,
      );
      fee = await signer.estimateFee(estimateExtrinsic);
    } catch (error) {
      _showMessage('Fee estimation failed: $error');
      return;
    }
    if (fee == null) {
      _showMessage(
        'A live fee estimate is required before any controlled transaction. '
        'Nothing was submitted.',
      );
      return;
    }
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _LiveCallConfirmationDialog(
        intent: intent,
        signerAddress: account.address,
        accountName: account.name,
        fee: fee,
      ),
    );
    if (confirmed != true || !mounted) return;
    if (!await _captureSessionMarketBaseline(intent) || !mounted) return;

    final journal = Phase6bTransactionJournal(storage: secureStorage);
    final runner = Phase6bTransactionRunner(
      provider: wallet.provider!,
      api: wallet.api!,
      journal: journal,
    );
    final transactionIntent = TransactionIntent(
      pallet: 'AiPredictions',
      call: intent.callName,
      argumentsSummary: intent.arguments,
      signer: account.address,
    );
    try {
      await runner.hydrateDuplicateGuard();
      final record = await runner.submit(
        intent: transactionIntent,
        recheckRuntime: () => _runtimeRecheck(intent),
        authenticate: () async {
          if (!mounted) return false;
          final result = await authenticateWalletForSensitiveAction(
            context,
            reason: 'Authenticate to sign live ${intent.callPath}',
          );
          return result.success;
        },
        sign: (signingContext) async {
          final currentMnemonic = await accounts.loadMnemonicForAccount(
            account.id,
          );
          if (currentMnemonic == null) {
            throw StateError('Signing material is unavailable.');
          }
          await _freshActionPreflight(
            intent,
            signerAddress: account.address,
            estimatedFee: fee,
          );
          return signer.sign(
            mnemonic: currentMnemonic,
            call: intent.call,
            expectedContext: signingContext,
            expectedSignerAddress: account.address,
          );
        },
        verifyPostState: (record) => _verifyPostState(intent, record),
        requirePostStateVerification:
            intent.audience != Phase6bActionAudience.participant ||
            intent.callName == 'claim_prediction_market_payout' ||
            (currentTestStage != null &&
                _intentMatchesStage(currentTestStage, intent)),
        beforeSubmit: currentTestStage == null
            ? null
            : (submittingRecord) async {
                if (!mounted ||
                    !identical(_testSession, testSession) ||
                    testSession!.isFinished ||
                    testSession.nextStage != currentTestStage) {
                  throw StateError(
                    'The controlled session changed before submission. '
                    'Nothing was broadcast.',
                  );
                }
                final pending = Phase6bPendingCallEvidence(
                  recordId: submittingRecord.id,
                  callName: submittingRecord.call,
                  callPath: intent.callPath,
                  arguments: submittingRecord.argumentsSummary,
                  feeBaseUnits: fee,
                  typedConfirmation: intent.typedConfirmation,
                );
                setState(() {
                  _pendingSessionEvidence[submittingRecord.id] = pending;
                });
                if (!await _persistTestSessionCheckpoint()) {
                  if (mounted) {
                    setState(() {
                      _pendingSessionEvidence.remove(submittingRecord.id);
                    });
                  }
                  throw StateError(
                    'The controlled transaction descriptor could not be '
                    'saved. Nothing was broadcast.',
                  );
                }
              },
        onUpdate: (record) {
          if (!mounted) return;
          setState(() {
            _latestReceipt = record;
            final byId = {
              for (final existing in _journal) existing.id: existing,
              record.id: record,
            };
            _journal = byId.values.toList(
              growable: false,
            )..sort((left, right) => right.createdAt.compareTo(left.createdAt));
          });
        },
      );
      if (!mounted) return;
      await _refresh();
      if (!mounted) return;
      await _recordTestTransactionStage(intent, record, fee);
      await _openReceipt(record);
    } on DuplicateSubmissionException catch (error) {
      _showMessage(
        '$error Do not resubmit until the earlier intent is verified.',
      );
    } catch (error) {
      _showMessage(
        'Submission outcome may be uncertain: $error\n'
        'Do not resubmit until the transaction journal is reconciled.',
      );
      await _refresh();
      if (!mounted || currentTestStage == null) return;
      final interrupted = _journal
          .where(
            (record) =>
                record.intentKey == transactionIntent.key &&
                record.protectsAgainstDuplicate,
          )
          .firstOrNull;
      if (interrupted != null) {
        await _recordTestTransactionEvidence(
          callName: intent.callName,
          callPath: intent.callPath,
          arguments: intent.arguments,
          typedConfirmation: intent.typedConfirmation,
          record: interrupted,
          fee: fee,
        );
      }
    }
  }

  Future<EraSigningContext> _runtimeRecheck(Phase6bCallIntent intent) async {
    final wallet = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final refreshed = await Phase6bRuntimeProbe(
      provider: wallet.provider!,
      api: wallet.api!,
    ).refresh(activeAccount: _activeAccount?.address);
    final compatibility = refreshed.compatibility;
    if (refreshed.syncing || refreshed.peerCount <= 0) {
      throw StateError(
        'The ERA endpoint is not ready for signing '
        '(syncing=${refreshed.syncing}, peers=${refreshed.peerCount}).',
      );
    }
    final allowed = switch (intent.audience) {
      Phase6bActionAudience.participant =>
        compatibility.participantSigningEnabled,
      Phase6bActionAudience.testingOperator =>
        compatibility.participantSigningEnabled &&
            compatibility.testingToolsEnabled,
      Phase6bActionAudience.governance =>
        compatibility.governanceActionsEnabled,
    };
    if (!allowed) {
      throw StateError(
        'Runtime compatibility changed before signing: '
        '${compatibility.explanation}',
      );
    }
    return EraSigningContext(
      genesisHash: refreshed.genesisHash,
      specVersion: refreshed.specVersion,
      transactionVersion: refreshed.transactionVersion,
      metadataHash: refreshed.metadataHash,
      runtimeWasmHash: refreshed.runtimeWasmHash,
      aiStorageVersion: refreshed.aiStorageVersion!,
    );
  }

  Future<void> _freshActionPreflight(
    Phase6bCallIntent intent, {
    required String signerAddress,
    required BigInt? estimatedFee,
  }) async {
    const checkedCalls = {
      'register_model',
      'approve_model',
      'suspend_model',
      'reject_model',
      'set_model_submitter',
      'submit_prediction',
      'tokenize_prediction',
      'validate_prediction',
      'close_prediction',
      'propose_prediction_outcome',
      'finalize_prediction_outcome_after_dispute_window',
      'admin_finalize_prediction_outcome',
      'stake_on_prediction_outcome_side',
      'unstake_from_prediction_outcome_side',
      'claim_prediction_market_payout',
    };
    if (!checkedCalls.contains(intent.callName)) return;

    final wallet = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final repository = Phase6bChainRepository(wallet.api!);
    final finalized = await PolkadartPhase6bFinalizedSource(
      provider: wallet.provider!,
      api: wallet.api!,
    ).latestFinalized();
    final at = _blockHashBytes(finalized.hash);
    final configuration = await repository.loadConfiguration(
      accountAddress: signerAddress,
      at: at,
    );
    Phase6bModel? model;
    Phase6bPrediction? prediction;
    Phase6bMarket? market;
    Phase6bPosition? position;

    BigInt? argumentId(String name) => _argumentId(intent.arguments[name]);
    switch (intent.callName) {
      case 'approve_model':
      case 'suspend_model':
      case 'reject_model':
      case 'set_model_submitter':
        final modelId = argumentId('model_id');
        model = modelId == null
            ? null
            : await repository.loadModel(modelId, at: at);
        break;
      case 'submit_prediction':
        final modelId = argumentId('model_id');
        model = modelId == null
            ? null
            : await repository.loadModel(modelId, at: at);
        break;
      case 'tokenize_prediction':
        final predictionId = argumentId('prediction_id');
        prediction = predictionId == null
            ? null
            : await repository.loadPrediction(predictionId, at: at);
        model = prediction == null
            ? null
            : await repository.loadModel(prediction.modelId, at: at);
        break;
      case 'validate_prediction':
      case 'close_prediction':
        final predictionId = argumentId('prediction_id');
        prediction = predictionId == null
            ? null
            : await repository.loadPrediction(predictionId, at: at);
        break;
      case 'propose_prediction_outcome':
      case 'finalize_prediction_outcome_after_dispute_window':
      case 'admin_finalize_prediction_outcome':
      case 'stake_on_prediction_outcome_side':
        final tokenId = argumentId('token_id');
        market = tokenId == null
            ? null
            : await repository.loadMarket(tokenId, at: at);
        break;
      case 'unstake_from_prediction_outcome_side':
      case 'claim_prediction_market_payout':
        final tokenId = argumentId('token_id');
        if (tokenId != null) {
          final values = await Future.wait<Object?>([
            repository.loadMarket(tokenId, at: at),
            repository.loadPosition(
              accountAddress: signerAddress,
              tokenId: tokenId,
              at: at,
            ),
          ]);
          market = values[0] as Phase6bMarket?;
          position = values[1] as Phase6bPosition?;
        }
        break;
    }

    Phase6bActionPreflight.ensureAllowed(
      intent: intent,
      configuration: configuration,
      signer: signerAddress,
      model: model,
      prediction: prediction,
      market: market,
      position: position,
      currentFinalizedBlock: finalized.number.toInt(),
    );

    if (intent.callName == 'stake_on_prediction_outcome_side') {
      if (estimatedFee == null) {
        throw StateError(
          'Fresh chain preflight blocked ${intent.callPath}: '
          'a fee estimate is required before staking.',
        );
      }
      final amount = argumentId('amount');
      if (amount == null) {
        throw StateError(
          'Fresh chain preflight blocked ${intent.callPath}: '
          'the stake amount is invalid.',
        );
      }
      final account = await wallet.api!.query.system.account(
        Keyring().decodeAddress(signerAddress),
        at: at,
      );
      Phase6bAmount.validateStake(
        amount: amount,
        minimumStake: configuration.minimumStake,
        freeBalance: account.data.free,
        estimatedFee: estimatedFee,
        existentialReserve: wallet.api!.constant.balances.existentialDeposit,
      );
    }
  }

  Future<PostStateVerification> _verifyPostState(
    Phase6bCallIntent intent,
    TransactionLifecycleRecord record,
  ) => _verifyPersistedPostState(
    record,
    callName: intent.callName,
    arguments: intent.arguments,
  );

  Future<PostStateVerification> _verifyPersistedPostState(
    TransactionLifecycleRecord record, {
    String? callName,
    Map<String, Object?>? arguments,
  }) async {
    final repository = Phase6bChainRepository(_walletApi);
    final checkedCall = callName ?? record.call;
    final checkedArguments = arguments ?? record.argumentsSummary;
    final finalityBlock = record.finalityBlock;
    if (finalityBlock == null) {
      return PostStateVerification(
        status: PostStateVerificationStatus.inconclusive,
        checkedAt: DateTime.now().toUtc(),
        details: const {
          'reason': 'A finalized block is required for canonical post-state.',
        },
      );
    }
    final at = _blockHashBytes(finalityBlock.hash);
    bool confirmed = false;
    final details = <String, Object?>{'call': 'AiPredictions.$checkedCall'};
    BigInt? id(String name) =>
        _argumentId(checkedArguments[name]) ??
        _eventId(record, name.replaceAll('_', ''));
    switch (checkedCall) {
      case 'register_model':
        final modelId = _eventId(record, 'modelId');
        final model = modelId == null
            ? null
            : await repository.loadModel(modelId, at: at);
        confirmed =
            model != null &&
            model.owner == record.signer &&
            model.modelHashHex == checkedArguments['model_hash'] &&
            model.metadataReference == checkedArguments['metadata_uri'] &&
            _matchingAiEvent(record, 'ModelRegistered', {
                  'modelId': modelId,
                  'owner': Keyring().decodeAddress(record.signer),
                }) !=
                null;
        details['modelId'] = modelId?.toString();
        details['actualOwner'] = model?.owner;
        details['actualModelHash'] = model?.modelHashHex;
        break;
      case 'approve_model':
      case 'suspend_model':
      case 'reject_model':
      case 'set_model_submitter':
        final modelId = id('model_id');
        final model = modelId == null
            ? null
            : await repository.loadModel(modelId, at: at);
        final expected = switch (checkedCall) {
          'approve_model' => 'Approved',
          'suspend_model' => 'Suspended',
          'reject_model' => 'Rejected',
          _ => null,
        };
        confirmed =
            model != null &&
            (expected == null || model.governanceStatus == expected) &&
            (checkedCall != 'set_model_submitter' ||
                model.authorizedSubmitter ==
                    _argumentAddress(checkedArguments['submitter'])) &&
            _matchingAiEvent(
                  record,
                  switch (checkedCall) {
                    'approve_model' => 'ModelApproved',
                    'suspend_model' => 'ModelSuspended',
                    'reject_model' => 'ModelRejected',
                    _ => 'ModelSubmitterUpdated',
                  },
                  {'modelId': modelId},
                ) !=
                null;
        details['actualStatus'] = model?.governanceStatus;
        if (checkedCall == 'set_model_submitter') {
          details['expectedSubmitter'] = _argumentAddress(
            checkedArguments['submitter'],
          );
          details['actualSubmitter'] = model?.authorizedSubmitter;
        }
        break;
      case 'submit_prediction':
        final predictionId = _eventId(record, 'predictionId');
        final prediction = predictionId == null
            ? null
            : await repository.loadPrediction(predictionId, at: at);
        confirmed =
            prediction != null &&
            prediction.modelId == id('model_id') &&
            prediction.submitter == record.signer &&
            prediction.domain == checkedArguments['domain'] &&
            prediction.categoryCode == checkedArguments['category_code'] &&
            prediction.predictionHashHex ==
                checkedArguments['prediction_hash'] &&
            prediction.metadataReference == checkedArguments['metadata_uri'] &&
            prediction.confidence == checkedArguments['confidence'] &&
            prediction.expiresAt == checkedArguments['expires_at'] &&
            _matchingAiEvent(record, 'PredictionSubmitted', {
                  'predictionId': predictionId,
                  'modelId': id('model_id'),
                  'submitter': Keyring().decodeAddress(record.signer),
                  'domain': checkedArguments['domain'],
                }) !=
                null;
        details['predictionId'] = predictionId?.toString();
        details['actualSubmitter'] = prediction?.submitter;
        details['actualModelId'] = prediction?.modelId.toString();
        break;
      case 'tokenize_prediction':
        final predictionId = id('prediction_id');
        final prediction = predictionId == null
            ? null
            : await repository.loadPrediction(predictionId, at: at);
        final tokenId = prediction?.tokenId;
        final market = tokenId == null
            ? null
            : await repository.loadMarket(tokenId, at: at);
        confirmed =
            prediction != null &&
            market != null &&
            market.predictionId == prediction.id &&
            market.metadataReference == checkedArguments['metadata_uri'] &&
            market.transferable == checkedArguments['transferable'] &&
            _matchingAiEvent(record, 'PredictionTokenized', {
                  'predictionId': prediction.id,
                  'tokenId': tokenId,
                  'owner': Keyring().decodeAddress(market.owner),
                }) !=
                null;
        details['tokenId'] = prediction?.tokenId?.toString();
        break;
      case 'validate_prediction':
      case 'close_prediction':
        final predictionId = id('prediction_id');
        final prediction = predictionId == null
            ? null
            : await repository.loadPrediction(predictionId, at: at);
        final expected = checkedCall == 'close_prediction'
            ? 'Closed'
            : 'Validated';
        confirmed =
            prediction?.status == expected &&
            (checkedCall != 'validate_prediction' ||
                prediction?.outcome == checkedArguments['outcome']) &&
            _matchingAiEvent(
                  record,
                  checkedCall == 'close_prediction'
                      ? 'PredictionClosed'
                      : 'PredictionValidated',
                  {
                    'predictionId': predictionId,
                    if (checkedCall == 'validate_prediction')
                      'validator': Keyring().decodeAddress(record.signer),
                    if (checkedCall == 'validate_prediction')
                      'outcome': checkedArguments['outcome'],
                  },
                ) !=
                null;
        details['actualStatus'] = prediction?.status;
        details['actualOutcome'] = prediction?.outcome;
        break;
      case 'stake_on_prediction_outcome_side':
      case 'unstake_from_prediction_outcome_side':
        final tokenId = id('token_id');
        final position = tokenId == null
            ? null
            : await repository.loadPosition(
                accountAddress: record.signer,
                tokenId: tokenId,
                at: at,
              );
        final event = _matchingAiEvent(
          record,
          checkedCall == 'stake_on_prediction_outcome_side'
              ? 'PredictionOutcomeSideStaked'
              : 'PredictionOutcomeSideUnstaked',
          {
            'tokenId': tokenId,
            'staker': Keyring().decodeAddress(record.signer),
            'side': checkedArguments['side'],
            'amount': id('amount'),
          },
        );
        confirmed =
            event != null &&
            (position?.side == checkedArguments['side'] ||
                (checkedCall == 'unstake_from_prediction_outcome_side' &&
                    _argumentId(event.fields['remainingStake']) ==
                        BigInt.zero));
        break;
      case 'claim_prediction_market_payout':
        final tokenId = id('token_id');
        final position = tokenId == null
            ? null
            : await repository.loadPosition(
                accountAddress: record.signer,
                tokenId: tokenId,
                at: at,
              );
        confirmed =
            position?.claimed == true &&
            _matchingAiEvent(record, 'PredictionMarketPayoutClaimed', {
                  'tokenId': tokenId,
                  'staker': Keyring().decodeAddress(record.signer),
                }) !=
                null;
        break;
      case 'propose_prediction_outcome':
      case 'finalize_prediction_outcome_after_dispute_window':
      case 'admin_finalize_prediction_outcome':
        final tokenId = id('token_id');
        final market = tokenId == null
            ? null
            : await repository.loadMarket(tokenId, at: at);
        final expectedOutcome =
            checkedArguments['proposed_outcome'] ??
            checkedArguments['final_outcome'];
        confirmed =
            market != null &&
            (checkedCall == 'propose_prediction_outcome'
                ? market.settlementStatus != 'NotStarted' &&
                      market.proposedOutcome == expectedOutcome &&
                      _matchingAiEvent(record, 'PredictionOutcomeProposed', {
                            'tokenId': tokenId,
                            'proposedOutcome': expectedOutcome,
                          }) !=
                          null
                : market.isSettled &&
                      (expectedOutcome == null ||
                          market.finalOutcome == expectedOutcome) &&
                      _matchingAiEvent(record, 'PredictionOutcomeFinalized', {
                            'tokenId': tokenId,
                            'finalOutcome': ?expectedOutcome,
                          }) !=
                          null);
        details['actualSettlementStatus'] = market?.settlementStatus;
        details['actualProposedOutcome'] = market?.proposedOutcome;
        details['actualFinalOutcome'] = market?.finalOutcome;
        break;
      default:
        details['reason'] =
            'No exact canonical post-state verifier exists for this call.';
        confirmed = false;
        break;
    }
    return PostStateVerification(
      status: confirmed
          ? PostStateVerificationStatus.confirmed
          : PostStateVerificationStatus.inconclusive,
      checkedAt: DateTime.now().toUtc(),
      details: details,
    );
  }

  Future<bool> _captureSessionMarketBaseline(Phase6bCallIntent intent) async {
    final session = _testSession;
    if (session == null ||
        session.nextStage != Phase6bTestStage.stakeYesFromAccountA ||
        intent.callName != 'stake_on_prediction_outcome_side' ||
        _sessionMarketTotals != null) {
      return true;
    }
    final tokenId = _argumentId(intent.arguments['token_id']);
    if (tokenId == null) {
      _showMessage('The controlled session has no market token ID.');
      return false;
    }
    try {
      final market = await Phase6bChainRepository(
        _walletApi,
      ).loadMarket(tokenId);
      if (market == null) {
        throw StateError('Canonical market #$tokenId was not found.');
      }
      if (!mounted) return false;
      setState(() {
        _sessionBaselineMarket = market;
        _sessionLatestMarket = market;
        _sessionMarketTotals = Phase6bMarketTotalsObservation(
          yesBeforeBaseUnits: market.yesTotal,
          yesAfterBaseUnits: market.yesTotal,
          noBeforeBaseUnits: market.noTotal,
          noAfterBaseUnits: market.noTotal,
        );
      });
      return _persistTestSessionCheckpoint();
    } catch (error) {
      _showMessage('Unable to capture pre-stake market totals: $error');
      return false;
    }
  }

  Future<void> _openReceipt(TransactionLifecycleRecord record) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FinalizedTransactionReceiptScreen(record: record),
      ),
    );
  }

  Future<void> _runSessionStageTransition(
    Future<void> Function() transition,
  ) async {
    if (_sessionStageTransitionActive ||
        _intentFlowActive ||
        _exportingReport) {
      return;
    }
    if (mounted) setState(() => _sessionStageTransitionActive = true);
    try {
      await transition();
    } finally {
      if (mounted) setState(() => _sessionStageTransitionActive = false);
    }
  }

  Future<void> _startTestSession() => _runSessionStageTransition(
    () => _startTestSessionUnlocked(replaceExisting: false),
  );

  Future<void> _startTestSessionUnlocked({
    required bool replaceExisting,
  }) async {
    if (_sessionCheckpointBusy || _sessionPersistenceError != null) {
      _showMessage(
        'Resolve the secure session checkpoint error before starting or '
        'restarting a controlled session.',
      );
      return;
    }
    if (_testSession != null && !replaceExisting) {
      _showMessage(
        'A controlled session already exists. Use Restart and confirm before '
        'replacing its evidence.',
      );
      return;
    }
    final accounts = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    if (_diagnostics?.compatibility.testingToolsEnabled != true ||
        _diagnostics?.compatibility.metadataCompatible != true) {
      _showMessage('A compatible controlled-testing build is required.');
      return;
    }
    if (_journal.any((record) => record.protectsAgainstDuplicate)) {
      _showMessage(
        'Resolve every pending or uncertain transaction before starting a '
        'controlled session.',
      );
      return;
    }
    if (_configuration?.requireModelApproval == true &&
        _diagnostics?.compatibility.governanceActionsEnabled != true) {
      _showMessage(
        'This runtime requires model approval. Start the session only in a '
        'reviewed build with governance actions enabled.',
      );
      return;
    }
    if (accounts.active == null || accounts.accounts.length < 2) {
      _showMessage(
        'Select and fund at least two public test accounts (Account A and B).',
      );
      return;
    }
    final selectedAccounts = await _selectSessionAccounts(
      accounts.accounts,
      accounts.active!,
    );
    if (selectedAccounts == null || !mounted) return;
    final participants = selectedAccounts
        .map((account) => account.address)
        .toList(growable: false);
    Map<String, BigInt> balances;
    try {
      balances = await _loadPublicBalances(participants);
    } catch (error) {
      _showMessage('Unable to start a verified test session: $error');
      return;
    }
    if (!mounted) return;
    setState(() {
      _testSession = Phase6bTestSession(
        sessionId: 'era-${DateTime.now().toUtc().millisecondsSinceEpoch}',
        startedAt: DateTime.now().toUtc(),
        participatingPublicAddresses: participants,
      );
      _sessionStartingBalances = Map.unmodifiable(balances);
      _sessionLatestBalances = Map.unmodifiable(balances);
      _sessionMarketTotals = null;
      _sessionBaselineMarket = null;
      _sessionLatestMarket = null;
      _sessionClaimPosition = null;
      _completedReport = null;
      _pendingSessionEvidence.clear();
      _sessionModelId = null;
      _sessionPredictionId = null;
      _sessionMarketId = null;
    });
    if (!await _persistTestSessionCheckpoint()) {
      _showMessage(
        'The session was created in memory, but its secure checkpoint could '
        'not be saved. Retry the secure save before recording any stage.',
      );
      return;
    }
    _showMessage(
      'Controlled session started. Each live stage must be reviewed and '
      'confirmed separately; no transaction was submitted.',
    );
  }

  Future<void> _restartTestSession() =>
      _runSessionStageTransition(_restartTestSessionUnlocked);

  Future<void> _restartTestSessionUnlocked() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Discard current session evidence?'),
            content: const Text(
              'Restarting replaces the securely stored stage sequence and '
              'public baselines. Export the current redacted report first if '
              'it is needed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Keep session'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Discard and restart'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed || !mounted) return;
    await _startTestSessionUnlocked(replaceExisting: true);
  }

  Future<List<WalletAccount>?> _selectSessionAccounts(
    List<WalletAccount> accounts,
    WalletAccount active,
  ) async {
    final alternatives = accounts
        .where((account) => account.id != active.id)
        .toList(growable: false);
    if (alternatives.isEmpty) return null;
    var accountB = alternatives.first;
    return showDialog<List<WalletAccount>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Select controlled test accounts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Account A (active): ${active.name}'),
                SelectableText(active.address),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: accountB.id,
                  decoration: const InputDecoration(
                    labelText: 'Account B',
                    helperText: 'Choose the opposing test participant.',
                  ),
                  items: [
                    for (final account in alternatives)
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                  ],
                  onChanged: (id) {
                    if (id == null) return;
                    setDialogState(() {
                      accountB = alternatives.firstWhere(
                        (account) => account.id == id,
                      );
                    });
                  },
                ),
                const SizedBox(height: 12),
                SelectableText(accountB.address),
                const SizedBox(height: 16),
                const Text(
                  'Only these two public accounts will be permitted and '
                  'recorded. Confirm their roles, tiny amounts, funding, '
                  'and the approved test window before continuing.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, [active, accountB]),
              child: const Text('Confirm accounts'),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, BigInt>> _loadPublicBalances(
    Iterable<String> addresses, {
    Uint8List? at,
  }) async {
    final result = <String, BigInt>{};
    final keyring = Keyring();
    for (final address in addresses) {
      final account = await _walletApi.query.system.account(
        keyring.decodeAddress(address),
        at: at,
      );
      result[address] = account.data.free;
    }
    return result;
  }

  List<Phase6bPrerequisiteCheck> _sessionPrerequisiteChecks(
    Phase6bTestStage stage,
  ) {
    final session = _testSession!;
    final definition = Phase6bTestLifecycle.definitionFor(stage);
    if (definition.prerequisites.isEmpty) {
      return [
        Phase6bPrerequisiteCheck(
          name: 'Controlled session active',
          passed: true,
          evidence: session.sessionId,
        ),
      ];
    }
    return definition.prerequisites
        .map((prerequisite) {
          final record = session.records
              .where((candidate) => candidate.stage == prerequisite)
              .firstOrNull;
          return Phase6bPrerequisiteCheck(
            name: Phase6bTestLifecycle.definitionFor(prerequisite).title,
            passed: record?.outcome == Phase6bTestOutcome.pass,
            evidence: record == null
                ? 'No stage record.'
                : '${record.outcome.label} at ${record.completedAt.toUtc().toIso8601String()}',
          );
        })
        .toList(growable: false);
  }

  Future<void> _recordReadOnlyTestStage(Phase6bTestStage stage) async {
    final session = _testSession;
    if (session == null || session.nextStage != stage) return;
    try {
      await _refresh();
      if (!mounted || _testSession != session) return;
      final evidence = <String, Object?>{};
      late final String exactCheck;
      switch (stage) {
        case Phase6bTestStage.selectTestAccounts:
          exactCheck = 'Wallet.select_public_test_accounts';
          evidence['publicAddresses'] = session.participatingPublicAddresses;
          break;
        case Phase6bTestStage.verifyBalancesAndRuntime:
          if (!_diagnostics!.compatibility.metadataCompatible ||
              _diagnostics!.freeBalance == null) {
            throw StateError(
              'Runtime compatibility and an on-chain balance are required.',
            );
          }
          exactCheck = 'System.Account + State.getRuntimeVersion';
          _sessionLatestBalances = Map.unmodifiable(
            await _loadPublicBalances(session.participatingPublicAddresses),
          );
          final requiredPerAccount =
              _configuration!.minimumStake +
              _walletApi.constant.balances.existentialDeposit;
          final underfunded = _sessionLatestBalances.entries
              .where((entry) => entry.value <= requiredPerAccount)
              .map((entry) => entry.key)
              .toList(growable: false);
          if (underfunded.isNotEmpty) {
            throw StateError(
              'Test accounts must each exceed the current minimum stake plus '
              'existential reserve. Underfunded: ${underfunded.join(', ')}',
            );
          }
          evidence['metadataHash'] = _diagnostics!.metadataHash;
          evidence['specVersion'] = _diagnostics!.specVersion;
          evidence['transactionVersion'] = _diagnostics!.transactionVersion;
          evidence['metadataVersion'] = _diagnostics!.metadataVersion;
          evidence['runtimeWasmHash'] = _diagnostics!.runtimeWasmHash;
          evidence['aiStorageVersion'] = _diagnostics!.aiStorageVersion;
          evidence['aiPalletIndex'] = _diagnostics!.aiPredictionsPallet?.index;
          evidence['balances'] = _sessionLatestBalances.map(
            (address, value) => MapEntry(address, value.toString()),
          );
          break;
        case Phase6bTestStage.refreshAndVerifyAccounting:
          final tokenId = BigInt.tryParse(_sessionMarketId ?? '');
          if (tokenId == null) {
            throw StateError('No tokenized market ID has been captured.');
          }
          final market = await Phase6bChainRepository(
            _walletApi,
          ).loadMarket(tokenId);
          if (market == null) {
            throw StateError('Canonical market #$tokenId was not found.');
          }
          final baseline = _sessionMarketTotals;
          if (baseline == null) {
            throw StateError(
              'Pre-stake market totals were not captured; accounting cannot '
              'be reported accurately.',
            );
          }
          exactCheck = 'AiPredictions canonical market accounting';
          _sessionMarketTotals = Phase6bMarketTotalsObservation(
            yesBeforeBaseUnits: baseline.yesBeforeBaseUnits,
            yesAfterBaseUnits: market.yesTotal,
            noBeforeBaseUnits: baseline.noBeforeBaseUnits,
            noAfterBaseUnits: market.noTotal,
          );
          _sessionLatestMarket = market;
          evidence.addAll(market.toJson());
          break;
        case Phase6bTestStage.verifyFinalBalancesAndTreasury:
          exactCheck = 'System.Account + AiPredictions market accounting';
          await _refreshSessionReportEvidence();
          evidence['balances'] = _sessionLatestBalances.map(
            (address, value) => MapEntry(address, value.toString()),
          );
          evidence['feesEnabled'] = _configuration!.feesEnabled;
          evidence['feeBps'] = _configuration!.feeBps;
          evidence['treasuryEnabled'] = _configuration!.treasuryEnabled;
          evidence['market'] = _sessionLatestMarket?.toJson();
          evidence['claimPosition'] = _sessionClaimPosition?.toJson();
          break;
        default:
          throw StateError('Stage ${stage.name} is not a read-only check.');
      }
      if (!mounted ||
          !identical(_testSession, session) ||
          session.nextStage != stage) {
        return;
      }
      final record = Phase6bStageRecord(
        stage: stage,
        prerequisiteChecks: _sessionPrerequisiteChecks(stage),
        exactCall: exactCheck,
        confirmation: Phase6bActionConfirmation.notRequired(),
        chainStateVerification: Phase6bChainStateVerification(
          verified: true,
          summary: 'Fresh canonical chain data was checked.',
          evidence: evidence,
        ),
        outcome: Phase6bTestOutcome.pass,
        notes: 'No transaction was submitted for this stage.',
        completedAt: DateTime.now().toUtc(),
      );
      setState(() => session.recordStage(record));
      await _persistTestSessionCheckpoint();
    } catch (error) {
      _showMessage('Stage verification was not recorded: $error');
    }
  }

  Future<void> _recordDelegationNotRequired() async {
    final session = _testSession;
    if (session == null ||
        session.nextStage != Phase6bTestStage.configureDelegation) {
      return;
    }
    final modelId = BigInt.tryParse(_sessionModelId ?? '');
    if (modelId == null) {
      _showMessage('The session has not captured a model ID.');
      return;
    }
    final model = await Phase6bChainRepository(_walletApi).loadModel(modelId);
    if (!mounted ||
        !identical(_testSession, session) ||
        session.nextStage != Phase6bTestStage.configureDelegation) {
      return;
    }
    final actor = model == null
        ? null
        : <String>{
            model.owner,
            if (model.authorizedSubmitter != null) model.authorizedSubmitter!,
          }.where(session.participatingPublicAddresses.contains).firstOrNull;
    if (model == null || actor == null) {
      _showMessage(
        'Canonical model authorization does not prove delegation is optional.',
      );
      return;
    }
    setState(() {
      session.recordStage(
        Phase6bStageRecord(
          stage: Phase6bTestStage.configureDelegation,
          prerequisiteChecks: _sessionPrerequisiteChecks(
            Phase6bTestStage.configureDelegation,
          ),
          exactCall: 'AiPredictions.set_model_submitter',
          confirmation: Phase6bActionConfirmation.notRequired(
            statement: 'No delegation transaction required.',
          ),
          chainStateVerification: Phase6bChainStateVerification(
            verified: true,
            summary: 'Existing owner/submitter authorization is sufficient.',
            evidence: {
              'modelId': model.id.toString(),
              'owner': model.owner,
              'authorizedSubmitter': model.authorizedSubmitter,
              'selectedActor': actor,
            },
          ),
          outcome: Phase6bTestOutcome.pass,
          notes: 'Conditional stage completed without a live transaction.',
          completedAt: DateTime.now().toUtc(),
        ),
      );
    });
    await _persistTestSessionCheckpoint();
  }

  Future<void> _recordApprovalNotRequired() async {
    final session = _testSession;
    if (session == null || session.nextStage != Phase6bTestStage.approveModel) {
      return;
    }
    if (_configuration?.requireModelApproval != false) {
      _showMessage('Canonical configuration still requires model approval.');
      return;
    }
    final modelId = BigInt.tryParse(_sessionModelId ?? '');
    if (modelId == null) {
      _showMessage('The session has not captured a model ID.');
      return;
    }
    final model = await Phase6bChainRepository(_walletApi).loadModel(modelId);
    if (model == null) {
      _showMessage('The registered model is absent from canonical storage.');
      return;
    }
    if (!mounted ||
        !identical(_testSession, session) ||
        session.nextStage != Phase6bTestStage.approveModel) {
      return;
    }
    setState(() {
      session.recordStage(
        Phase6bStageRecord(
          stage: Phase6bTestStage.approveModel,
          prerequisiteChecks: _sessionPrerequisiteChecks(
            Phase6bTestStage.approveModel,
          ),
          exactCall: 'AiPredictions.ModelOnboardingConfig',
          confirmation: Phase6bActionConfirmation.notRequired(
            statement: 'Model approval is disabled by canonical config.',
          ),
          chainStateVerification: Phase6bChainStateVerification(
            verified: true,
            summary:
                'Canonical configuration proves no approval call is '
                'required.',
            evidence: {
              'modelId': model.id.toString(),
              'modelStatus': model.governanceStatus,
              'requireModelApproval': false,
            },
          ),
          outcome: Phase6bTestOutcome.pass,
          notes: 'Conditional approval stage completed without a transaction.',
          completedAt: DateTime.now().toUtc(),
        ),
      );
    });
    await _persistTestSessionCheckpoint();
  }

  Future<void> _recordTestTransactionStage(
    Phase6bCallIntent intent,
    TransactionLifecycleRecord record,
    BigInt? fee,
  ) async {
    await _recordTestTransactionEvidence(
      callName: intent.callName,
      callPath: intent.callPath,
      arguments: intent.arguments,
      typedConfirmation: intent.typedConfirmation,
      record: record,
      fee: fee,
    );
  }

  Future<void> _recordTestTransactionEvidence({
    required String callName,
    required String callPath,
    required Map<String, Object?> arguments,
    required String? typedConfirmation,
    required TransactionLifecycleRecord record,
    required BigInt? fee,
  }) async {
    final intentEvidenceMatches =
        record.pallet == 'AiPredictions' &&
        record.call == callName &&
        callPath == '${record.pallet}.${record.call}' &&
        _publicEvidenceEquals(record.argumentsSummary, arguments);
    if (!intentEvidenceMatches) {
      if (mounted) {
        setState(() {
          _sessionPersistenceError =
              'Controlled-session call evidence does not match transaction '
              'journal record ${record.id}. Signing remains blocked.';
        });
      }
      _showMessage(
        'Session evidence does not match the journaled transaction. '
        'Nothing was advanced or resubmitted.',
      );
      return;
    }
    final session = _testSession;
    final stage = session?.nextStage;
    if (session == null || stage == null) {
      return;
    }
    final matchesStage = _callMatchesStage(
      stage,
      callName: callName,
      arguments: arguments,
    );
    final isAllowedAuxiliary = _callIsAllowedAuxiliaryForStage(
      stage,
      callName: callName,
      arguments: arguments,
    );
    final pendingResolution = resolvePhase6bPendingCall(
      matchesStage: matchesStage,
      isAllowedAuxiliary: isAllowedAuxiliary,
      isDefinitiveTerminal:
          record.state == TransactionLifecycleState.succeeded ||
          record.state == TransactionLifecycleState.failed,
    );
    if (pendingResolution == Phase6bPendingCallResolution.retain &&
        !matchesStage &&
        !isAllowedAuxiliary) {
      return;
    }
    if (pendingResolution ==
        Phase6bPendingCallResolution.clearWithoutAdvancing) {
      final pending = _pendingSessionEvidence[record.id];
      if (pending == null) return;
      if (mounted) {
        setState(() => _pendingSessionEvidence.remove(record.id));
      } else {
        _pendingSessionEvidence.remove(record.id);
      }
      final persisted = await _persistTestSessionCheckpoint();
      if (!persisted) {
        if (mounted) {
          setState(() => _pendingSessionEvidence[record.id] = pending);
        } else {
          _pendingSessionEvidence[record.id] = pending;
        }
        _showMessage(
          'The auxiliary transaction is terminal, but its pending descriptor '
          'could not be cleared durably. Signing remains blocked.',
        );
        return;
      }
      _showMessage(
        'The auxiliary ${record.call} transaction is terminal. Its pending '
        'descriptor was cleared; the settle-market stage remains open.',
      );
      return;
    }
    _captureSessionIds(arguments, record);
    final txHash = record.txHash;
    if (txHash == null || txHash.isEmpty) {
      _showMessage(
        'The stage remains open because this uncertain submission has no hash.',
      );
      return;
    }
    final verified =
        record.postStateVerification.status ==
        PostStateVerificationStatus.confirmed;
    final expectedSigner = _expectedSessionSigner(stage);
    final signerMatches =
        expectedSigner == null || expectedSigner == record.signer;
    final succeeded =
        record.state == TransactionLifecycleState.succeeded &&
        verified &&
        signerMatches &&
        fee != null;
    final failed = record.state == TransactionLifecycleState.failed;
    if (!succeeded && !failed) {
      try {
        _pendingSessionEvidence[record.id] = Phase6bPendingCallEvidence(
          recordId: record.id,
          callName: callName,
          callPath: callPath,
          arguments: record.argumentsSummary,
          feeBaseUnits: fee,
          typedConfirmation: typedConfirmation,
        );
        await _persistTestSessionCheckpoint();
      } catch (error) {
        if (mounted) {
          setState(() {
            _sessionPersistenceError =
                'The uncertain transaction could not be checkpointed '
                'safely. Do not resubmit: $error';
          });
        }
      }
      _showMessage(
        'The controlled stage remains open until this transaction has a '
        'definitive dispatch and canonical post-state result. Do not '
        'resubmit; use Verify against chain from the transaction journal.',
      );
      return;
    }
    final outcome = succeeded
        ? Phase6bTestOutcome.pass
        : Phase6bTestOutcome.fail;
    final warnings = <String>[
      if (fee == null) 'Fee estimate was unavailable.',
      if (!verified) 'Canonical post-state was not conclusively verified.',
      if (!signerMatches) 'The selected signer does not match this stage.',
      if (record.state == TransactionLifecycleState.unknownNeedsVerification)
        'Do not resubmit until chain verification is conclusive.',
    ];
    try {
      final stageRecord = Phase6bStageRecord(
        stage: stage,
        prerequisiteChecks: _sessionPrerequisiteChecks(stage),
        exactCall: callPath,
        publicSigner: record.signer,
        feeEstimate: Phase6bFeeEstimate(baseUnits: fee ?? BigInt.zero),
        confirmation: Phase6bActionConfirmation(
          confirmed: true,
          statement:
              typedConfirmation ??
              'I reviewed and confirmed this single live ERA transaction.',
          confirmedByPublicAddress: record.signer,
          confirmedAt: record.createdAt,
        ),
        receipt: Phase6bTransactionReceiptRef(
          referenceId: record.id,
          transactionHash: txHash,
          inclusionBlockNumber: record.inclusionBlock?.number.toInt(),
          inclusionBlockHash: record.inclusionBlock?.hash,
          finalizedBlockNumber: record.finalityBlock?.number.toInt(),
          finalizedBlockHash: record.finalityBlock?.hash,
          dispatchResult:
              record.dispatchResult?.status.name ?? record.state.name,
          relevantEvents: record.relevantEvents
              .map((event) => '${event.pallet}.${event.event}')
              .toList(growable: false),
          finalized: record.finalityBlock != null,
          succeeded:
              record.dispatchResult?.status == DispatchResultStatus.success,
        ),
        chainStateVerification: Phase6bChainStateVerification(
          verified: verified,
          summary: verified
              ? 'Canonical storage confirmed the expected post-state.'
              : 'Canonical post-state is not yet conclusive.',
          evidence: record.postStateVerification.details,
        ),
        outcome: outcome,
        notes: 'Recorded from the reusable finalized transaction service.',
        warnings: warnings,
        isLiveTransaction: true,
        completedAt: DateTime.now().toUtc(),
      );
      setState(() {
        session.recordStage(stageRecord);
        _pendingSessionEvidence.remove(record.id);
      });
      await _persistTestSessionCheckpoint();
    } catch (error) {
      _showMessage(
        'Transaction evidence could not advance the session: $error',
      );
    }
  }

  bool _intentMatchesStage(Phase6bTestStage stage, Phase6bCallIntent intent) =>
      _callMatchesStage(
        stage,
        callName: intent.callName,
        arguments: intent.arguments,
      );

  bool _callMatchesStage(
    Phase6bTestStage stage, {
    required String callName,
    required Map<String, Object?> arguments,
  }) => switch (stage) {
    Phase6bTestStage.onboardModel => callName == 'register_model',
    Phase6bTestStage.approveModel =>
      callName == 'approve_model' &&
          _matchesSessionArgument(arguments, 'model_id', _sessionModelId),
    Phase6bTestStage.configureDelegation =>
      callName == 'set_model_submitter' &&
          _matchesSessionArgument(arguments, 'model_id', _sessionModelId),
    Phase6bTestStage.createPrediction =>
      callName == 'submit_prediction' &&
          _matchesSessionArgument(arguments, 'model_id', _sessionModelId),
    Phase6bTestStage.createOrTokenizeMarket =>
      callName == 'tokenize_prediction' &&
          _matchesSessionArgument(
            arguments,
            'prediction_id',
            _sessionPredictionId,
          ),
    Phase6bTestStage.stakeYesFromAccountA =>
      callName == 'stake_on_prediction_outcome_side' &&
          arguments['side'] == 'Yes' &&
          _matchesSessionArgument(arguments, 'token_id', _sessionMarketId),
    Phase6bTestStage.stakeNoFromAccountB =>
      callName == 'stake_on_prediction_outcome_side' &&
          arguments['side'] == 'No' &&
          _matchesSessionArgument(arguments, 'token_id', _sessionMarketId),
    Phase6bTestStage.validateOrClosePrediction =>
      const {'validate_prediction', 'close_prediction'}.contains(callName) &&
          _matchesSessionArgument(
            arguments,
            'prediction_id',
            _sessionPredictionId,
          ),
    Phase6bTestStage.settleMarket =>
      const {
            'finalize_prediction_outcome_after_dispute_window',
            'admin_finalize_prediction_outcome',
          }.contains(callName) &&
          _matchesSessionArgument(arguments, 'token_id', _sessionMarketId),
    Phase6bTestStage.claimWinningPayout =>
      callName == 'claim_prediction_market_payout' &&
          _matchesSessionArgument(arguments, 'token_id', _sessionMarketId),
    _ => false,
  };

  bool _intentAllowedDuringStage(
    Phase6bTestStage stage,
    Phase6bCallIntent intent,
  ) {
    if (_intentMatchesStage(stage, intent)) return true;
    return _callIsAllowedAuxiliaryForStage(
      stage,
      callName: intent.callName,
      arguments: intent.arguments,
    );
  }

  bool _callIsAllowedAuxiliaryForStage(
    Phase6bTestStage stage, {
    required String callName,
    required Map<String, Object?> arguments,
  }) {
    if (stage != Phase6bTestStage.settleMarket) return false;
    return (callName == 'propose_prediction_outcome' &&
            _matchesSessionArgument(arguments, 'token_id', _sessionMarketId)) ||
        (callName == 'close_prediction' &&
            _matchesSessionArgument(
              arguments,
              'prediction_id',
              _sessionPredictionId,
            ));
  }

  bool _matchesSessionArgument(
    Map<String, Object?> arguments,
    String argument,
    String? expected,
  ) =>
      expected != null &&
      _argumentId(arguments[argument])?.toString() == expected;

  String? _expectedSessionSigner(Phase6bTestStage stage) {
    final participants = _testSession?.participatingPublicAddresses ?? const [];
    return switch (stage) {
      Phase6bTestStage.stakeYesFromAccountA =>
        participants.isEmpty ? null : participants.first,
      Phase6bTestStage.stakeNoFromAccountB =>
        participants.length < 2 ? null : participants[1],
      _ => null,
    };
  }

  void _captureSessionIds(
    Map<String, Object?> arguments,
    TransactionLifecycleRecord record,
  ) {
    String? value(BigInt? id) => id?.toString();
    final modelId =
        _eventId(record, 'modelId') ?? _argumentId(arguments['model_id']);
    final predictionId =
        _eventId(record, 'predictionId') ??
        _argumentId(arguments['prediction_id']);
    final marketId =
        _eventId(record, 'tokenId') ?? _argumentId(arguments['token_id']);
    _sessionModelId ??= value(modelId);
    _sessionPredictionId ??= value(predictionId);
    _sessionMarketId ??= value(marketId);
  }

  Phase6bStageRecord? _prospectiveExportStage({
    required String artifactReference,
    required DateTime completedAt,
  }) {
    final session = _testSession;
    if (session == null || session.nextStage != Phase6bTestStage.exportReport) {
      return null;
    }
    final prerequisites = _sessionPrerequisiteChecks(
      Phase6bTestStage.exportReport,
    );
    final lifecyclePassed = prerequisites.every((check) => check.passed);
    return Phase6bStageRecord(
      stage: Phase6bTestStage.exportReport,
      prerequisiteChecks: prerequisites,
      exactCall: 'Wallet.export_phase6b_test_report',
      confirmation: Phase6bActionConfirmation.notRequired(),
      chainStateVerification: Phase6bChainStateVerification(
        verified: true,
        summary: 'The redacted JSON and Markdown report was produced.',
        evidence: {'artifact': artifactReference},
      ),
      outcome: lifecyclePassed
          ? Phase6bTestOutcome.pass
          : Phase6bTestOutcome.blocked,
      notes: lifecyclePassed
          ? 'No live transaction was submitted.'
          : 'The report was produced, but lifecycle completion remains '
                'BLOCKED by the earlier failed stage.',
      completedAt: completedAt,
    );
  }

  Future<void> _commitExportStage(
    Phase6bStageRecord stage,
    DateTime completedAt,
    Phase6bTestReport report,
  ) async {
    final session = _testSession;
    if (session == null || session.nextStage != Phase6bTestStage.exportReport) {
      return;
    }
    session.recordStage(stage);
    session.finish(completedAt);
    _completedReport = report;
    if (mounted) setState(() {});
    await _persistTestSessionCheckpoint();
  }

  Future<void> _refreshSessionReportEvidence() async {
    final session = _testSession;
    if (session == null) return;
    final wallet = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final finalized = await PolkadartPhase6bFinalizedSource(
      provider: wallet.provider!,
      api: wallet.api!,
    ).latestFinalized();
    final at = _blockHashBytes(finalized.hash);
    final repository = Phase6bChainRepository(wallet.api!);
    final balances = await _loadPublicBalances(
      session.participatingPublicAddresses,
      at: at,
    );
    final activeAddress = _activeAccount?.address;
    final configuration = await repository.loadConfiguration(
      accountAddress: activeAddress,
      at: at,
    );
    Phase6bMarket? market;
    Phase6bPosition? claimPosition;
    final tokenId = BigInt.tryParse(_sessionMarketId ?? '');
    if (tokenId != null) {
      market = await repository.loadMarket(tokenId, at: at);
      final positions = await Future.wait([
        for (final address in session.participatingPublicAddresses)
          repository.loadPosition(
            accountAddress: address,
            tokenId: tokenId,
            at: at,
          ),
      ]);
      final availablePositions = positions.whereType<Phase6bPosition>().toList(
        growable: false,
      );
      claimPosition =
          availablePositions
              .where((position) => position.claimed)
              .firstOrNull ??
          availablePositions.firstOrNull;
    }
    if (!mounted || _testSession != session) return;
    setState(() {
      _configuration = configuration;
      _sessionLatestBalances = Map.unmodifiable(balances);
      _sessionLatestMarket = market ?? _sessionLatestMarket;
      _sessionClaimPosition = claimPosition ?? _sessionClaimPosition;
      final baseline = _sessionMarketTotals;
      if (baseline != null && market != null) {
        _sessionMarketTotals = Phase6bMarketTotalsObservation(
          yesBeforeBaseUnits: baseline.yesBeforeBaseUnits,
          yesAfterBaseUnits: market.yesTotal,
          noBeforeBaseUnits: baseline.noBeforeBaseUnits,
          noAfterBaseUnits: market.noTotal,
        );
      }
    });
    await _persistTestSessionCheckpoint();
  }

  Phase6bTestReport _buildCurrentReport({
    List<Phase6bStageRecord>? stages,
    DateTime? endedAt,
  }) {
    final session = _testSession!;
    final reportStages = stages ?? session.records;
    final reportEndedAt = endedAt ?? session.endedAt;
    final balanceObservations = session.participatingPublicAddresses
        .where(_sessionStartingBalances.containsKey)
        .map(
          (address) => Phase6bBalanceObservation(
            publicAddress: address,
            beforeBaseUnits: _sessionStartingBalances[address]!,
            afterBaseUnits:
                _sessionLatestBalances[address] ??
                _sessionStartingBalances[address]!,
          ),
        )
        .toList(growable: false);
    final market = _sessionLatestMarket;
    final position = _sessionClaimPosition;
    return Phase6bTestReport(
      walletAppVersion: '1.0.0+1',
      platform: kIsWeb ? 'web' : defaultTargetPlatform.name,
      endpoint: _diagnostics!.endpoint,
      genesisHash: _diagnostics!.genesisHash,
      runtimeSpecName: _diagnostics!.specName,
      runtimeSpecVersion: _diagnostics!.specVersion,
      transactionVersion: _diagnostics!.transactionVersion,
      metadataVersion: _diagnostics!.metadataVersion,
      metadataFingerprint: _diagnostics!.metadataHash,
      runtimeWasmHash: _diagnostics!.runtimeWasmHash,
      aiStorageVersion: _diagnostics!.aiStorageVersion,
      aiPalletIndex: _diagnostics!.aiPredictionsPallet?.index,
      testSessionId: session.sessionId,
      startedAt: session.startedAt,
      endedAt: reportEndedAt,
      participatingPublicAddresses: session.participatingPublicAddresses,
      modelId: _sessionModelId,
      predictionId: _sessionPredictionId,
      marketId: _sessionMarketId,
      stages: reportStages,
      balanceObservations: balanceObservations,
      marketTotals: _sessionMarketTotals,
      treasuryAndFeeObservations: [
        for (final stage in reportStages.where(
          (stage) => stage.feeEstimate != null,
        ))
          Phase6bTreasuryFeeObservation(
            label: '${stage.exactCall} fee estimate',
            before: 'Not applicable',
            after: stage.feeEstimate!.display,
            detail: 'Estimated before the separately confirmed submission.',
          ),
        if (market != null)
          Phase6bTreasuryFeeObservation(
            label: 'Market fees collected',
            before:
                '${_sessionBaselineMarket?.feesCollected ?? BigInt.zero} ETKN base units',
            after: '${market.feesCollected} ETKN base units',
            detail: _configuration!.treasuryEnabled
                ? 'Treasury routing is enabled by canonical configuration.'
                : 'Treasury routing is disabled by canonical configuration.',
          ),
      ],
      settlementResult: market?.settlementStatus ?? 'Not completed',
      claimResult: position?.claimed == true ? 'Claimed' : 'Not completed',
      postStateVerification:
          reportStages.isNotEmpty &&
              reportStages.every(
                (stage) => stage.chainStateVerification.verified,
              )
          ? 'All recorded stages have canonical/local export verification.'
          : 'Session has incomplete post-state verification.',
      warnings: [
        'Live actions are never batched or automatically retried.',
        if (_history?.historyComplete != true)
          'Bounded finalized history is incomplete because the RPC may prune blocks.',
      ],
      additionalEvidence: {
        'historyComplete': _history?.historyComplete,
        'finalizedEventCount': _history?.events.length,
        'sessionTransactionJournal': _journal
            .where(
              (record) =>
                  !record.createdAt.isBefore(session.startedAt) &&
                  (reportEndedAt == null ||
                      !record.createdAt.isAfter(reportEndedAt)) &&
                  session.participatingPublicAddresses.contains(record.signer),
            )
            .map((record) => record.toJson())
            .toList(growable: false),
      },
    );
  }

  Future<void> _saveReport() async {
    if (_exportingReport ||
        _intentFlowActive ||
        _sessionStageTransitionActive) {
      return;
    }
    setState(() => _exportingReport = true);
    try {
      if (_completedReport == null) {
        await _refreshSessionReportEvidence();
      }
      if (!mounted) return;
      final persistenceError = _sessionPersistenceError;
      if (persistenceError != null) {
        throw StateError(persistenceError);
      }
      final exporter = Phase6bReportExporter();
      final completedAt = DateTime.now().toUtc();
      final stage = _prospectiveExportStage(
        artifactReference: 'local redacted JSON and Markdown report pair',
        completedAt: completedAt,
      );
      final stages = stage == null ? null : [..._testSession!.records, stage];
      final report =
          _completedReport ??
          _buildCurrentReport(
            stages: stages,
            endedAt: stage == null ? null : completedAt,
          );
      final saved = await exporter.save(
        report,
        fileStem: 'era-phase6b-${_testSession!.sessionId}',
      );
      if (stage != null) {
        await _commitExportStage(stage, completedAt, report);
      }
      _showMessage('Saved JSON and Markdown to ${saved.markdownPath}');
    } catch (error) {
      _showMessage('Report save failed: $error');
    } finally {
      if (mounted) setState(() => _exportingReport = false);
    }
  }

  Future<void> _shareReport() async {
    if (_exportingReport ||
        _intentFlowActive ||
        _sessionStageTransitionActive) {
      return;
    }
    setState(() => _exportingReport = true);
    try {
      if (_completedReport == null) {
        await _refreshSessionReportEvidence();
      }
      if (!mounted) return;
      final persistenceError = _sessionPersistenceError;
      if (persistenceError != null) {
        throw StateError(persistenceError);
      }
      final completedAt = DateTime.now().toUtc();
      final stage = _prospectiveExportStage(
        artifactReference: 'redacted JSON and Markdown share/download pair',
        completedAt: completedAt,
      );
      final stages = stage == null ? null : [..._testSession!.records, stage];
      final renderBox = context.findRenderObject();
      final shareOrigin = renderBox is RenderBox && renderBox.hasSize
          ? renderBox.localToGlobal(Offset.zero) & renderBox.size
          : null;
      final report =
          _completedReport ??
          _buildCurrentReport(
            stages: stages,
            endedAt: stage == null ? null : completedAt,
          );
      final result = await Phase6bReportExporter().share(
        report,
        fileStem: 'era-phase6b-${_testSession!.sessionId}',
        sharePositionOrigin: shareOrigin,
      );
      final exported = !kIsWeb || result.status != ShareResultStatus.dismissed;
      if (exported && stage != null) {
        await _commitExportStage(stage, completedAt, report);
      }
      if (result.status == ShareResultStatus.dismissed) {
        _showMessage(
          kIsWeb
              ? 'Report sharing was cancelled.'
              : 'Sharing was cancelled, but the redacted report was saved '
                    'locally.',
        );
        return;
      }
      _showMessage('Report share/download prepared.');
    } catch (error) {
      _showMessage('Report sharing is unavailable: $error');
    } finally {
      if (mounted) setState(() => _exportingReport = false);
    }
  }

  Future<void> _verifyJournalRecord(TransactionLifecycleRecord record) async {
    if (_intentFlowActive) return;
    if (_pendingSessionEvidence.containsKey(record.id) &&
        (_sessionCheckpointBusy || _sessionPersistenceError != null)) {
      _showMessage(
        'Resolve the secure session checkpoint before reconciling this '
        'controlled-session transaction.',
      );
      return;
    }
    if (mounted) setState(() => _intentFlowActive = true);
    final wallet = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    try {
      final pendingTerminal = _pendingSessionEvidence[record.id];
      if (pendingTerminal != null && !record.protectsAgainstDuplicate) {
        await _recordTestTransactionEvidence(
          callName: pendingTerminal.callName,
          callPath: pendingTerminal.callPath,
          arguments: pendingTerminal.arguments,
          typedConfirmation: pendingTerminal.typedConfirmation,
          record: record,
          fee: pendingTerminal.feeBaseUnits,
        );
        await _refresh();
        _showMessage(
          'The durable terminal journal record was applied to the controlled '
          'session without resubmitting.',
        );
        return;
      }
      final result =
          await Phase6bTransactionRunner(
            provider: wallet.provider!,
            api: wallet.api!,
            journal: Phase6bTransactionJournal(storage: secureStorage),
          ).verifyUnknown(
            record,
            verifyPostState: (finalized) =>
                _verifyPersistedPostState(finalized),
          );
      final pending = _pendingSessionEvidence[record.id];
      final reconciled = result.reconciledRecord;
      if (pending != null && reconciled != null) {
        await _recordTestTransactionEvidence(
          callName: pending.callName,
          callPath: pending.callPath,
          arguments: pending.arguments,
          typedConfirmation: pending.typedConfirmation,
          record: reconciled,
          fee: pending.feeBaseUnits,
        );
      }
      await _refresh();
      _showMessage(
        result.status == ChainVerificationStatus.inconclusive
            ? 'Verification is inconclusive. Do not resubmit.'
            : 'Chain verification result: ${result.status.name}.',
      );
    } catch (error) {
      _showMessage('Chain verification failed: $error. Do not resubmit.');
    } finally {
      if (mounted) setState(() => _intentFlowActive = false);
    }
  }

  String _roleAssessment(String? address) {
    if (address == null) return 'No account selected';
    final owned =
        _models?.items.where((model) => model.owner == address).length ?? 0;
    final delegated =
        _models?.items
            .where((model) => model.authorizedSubmitter == address)
            .length ??
        0;
    return '$owned owned model(s), $delegated delegated model(s). '
        'Privileged origin eligibility remains informational until dispatch.';
  }

  bool get _canSignOperator =>
      _diagnostics?.compatibility.testingToolsEnabled == true &&
      _diagnostics?.compatibility.metadataCompatible == true &&
      _diagnostics?.syncing == false &&
      (_diagnostics?.peerCount ?? 0) > 0 &&
      !_journal.any((record) => record.protectsAgainstDuplicate) &&
      _pendingSessionEvidence.isEmpty &&
      _sessionPersistenceError == null &&
      !_sessionCheckpointBusy &&
      !_sessionStageTransitionActive &&
      !_intentFlowActive &&
      !_exportingReport &&
      _activeAccount != null;

  WalletAccount? get _activeAccount =>
      flutter_provider.Provider.of<AccountManager>(
        context,
        listen: false,
      ).active;

  era_api.Era get _walletApi => flutter_provider.Provider.of<EraWalletProvider>(
    context,
    listen: false,
  ).api!;

  Phase6bPosition? _positionFor(BigInt tokenId) {
    for (final position in _positions?.items ?? const <Phase6bPosition>[]) {
      if (position.tokenId == tokenId) return position;
    }
    return null;
  }

  BigInt? _eventId(TransactionLifecycleRecord record, String name) {
    final normalized = name.toLowerCase();
    for (final event in record.relevantEvents) {
      for (final entry in event.fields.entries) {
        if (entry.key.toLowerCase() == normalized) {
          return _argumentId(entry.value);
        }
      }
    }
    return null;
  }

  LifecycleRelevantEvent? _matchingAiEvent(
    TransactionLifecycleRecord record,
    String eventName,
    Map<String, Object?> expectedFields,
  ) {
    for (final event in record.relevantEvents) {
      if (event.pallet != 'AiPredictions' || event.event != eventName) {
        continue;
      }
      if (expectedFields.entries.every(
        (entry) => _eventValueMatches(event.fields[entry.key], entry.value),
      )) {
        return event;
      }
    }
    return null;
  }

  bool _eventValueMatches(Object? actual, Object? expected) {
    if (expected == null || actual == null) return false;
    if (expected is BigInt) return _argumentId(actual) == expected;
    if (expected is List<int> && actual is List) {
      final actualBytes = actual.whereType<int>().toList(growable: false);
      return actualBytes.length == actual.length &&
          listEquals(actualBytes, expected);
    }
    if (expected is String && actual is Map) {
      return actual.keys.any((key) => key.toString() == expected);
    }
    return actual.toString() == expected.toString();
  }

  BigInt? _argumentId(Object? value) => value == null
      ? null
      : value is BigInt
      ? value
      : BigInt.tryParse(value.toString());

  Uint8List _blockHashBytes(String value) {
    final normalized = value.startsWith('0x') ? value.substring(2) : value;
    if (normalized.length != 64) {
      throw StateError('Finalized block hash is malformed.');
    }
    return Uint8List.fromList(decodeHex(normalized));
  }

  String? _argumentAddress(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    try {
      if (!text.startsWith('0x') || text.length != 66) {
        return '__invalid_public_address__';
      }
      final bytes = <int>[
        for (var offset = 2; offset < text.length; offset += 2)
          int.parse(text.substring(offset, offset + 2), radix: 16),
      ];
      return Keyring().encodeAddress(bytes);
    } catch (_) {
      return '__invalid_public_address__';
    }
  }

  Future<void> _copyText(String text, String message) async {
    await Clipboard.setData(ClipboardData(text: text));
    _showMessage(message);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class Phase6bModelDetailScreen extends StatelessWidget {
  final Phase6bModel model;
  final bool governanceActionsEnabled;
  final Future<void> Function(Phase6bCallIntent intent) onAction;
  final Phase6bCallFactory callFactory;

  const Phase6bModelDetailScreen({
    super.key,
    required this.model,
    required this.governanceActionsEnabled,
    required this.onAction,
    required this.callFactory,
  });

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(title: Text('Model #${model.id}')),
      body: ListView(
        children: [
          _InfoCard(
            title: 'Canonical model',
            rows: {
              'Status': model.governanceStatus,
              'Active': _yesNo(model.active),
              'Owner': model.owner,
              'Authorized submitter': model.authorizedSubmitter ?? 'None',
              'Model hash': model.modelHashHex,
              'Metadata reference': model.metadataReference,
              'Registered block': '${model.registeredAt}',
              'Updated block': '${model.updatedAt ?? 'Never'}',
              'Governance updated': '${model.governanceUpdatedAt}',
              'Total predictions': '${model.totalPredictions}',
              'Active predictions': '${model.activePredictions}',
              'Prediction index': model.predictionIds.join(', '),
              'Provenance': model.provenance.name,
            },
          ),
          if (governanceActionsEnabled)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Governance actions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Account eligibility is informational until the chain '
                      'accepts the exact call. Every action requires re-authentication.',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.tonal(
                          onPressed: model.governanceStatus == 'Approved'
                              ? null
                              : () => onAction(
                                  callFactory.approveModel(model.id),
                                ),
                          child: const Text('Approve'),
                        ),
                        OutlinedButton(
                          onPressed: model.governanceStatus != 'Approved'
                              ? null
                              : () => onAction(
                                  callFactory.suspendModel(model.id),
                                ),
                          child: const Text('Suspend'),
                        ),
                        OutlinedButton(
                          onPressed: model.governanceStatus == 'Rejected'
                              ? null
                              : () =>
                                    onAction(callFactory.rejectModel(model.id)),
                          child: const Text('Reject'),
                        ),
                        OutlinedButton(
                          onPressed: () => _setSubmitter(context),
                          child: const Text('Set/revoke submitter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ExpansionTile(
            title: const Text('Developer diagnostics: decoded record'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  const JsonEncoder.withIndent('  ').convert(model.toJson()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setSubmitter(BuildContext context) async {
    final controller = TextEditingController(text: model.authorizedSubmitter);
    final result = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Set model submitter'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'SS58 address (blank revokes)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Review'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!context.mounted || result == null) return;
    List<int>? bytes;
    if (result.isNotEmpty) {
      try {
        bytes = Keyring().decodeAddress(result);
      } catch (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid SS58 address.')));
        return;
      }
    }
    await onAction(
      callFactory.setModelSubmitter(modelId: model.id, submitter: bytes),
    );
  }
}

class ModelOnboardingWizardScreen extends StatefulWidget {
  final Phase6bRuntimeDiagnostics diagnostics;
  final WalletAccount? activeAccount;

  const ModelOnboardingWizardScreen({
    super.key,
    required this.diagnostics,
    required this.activeAccount,
  });

  @override
  State<ModelOnboardingWizardScreen> createState() =>
      _ModelOnboardingWizardScreenState();
}

class _ModelOnboardingWizardScreenState
    extends State<ModelOnboardingWizardScreen> {
  final _hash = TextEditingController();
  final _metadata = TextEditingController();
  int _step = 0;
  String? _error;

  @override
  void dispose() {
    _hash.clear();
    _metadata.clear();
    _hash.dispose();
    _metadata.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(title: const Text('Model Onboarding')),
      body: Stepper(
        currentStep: _step,
        onStepTapped: (value) => setState(() => _step = value),
        controlsBuilder: (context, details) => Row(
          children: [
            FilledButton(
              onPressed: _step == 6 ? _finish : details.onStepContinue,
              child: Text(_step == 6 ? 'Review live call' : 'Continue'),
            ),
            const SizedBox(width: 8),
            if (_step > 0)
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
          ],
        ),
        onStepContinue: () => setState(() => _step = (_step + 1).clamp(0, 6)),
        onStepCancel: () => setState(() => _step = (_step - 1).clamp(0, 6)),
        steps: [
          Step(
            title: const Text('Runtime and account checks'),
            content: _InfoRows(
              rows: {
                'Runtime':
                    '${widget.diagnostics.specName} v${widget.diagnostics.specVersion}',
                'Metadata compatible': _yesNo(
                  widget.diagnostics.compatibility.metadataCompatible,
                ),
                'Signer': widget.activeAccount?.address ?? 'None',
                'Live chain': widget.diagnostics.chainName,
              },
            ),
          ),
          Step(
            title: const Text('Model information'),
            content: Column(
              children: [
                TextField(
                  controller: _hash,
                  decoration: const InputDecoration(
                    labelText: 'Model hash or identifier (max 128 UTF-8 bytes)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _metadata,
                  decoration: const InputDecoration(
                    labelText: 'Metadata URI/reference (max 256 UTF-8 bytes)',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          Step(
            title: const Text('Review encoded transaction'),
            content: SelectableText(
              'AiPredictions.register_model\n'
              'model_hash: ${utf8.encode(_hash.text).length} bytes\n'
              'metadata_uri: ${utf8.encode(_metadata.text).length} bytes',
            ),
          ),
          const Step(
            title: Text('Fee estimate'),
            content: Text(
              'A fresh signed fee estimate is shown before final confirmation.',
            ),
          ),
          const Step(
            title: Text('Authenticate and sign'),
            content: Text(
              'A second authentication is required immediately before signing.',
            ),
          ),
          const Step(
            title: Text('Inclusion/finality receipt'),
            content: Text(
              'The wallet watches InBlock and Finalized, then decodes dispatch events.',
            ),
          ),
          const Step(
            title: Text('Refresh model from chain'),
            content: Text(
              'Success requires the created model to exist in canonical storage.',
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    final input = ModelRegistrationInput(
      modelHash: utf8.encode(_hash.text.trim()),
      metadataUri: utf8.encode(_metadata.text.trim()),
    );
    try {
      input.validate();
      Navigator.pop(context, input);
    } catch (error) {
      setState(() {
        _step = 1;
        _error = error.toString();
      });
    }
  }
}

class PredictionCreationWizardScreen extends StatefulWidget {
  final Phase6bRuntimeDiagnostics diagnostics;
  final List<Phase6bModel> models;
  final WalletAccount? activeAccount;
  final bool requireModelApproval;

  const PredictionCreationWizardScreen({
    super.key,
    required this.diagnostics,
    required this.models,
    required this.activeAccount,
    required this.requireModelApproval,
  });

  @override
  State<PredictionCreationWizardScreen> createState() =>
      _PredictionCreationWizardScreenState();
}

class _PredictionCreationWizardScreenState
    extends State<PredictionCreationWizardScreen> {
  Phase6bModel? _model;
  PredictionDomain _domain = PredictionDomain.other;
  final _category = TextEditingController();
  final _hash = TextEditingController();
  final _metadata = TextEditingController();
  final _confidence = TextEditingController(text: '80');
  final _expiry = TextEditingController();
  int _step = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _model = widget.models.firstOrNull;
    _expiry.text = (widget.diagnostics.latestFinalizedBlock + 100).toString();
  }

  @override
  void dispose() {
    for (final controller in [
      _category,
      _hash,
      _metadata,
      _confidence,
      _expiry,
    ]) {
      controller.clear();
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(title: const Text('Create Prediction')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: () => _step == 8 ? _finish() : setState(() => _step++),
        onStepCancel: _step == 0 ? null : () => setState(() => _step--),
        controlsBuilder: (context, details) => Row(
          children: [
            FilledButton(
              onPressed: details.onStepContinue,
              child: Text(_step == 8 ? 'Review live call' : 'Continue'),
            ),
            if (_step > 0)
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
          ],
        ),
        steps: [
          Step(
            title: const Text('Select approved model'),
            content: widget.models.isEmpty
                ? const Text(
                    'No active approved owner/delegated model is available.',
                  )
                : DropdownButtonFormField<Phase6bModel>(
                    initialValue: _model,
                    items: [
                      for (final model in widget.models)
                        DropdownMenuItem(
                          value: model,
                          child: Text('Model #${model.id}'),
                        ),
                    ],
                    onChanged: (value) => setState(() => _model = value),
                  ),
          ),
          Step(
            title: const Text('Verify ownership/delegation'),
            content: Text(
              _model == null
                  ? 'Unavailable'
                  : 'Signer ${widget.activeAccount?.address}\nOwner ${_model!.owner}\n'
                        'Delegate ${_model!.authorizedSubmitter ?? 'None'}',
            ),
          ),
          Step(
            title: const Text('Enter prediction parameters'),
            content: Column(
              children: [
                DropdownButtonFormField<PredictionDomain>(
                  initialValue: _domain,
                  items: [
                    for (final domain in PredictionDomain.values)
                      DropdownMenuItem(
                        value: domain,
                        child: Text(domain.variantName),
                      ),
                  ],
                  onChanged: (value) => setState(() => _domain = value!),
                  decoration: const InputDecoration(labelText: 'Domain'),
                ),
                for (final entry in {
                  'Category code (max 96 bytes)': _category,
                  'Prediction hash/identifier (max 128 bytes)': _hash,
                  'Metadata URI (max 256 bytes)': _metadata,
                  'Confidence 0–100': _confidence,
                  'Expiry block': _expiry,
                }.entries)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: entry.key,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const Step(
            title: Text('Review lifecycle constraints'),
            content: Text(
              'Model must remain active and approved; expiry must remain in the future.',
            ),
          ),
          const Step(
            title: Text('Review encoded transaction'),
            content: Text(
              'Exact generated AiPredictions.submit_prediction values are shown in confirmation.',
            ),
          ),
          const Step(
            title: Text('Estimate fee'),
            content: Text(
              'A fresh payment_queryInfo estimate is shown before submission.',
            ),
          ),
          const Step(
            title: Text('Authenticate and sign'),
            content: Text(
              'Runtime is rechecked immediately before local sr25519 signing.',
            ),
          ),
          const Step(
            title: Text('Wait for finality'),
            content: Text(
              'The wallet does not treat a submission hash as success.',
            ),
          ),
          const Step(
            title: Text('Open created prediction'),
            content: Text(
              'Canonical storage is reloaded using the emitted prediction ID.',
            ),
          ),
        ],
      ),
    );
  }

  void _finish() {
    if (_model == null) {
      setState(() {
        _step = 0;
        _error = 'Select an eligible model.';
      });
      return;
    }
    final input = PredictionSubmissionInput(
      modelId: _model!.id,
      modelStatus: _model!.governanceStatus,
      modelActive: _model!.active,
      signerAuthorized: _model!.canSubmit(
        widget.activeAccount?.address ?? '',
        requireApproval: widget.requireModelApproval,
      ),
      requireModelApproval: widget.requireModelApproval,
      categoryCode: utf8.encode(_category.text.trim()),
      predictionHash: utf8.encode(_hash.text.trim()),
      metadataUri: utf8.encode(_metadata.text.trim()),
      confidence: int.tryParse(_confidence.text.trim()) ?? -1,
      expiresAt: int.tryParse(_expiry.text.trim()) ?? -1,
      currentFinalizedBlock: widget.diagnostics.latestFinalizedBlock,
    );
    try {
      input.validate();
      Navigator.pop(
        context,
        _PredictionWizardResult(
          model: _model!,
          domain: _domain,
          category: input.categoryCode,
          hash: input.predictionHash,
          metadataUri: input.metadataUri,
          confidence: input.confidence,
          expiresAt: input.expiresAt,
        ),
      );
    } catch (error) {
      setState(() {
        _step = 2;
        _error = error.toString();
      });
    }
  }
}

class _PredictionWizardResult {
  final Phase6bModel model;
  final PredictionDomain domain;
  final List<int> category;
  final List<int> hash;
  final List<int> metadataUri;
  final int confidence;
  final int expiresAt;

  const _PredictionWizardResult({
    required this.model,
    required this.domain,
    required this.category,
    required this.hash,
    required this.metadataUri,
    required this.confidence,
    required this.expiresAt,
  });
}

class _LiveCallConfirmationDialog extends StatefulWidget {
  final Phase6bCallIntent intent;
  final String signerAddress;
  final String accountName;
  final BigInt? fee;

  const _LiveCallConfirmationDialog({
    required this.intent,
    required this.signerAddress,
    required this.accountName,
    required this.fee,
  });

  @override
  State<_LiveCallConfirmationDialog> createState() =>
      _LiveCallConfirmationDialogState();
}

class _LiveCallConfirmationDialogState
    extends State<_LiveCallConfirmationDialog> {
  final _confirmation = TextEditingController();
  bool _reviewed = false;

  bool get _valid =>
      widget.fee != null &&
      (widget.intent.typedConfirmation == null
          ? _reviewed
          : _confirmation.text.trim() == widget.intent.typedConfirmation);

  @override
  void dispose() {
    _confirmation.clear();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review live ERA transaction'),
      content: SizedBox(
        width: 620,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _ControlledTestingBanner(inline: true),
              _InfoRows(
                rows: {
                  'Call path': widget.intent.callPath,
                  'Signer label': widget.accountName,
                  'Full signer address': widget.signerAddress,
                  'Exact fee estimate': widget.fee == null
                      ? 'Unavailable — cancel if exact fee is required'
                      : '${formatEra(widget.fee)} ETKN',
                  'Expected authorization': widget.intent.expectedAuthorization,
                  'Arguments': const JsonEncoder.withIndent(
                    '  ',
                  ).convert(widget.intent.arguments),
                },
              ),
              const Text(
                'This uses ERA-MAINNET and real ETKN. A second authentication '
                'is required immediately before signing. The wallet submits once.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (widget.intent.typedConfirmation != null) ...[
                Text('Type exactly: ${widget.intent.typedConfirmation}'),
                TextField(
                  controller: _confirmation,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ] else
                CheckboxListTile(
                  value: _reviewed,
                  onChanged: (value) =>
                      setState(() => _reviewed = value ?? false),
                  title: const Text(
                    'I reviewed the signer, call, amount, and fee.',
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _valid ? () => Navigator.pop(context, true) : null,
          child: const Text('Authenticate and submit once'),
        ),
      ],
    );
  }
}

class _StakeAmountDialog extends StatefulWidget {
  final BigInt minimumStake;
  final BigInt freeBalance;
  final String title;
  final BigInt? maximum;

  const _StakeAmountDialog({
    required this.minimumStake,
    required this.freeBalance,
    this.title = 'Stake ETKN',
    this.maximum,
  });

  @override
  State<_StakeAmountDialog> createState() => _StakeAmountDialogState();
}

class _StakeAmountDialogState extends State<_StakeAmountDialog> {
  final _amount = TextEditingController(text: '0.01');
  String? _error;

  @override
  void dispose() {
    _amount.clear();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Balance: ${formatEra(widget.freeBalance)} ETKN'),
          Text('Minimum: ${formatEra(widget.minimumStake)} ETKN'),
          const Text(
            'Never defaults to Max. Estimated share is not a guaranteed payout.',
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final preset in const ['0.01', '0.1', '1'])
                ActionChip(
                  label: Text('$preset ETKN'),
                  onPressed: () => setState(() => _amount.text = preset),
                ),
            ],
          ),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'ETKN amount',
              border: OutlineInputBorder(),
            ),
          ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Review')),
      ],
    );
  }

  void _submit() {
    try {
      final value = Phase6bAmount.parseStrict(_amount.text);
      if (value < widget.minimumStake) {
        throw Phase6bValidationException(
          'Amount',
          'Minimum stake is ${formatEra(widget.minimumStake)} ETKN.',
        );
      }
      if (widget.maximum != null && value > widget.maximum!) {
        throw const Phase6bValidationException(
          'Amount',
          'Exceeds the position amount.',
        );
      }
      Navigator.pop(context, value);
    } catch (error) {
      setState(() => _error = error.toString());
    }
  }
}

class _ControlledTestingBanner extends StatelessWidget {
  final bool inline;

  const _ControlledTestingBanner({this.inline = false});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      color: Colors.deepOrange.withValues(alpha: 0.14),
      padding: const EdgeInsets.all(12),
      child: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.deepOrange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Phase 6B Controlled Testing Mode\n'
              'Transactions use the live ERA blockchain and real ETKN. '
              'Use only approved test accounts and small test amounts.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    return inline ? Card(child: child) : child;
  }
}

class _ParticipantRiskBanner extends StatelessWidget {
  const _ParticipantRiskBanner();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    color: Colors.amber.withValues(alpha: 0.12),
    padding: const EdgeInsets.all(12),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Prediction risk notice',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('AI predictions may be incorrect.'),
        Text('Blockchain transactions are irreversible after finality.'),
        Text('Payouts and profits are not guaranteed.'),
        Text('Use only amounts you can afford to lose.'),
      ],
    ),
  );
}

class _CompatibilityCard extends StatelessWidget {
  final Phase6bRuntimeDiagnostics diagnostics;

  const _CompatibilityCard({required this.diagnostics});

  @override
  Widget build(BuildContext context) {
    final compatible = diagnostics.compatibility.metadataCompatible;
    return Card(
      color: (compatible ? Colors.green : Colors.red).withValues(alpha: 0.10),
      child: ListTile(
        leading: Icon(
          compatible ? Icons.verified : Icons.gpp_bad,
          color: compatible ? Colors.green : Colors.red,
        ),
        title: Text(diagnostics.compatibility.level.label),
        subtitle: Text(
          compatible
              ? 'Pinned metadata fingerprint verified. Signing gate is active.'
              : 'Signing disabled: ${diagnostics.compatibility.explanation}',
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Map<String, String> rows;

  const _InfoCard({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _InfoRows(rows: rows),
          ],
        ),
      ),
    );
  }
}

class _InfoRows extends StatelessWidget {
  final Map<String, String> rows;

  const _InfoRows({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in rows.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: Theme.of(context).textTheme.labelMedium),
                SelectableText(entry.value),
              ],
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;

  const _StatusChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label),
      avatar: Icon(_icon(label), size: 16),
    );
  }

  static IconData _icon(String label) => switch (label.toLowerCase()) {
    'approved' || 'finalized' || 'claimed' || 'settled' => Icons.check_circle,
    'suspended' || 'blocked' => Icons.pause_circle,
    'rejected' || 'failed' => Icons.cancel,
    'yes' => Icons.thumb_up,
    'no' => Icons.thumb_down,
    _ => Icons.schedule,
  };
}

class _PageNotice extends StatelessWidget {
  final int offset;
  final int shown;
  final int total;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _PageNotice({
    required this.offset,
    required this.shown,
    required this.total,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          shown == 0
              ? 'No records in this bounded page'
              : 'Showing ${offset + 1}–${offset + shown} of $total',
        ),
        subtitle: const Text(
          'Page bounds are explicit; results are never silently capped.',
        ),
        trailing: Wrap(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(icon, size: 40),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(body, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

bool _publicEvidenceEquals(Object? left, Object? right) {
  if (identical(left, right) || left == right) return true;
  if (left is List && right is List) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_publicEvidenceEquals(left[index], right[index])) return false;
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !_publicEvidenceEquals(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  return false;
}

String _yesNo(bool value) => value ? 'Yes' : 'No';

String _displayReference(String value) {
  if (value.isEmpty) return 'Unnamed on-chain record';
  return value.length <= 72 ? value : '${value.substring(0, 69)}…';
}
