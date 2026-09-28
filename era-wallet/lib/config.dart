/// Reviewed public ERA WebSocket endpoint.
const String kOfficialEraWsEndpoint = 'wss://eraprojects.org/';

/// Configured WebSocket endpoint for ERA chain.
///
/// Production builds accept only [kOfficialEraWsEndpoint]. Developers must
/// explicitly opt into another secure endpoint with
/// `ALLOW_NON_PRODUCTION_ERA_ENDPOINT=true`. Insecure `ws://` endpoints are
/// always rejected, and there is no automatic fallback to another node.
const String kDefaultEraWsEndpoint = String.fromEnvironment(
  'ERA_WS_ENDPOINT',
  defaultValue: kOfficialEraWsEndpoint,
);

const bool kAllowNonProductionEraEndpoint = bool.fromEnvironment(
  'ALLOW_NON_PRODUCTION_ERA_ENDPOINT',
  defaultValue: false,
);

Uri validateEraWsEndpoint(String endpoint) {
  final uri = Uri.tryParse(endpoint);
  if (uri == null || uri.scheme != 'wss' || uri.host.isEmpty) {
    throw StateError('ERA Wallet requires a valid secure wss:// endpoint.');
  }
  if (!kAllowNonProductionEraEndpoint && endpoint != kOfficialEraWsEndpoint) {
    throw StateError(
      'This participant build accepts only the reviewed ERA endpoint.',
    );
  }
  return uri;
}
