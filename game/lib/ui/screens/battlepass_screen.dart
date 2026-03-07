import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/battlepass/battlepass_adapter.dart';

/// Battlepass Screen - Placeholder Implementation
/// TODO: Complete UI implementation following docs/BATTLEPASS_GACHA_ACTIVATION_GUIDE.md
class BattlepassScreen extends StatefulWidget {
  const BattlepassScreen({super.key});

  @override
  State<BattlepassScreen> createState() => _BattlepassScreenState();
}

class _BattlepassScreenState extends State<BattlepassScreen> {
  late final TowerBattlePass _battlepass;

  @override
  void initState() {
    super.initState();
    _battlepass = GetIt.I<TowerBattlePass>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battle Pass'),
        backgroundColor: Colors.green,
      ),
      body: ListenableBuilder(
        listenable: _battlepass,
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Battle Pass',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Level: ${_battlepass.currentLevel}'),
                Text('EXP: ${_battlepass.currentExp} / 1000'),
                Text('Premium: ${_battlepass.isPremium ? "Yes" : "No"}'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    _battlepass.addExp(100);
                  },
                  child: const Text('Add 100 EXP (Test)'),
                ),
                if (!_battlepass.isPremium) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _battlepass.purchasePremium();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Premium activated!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                    child: const Text('Upgrade to Premium (\$9.99)'),
                  ),
                ],
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'TODO: Implement full UI with missions, rewards, and premium track',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
