import { createHash } from 'node:crypto';
import { access, mkdir, readFile, writeFile } from 'node:fs/promises';

const configuredEndpoint =
  process.env.ERA_WS_ENDPOINT ?? 'wss://eraprojects.org/';
const expectedChainName = 'ERA-MAINNET';
const expectedGenesisHash =
  '0xba96ed0fe6c37790ee7da7ed9e83e9630b29fc8ba66e6753dc2e5c5704aa94e7';
const expectedSpecName = 'era';
const expectedSpecVersion = 13;
const expectedTransactionVersion = 1;
const expectedMetadataVersion = 14;
const expectedMetadataSha256 =
  '5c3715502b0f4cd3c3bc124f13f7f153cd3486e0c3877dc1d685335e57ed4c3f';
const expectedRuntimeWasmSha256 =
  'ecca5baddc60d4e8522c8ea6206fec0c29175d59ddf2359e6d43201f1faa44a2';
const expectedMetadataBytes = 209828;
const expectedRuntimeCodeBytes = 997122;
const aiPredictionsStorageVersionKey =
  '0x507d4f0bb08b9e2c877acf6d401c17174e7b9012096b41c4eb3aaf947f6ea429';
const runtimeCodeKey = '0x3a636f6465';

const arguments_ = process.argv.slice(2);
if (arguments_.length !== 1 || arguments_[0] !== '--live') {
  throw new Error(
    'Live capture requires exactly: node tool/capture_phase6b_metadata.mjs --live',
  );
}
if (typeof WebSocket !== 'function') {
  throw new Error(
    'This capture tool requires Node.js 22 or newer with the global WebSocket API.',
  );
}

const pubspec = await readFile('pubspec.yaml', 'utf8').catch(() => null);
await access('lib/main.dart').catch(() => {
  throw new Error(
    'Run this tool from the ERA Wallet project root (lib/main.dart is missing).',
  );
});
if (!pubspec || !/^name:\s*era_wallet\s*$/m.test(pubspec)) {
  throw new Error(
    'Run this tool from the ERA Wallet project root (package name mismatch).',
  );
}

const endpointUri = parseLiveEndpoint(configuredEndpoint);
const publicEndpoint = `${endpointUri.protocol}//${endpointUri.host}`;

const socket = (() => {
  try {
    // Keep credentials, paths, and query parameters confined to the connection.
    return new WebSocket(endpointUri);
  } catch {
    throw new Error(`Unable to open configured ERA endpoint (${publicEndpoint}).`);
  }
})();
const pending = new Map();
let nextId = 1;

const opened = new Promise((resolve, reject) => {
  socket.addEventListener('open', resolve, { once: true });
  socket.addEventListener(
    'error',
    () => reject(new Error(`Unable to connect to ${publicEndpoint}`)),
    { once: true },
  );
});

socket.addEventListener('message', (event) => {
  const message = JSON.parse(
    typeof event.data === 'string' ? event.data : event.data.toString(),
  );
  const request = pending.get(message.id);
  if (!request) return;
  pending.delete(message.id);
  if (message.error) {
    request.reject(new Error(JSON.stringify(message.error)));
  } else {
    request.resolve(message.result);
  }
});

function rpc(method, params = []) {
  const id = nextId++;
  return new Promise((resolve, reject) => {
    pending.set(id, { resolve, reject });
    socket.send(JSON.stringify({ jsonrpc: '2.0', id, method, params }));
  });
}

const timeout = setTimeout(() => {
  for (const request of pending.values()) {
    request.reject(new Error('Timed out waiting for ERA JSON-RPC response.'));
  }
  pending.clear();
  socket.close();
}, 30_000);

