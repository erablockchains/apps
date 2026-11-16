/// Disposable, in-memory examples for the App Review demonstration.
///
/// This model has no wallet, RPC, key, storage or transaction dependency.
/// It is recreated every time the demonstration is opened.
class DemoSession {
  DemoSession();

  static const fee = 0.01;
  final accounts = <String>['Demo Reviewer'];
  final activity = <String>[];
  String activeAccount = 'Demo Reviewer';
  double available = 12;
  double bonded = 3;
  double pendingUnbond = 0;
  bool connected = true;
  bool rewardClaimed = false;
  int _nextAccount = 2;

  static const address = 'DEMO-ERA-ADDRESS-NOT-ON-CHAIN';
  static const recipient = 'DEMO-RECIPIENT-NOT-ON-CHAIN';

  String createAccount() {
    final name = 'Demo Account ${_nextAccount++}';
    accounts.add(name);
    activeAccount = name;
    return name;
  }

  String importFixture() {
    final name = 'Imported Demo Fixture ${_nextAccount++}';
    accounts.add(name);
    activeAccount = name;
    return name;
  }

  String? send({required String to, required double amount}) {
    if (!connected) return 'Demo connection is offline. Reconnect first.';
    if (to.trim().isEmpty || amount <= 0 || !amount.isFinite) {
      return 'Enter a demo recipient and a positive amount.';
    }
    if (amount + fee > available) return 'Insufficient synthetic balance.';
    available -= amount + fee;
    activity.insert(0, 'Synthetic transfer: ${amount.toStringAsFixed(2)} ETKN');
    return null;
  }

  String? bond(double amount) {
    if (!connected) return 'Demo connection is offline. Reconnect first.';
    if (amount <= 0 || amount > available) {
      return 'Insufficient synthetic balance for bond.';
    }
    available -= amount;
    bonded += amount;
    activity.insert(0, 'Synthetic bond and nomination: $amount ETKN');
    return null;
  }

  String? unbond(double amount) {
    if (!connected) return 'Demo connection is offline. Reconnect first.';
    if (amount <= 0 || amount > bonded) {
      return 'Insufficient synthetic bonded balance.';
    }
    bonded -= amount;
    pendingUnbond += amount;
    activity.insert(0, 'Synthetic unbond queued: $amount ETKN');
    return null;
  }

  String? claimReward() {
    if (!connected) return 'Demo connection is offline. Reconnect first.';
    if (rewardClaimed) return 'Synthetic reward already claimed.';
    rewardClaimed = true;
    available += 0.5;
    activity.insert(0, 'Synthetic reward claim: 0.50 ETKN');
    return null;
  }
}
