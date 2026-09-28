import 'package:flutter/material.dart';

import 'era_v14_compatibility.dart';

class EraStakingRewardNotice extends StatelessWidget {
  const EraStakingRewardNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: Icon(Icons.info_outline),
        title: Text('Current staking rewards'),
        subtitle: Text(kEraStakingRewardNotice),
      ),
    );
  }
}
