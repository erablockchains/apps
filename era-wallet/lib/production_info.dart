import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as flutter_provider;
import 'package:url_launcher/url_launcher.dart';

import 'accounts_flow.dart';
import 'era_chain.dart';
import 'era_scaffold.dart';
import 'phase6b/runtime_probe.dart';

const String kEraWalletReleaseName = 'ERA Wallet';
const String kEraWalletReleasePhase = 'Phase 6B';
const String kEraWalletReleaseChannel = 'Controlled Production Release';
const String kEraWalletVersion = '1.1.0';
const int kEraWalletBuildNumber = 2;

const String kEraOfficialWebsite = 'https://www.eraprojects.io/';
const String kEraPrivacyPolicyUrl =
    'https://www.eraprojects.io/privacy-policy.html';
const String kEraSupportUrl = 'https://www.eraprojects.io/support.html';
const String kEraTermsUrl = 'https://www.eraprojects.io/terms.html';
const String kEraSupportEmail = 'support@eraprojects.io';

class ProductionInformationScreen extends StatefulWidget {
  const ProductionInformationScreen({super.key});

  @override
  State<ProductionInformationScreen> createState() =>
      _ProductionInformationScreenState();
}

class _ProductionInformationScreenState
    extends State<ProductionInformationScreen> {
  Future<Phase6bRuntimeDiagnostics>? _diagnostics;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  void _refresh() {
    setState(() => _diagnostics = _loadDiagnostics());
  }

  Future<Phase6bRuntimeDiagnostics> _loadDiagnostics() async {
    final wallet = flutter_provider.Provider.of<EraWalletProvider>(
      context,
      listen: false,
    );
    final accounts = flutter_provider.Provider.of<AccountManager>(
      context,
      listen: false,
    );
    final connected = await wallet.ensureConnected();
    if (!connected || wallet.provider == null || wallet.api == null) {
      throw StateError(wallet.connectionError ?? 'ERA node is unavailable.');
    }
    return Phase6bRuntimeProbe(
      provider: wallet.provider!,
      api: wallet.api!,
    ).refresh(activeAccount: accounts.active?.address);
  }

  @override
  Widget build(BuildContext context) {
    return EraScaffold(
      appBar: AppBar(
        title: const Text('Network & Release'),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Refresh network status',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        children: [
          const _ReleaseIdentityCard(),
          const SizedBox(height: 12),
          _networkCard(),
          const SizedBox(height: 12),
          const _SafetyCard(),
          const SizedBox(height: 12),
          const _OfficialLinksCard(),
        ],
      ),
    );
  }

  Widget _networkCard() {
    final future = _diagnostics;
    if (future == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return FutureBuilder<Phase6bRuntimeDiagnostics>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (snapshot.hasError) {
          return Card(
            color: Colors.red.withValues(alpha: 0.08),
            child: ListTile(
              leading: const Icon(Icons.cloud_off, color: Colors.red),
              title: const Text('Connection unavailable'),
              subtitle: Text('${snapshot.error}'),
              trailing: IconButton(
                onPressed: _refresh,
                icon: const Icon(Icons.refresh),
              ),
            ),
          );
        }
        final diagnostics = snapshot.requireData;
        final compatible = diagnostics.compatibility.metadataCompatible;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      compatible ? Icons.verified_user : Icons.gpp_bad,
                      color: compatible ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      compatible
                          ? 'Compatible ERA network'
                          : 'Read-only: incompatible runtime',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _row('Connection', diagnostics.syncing ? 'Syncing' : 'Online'),
                _row('Endpoint', diagnostics.endpoint),
                _row('Chain', diagnostics.chainName),
                _row('Genesis hash', diagnostics.genesisHash),
                _row(
                  'Runtime',
                  '${diagnostics.specName} v${diagnostics.specVersion}',
                ),
                _row(
                  'Transaction version',
                  '${diagnostics.transactionVersion}',
                ),
                _row(
                  'Latest finalized block',
                  '${diagnostics.latestFinalizedBlock}',
                ),
                _row(
                  'AI Predictions storage',
                  diagnostics.aiStorageVersion?.toString() ?? 'Unavailable',
                ),
                _row('Compatibility', diagnostics.compatibility.explanation),
                if (!compatible) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Signed AI Prediction actions are blocked. Diagnostics '
                    'remain available so runtime drift can be reviewed safely.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        SelectableText(value),
      ],
    ),
  );
}

class _ReleaseIdentityCard extends StatelessWidget {
  const _ReleaseIdentityCard();

  @override
  Widget build(BuildContext context) => const Card(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$kEraWalletReleaseName · $kEraWalletReleasePhase',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(kEraWalletReleaseChannel),
          Text('Version $kEraWalletVersion+$kEraWalletBuildNumber'),
          Text('Native token: ETKN · 18 decimals · SS58 prefix 42'),
        ],
      ),
    ),
  );
}

class _SafetyCard extends StatelessWidget {
  const _SafetyCard();

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.amber.withValues(alpha: 0.10),
    child: const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Safety', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('AI predictions may be incorrect.'),
          Text('Blockchain transactions are irreversible after finality.'),
          Text('Payouts and profits are not guaranteed.'),
          Text('Use only amounts you can afford to lose.'),
          SizedBox(height: 8),
          Text(
            'Never share your recovery phrase, private key, PIN, or password. '
            'ERA support will never ask for them.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            'Download ERA Wallet only from the official ERA Projects website '
            'or a verified official app-store listing, and verify checksums.',
          ),
        ],
      ),
    ),
  );
}

class _OfficialLinksCard extends StatelessWidget {
  const _OfficialLinksCard();

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Official links',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          _link(context, 'Website', kEraOfficialWebsite),
          _link(context, 'Privacy policy', kEraPrivacyPolicyUrl),
          _link(context, 'Support', kEraSupportUrl),
          _link(context, 'Terms of use', kEraTermsUrl),
          _link(context, 'Support email', 'mailto:$kEraSupportEmail'),
        ],
      ),
    ),
  );

  static Widget _link(BuildContext context, String label, String value) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        subtitle: Text(value),
        trailing: const Icon(Icons.open_in_new),
        onTap: () async {
          final uri = Uri.parse(value);
          final opened = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!opened && context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Could not open $value')));
          }
        },
      );
}
