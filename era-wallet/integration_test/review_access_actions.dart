// Test-only selectors shared by the simulator capture and its regression test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapCreateAccountAction(WidgetTester tester) async {
  // The title and explanatory heading have the same text as the action.
  final action = find.ancestor(
    of: find.text('Create Account'),
    matching: find.byWidgetPredicate((widget) => widget is FilledButton),
  );
  expect(action, findsOneWidget, reason: 'Select the action, never a heading.');
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.ensureVisible(action);
  await tester.tap(action);
  await tester.pump(const Duration(milliseconds: 100));
}

void pauseReviewApp(WidgetTester tester) {
  for (final state in <AppLifecycleState>[
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}

void resumeReviewApp(WidgetTester tester) {
  for (final state in <AppLifecycleState>[
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
}
