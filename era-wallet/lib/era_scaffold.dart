import 'package:flutter/material.dart';

/// Shared wallet layout. Keep page content clear of decorative imagery.
class EraScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final bool resizeToAvoidBottomInset;

  const EraScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: SafeArea(
        child: Padding(padding: const EdgeInsets.all(12.0), child: body),
      ),
    );
  }
}
