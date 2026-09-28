/// Default WebSocket endpoint for ERA chain.
/// This can be overridden at build time with:
/// flutter run --dart-define=ERA_WS_ENDPOINT=wss://mainnet.era.org/
const String kDefaultEraWsEndpoint = String.fromEnvironment(
  'ERA_WS_ENDPOINT',
  defaultValue: 'wss://eraprojects.org/', // dev default
);