try {
  await opened;
  const finalizedHead = await rpc('chain_getFinalizedHead');
  const [
    chainName,
    runtimeVersion,
    genesisHash,
    metadataHex,
    health,
    properties,
    storageVersionHex,
    runtimeCodeHex,
  ] = await Promise.all([
    rpc('system_chain'),
    rpc('state_getRuntimeVersion', [finalizedHead]),
    rpc('chain_getBlockHash', [0]),
    rpc('state_getMetadata', [finalizedHead]),
    rpc('system_health'),
    rpc('system_properties'),
    rpc('state_getStorage', [aiPredictionsStorageVersionKey, finalizedHead]),
    rpc('state_getStorage', [runtimeCodeKey, finalizedHead]),
  ]);

  if (typeof metadataHex !== 'string' || typeof runtimeCodeHex !== 'string') {
    throw new Error('The finalized snapshot is missing metadata or runtime code.');
  }

  const metadata = Buffer.from(metadataHex.slice(2), 'hex');
  const metadataSha256 = createHash('sha256').update(metadata).digest('hex');
  const runtimeCode = Buffer.from(runtimeCodeHex.slice(2), 'hex');
  const runtimeWasmSha256 = createHash('sha256')
    .update(runtimeCode)
    .digest('hex');
  const metadataVersion = metadata[4];
  if (chainName !== expectedChainName || genesisHash !== expectedGenesisHash) {
    throw new Error(`Unexpected chain identity ${chainName}/${genesisHash}`);
  }
  if (
    runtimeVersion.specName !== expectedSpecName ||
    runtimeVersion.specVersion !== expectedSpecVersion ||
    runtimeVersion.transactionVersion !== expectedTransactionVersion
  ) {
    throw new Error(
      `Unexpected runtime ${runtimeVersion.specName}/${runtimeVersion.specVersion}/${runtimeVersion.transactionVersion}`,
    );
  }
  if (metadataVersion !== expectedMetadataVersion) {
    throw new Error(`Unexpected metadata version ${metadataVersion}`);
  }
  if (
    properties?.tokenSymbol !== 'ETKN' ||
    properties?.tokenDecimals !== 18 ||
    properties?.ss58Format !== 42
  ) {
    throw new Error(
      `Unexpected chain properties ${JSON.stringify(properties)}`,
    );
  }
  if (metadataSha256 !== expectedMetadataSha256) {
    throw new Error(
      `Metadata drift: ${metadataSha256} != ${expectedMetadataSha256}`,
    );
  }
  if (metadata.length !== expectedMetadataBytes) {
    throw new Error(
      `Metadata length drift: ${metadata.length} != ${expectedMetadataBytes}`,
    );
  }
  if (storageVersionHex !== '0x0300') {
    throw new Error(`AI Predictions storage-version drift: ${storageVersionHex}`);
  }
  if (runtimeWasmSha256 !== expectedRuntimeWasmSha256) {
    throw new Error(
      `Runtime WASM drift: ${runtimeWasmSha256} != ${expectedRuntimeWasmSha256}`,
    );
  }
  if (runtimeCode.length !== expectedRuntimeCodeBytes) {
    throw new Error(
      `Runtime WASM length drift: ${runtimeCode.length} != ${expectedRuntimeCodeBytes}`,
    );
  }

  const summary = {
    capturedAtUtc: new Date().toISOString(),
    endpoint: publicEndpoint,
    chainName,
    genesisHash,
    runtimeVersion,
    metadataVersion,
    metadataBytes: metadata.length,
    metadataSha256,
    runtimeCodeBytes: runtimeCode.length,
    runtimeWasmSha256,
    aiPredictionsStorageVersionKey,
    aiPredictionsStorageVersionRaw: storageVersionHex,
    aiPredictionsStorageVersion: 3,
    finalizedHead,
    health,
    properties,
  };

  await mkdir('artifacts/phase6b', { recursive: true });
  await writeFile('artifacts/phase6b/era-spec13-metadata.scale', metadata);
  await writeFile(
    'artifacts/phase6b/era-spec13-runtime-rpc.json',
    `${JSON.stringify(summary, null, 2)}\n`,
  );
  process.stdout.write(`${JSON.stringify(summary, null, 2)}\n`);
} finally {
  clearTimeout(timeout);
  socket.close();
}

function parseLiveEndpoint(value) {
  let parsed;
  try {
    parsed = new URL(value);
  } catch {
    throw new Error('ERA_WS_ENDPOINT must be a valid WSS URL.');
  }
  if (parsed.protocol !== 'wss:' || !parsed.hostname) {
    throw new Error('ERA_WS_ENDPOINT must use WSS and include a host.');
  }
  return parsed;
}
