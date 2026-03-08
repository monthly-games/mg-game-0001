import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/gacha/gacha_adapter.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';

/// Gacha Screen - Placeholder Implementation  
/// TODO: Complete UI implementation following docs/BATTLEPASS_GACHA_ACTIVATION_GUIDE.md
class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  late final TowerGachaAdapter _gacha;
  List<dynamic> _pullResults = [];

  @override
  void initState() {
    super.initState();
    _gacha = GetIt.I<TowerGachaAdapter>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gacha'),
        backgroundColor: Colors.purple,
      ),
      body: ListenableBuilder(
        listenable: _gacha,
        builder: (context, _) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Tower Gacha',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Pity: ${_gacha.pullsUntilPity} pulls remaining'),
                Text('Total Pulls: ${_gacha.totalPulls}'),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pullSingle,
                      child: const Text('Pull x1'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _pullTen,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                      child: const Text('Pull x10'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (_pullResults.isNotEmpty) ...[
                  const Text(
                    'Last Pull Results:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _pullResults.length,
                      itemBuilder: (context, index) {
                        final item = _pullResults[index];
                        return ListTile(
                          leading: Icon(Icons.star, color: _getRarityColor(item.rarity)),
                          title: Text(item.name ?? 'Unknown'),
                          subtitle: Text(item.rarity.toString().split('.').last),
                        );
                      },
                    ),
                  ),
                ],
                if (_pullResults.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'TODO: Implement full UI with pity counter, history, and animations',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: MGColors.common),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getRarityColor(dynamic rarity) {
    final rarityStr = rarity.toString().toLowerCase();
    if (rarityStr.contains('ultrarare')) return MGColors.error;
    if (rarityStr.contains('supersuperrare')) return MGColors.warning;
    if (rarityStr.contains('superrare')) return MGColors.info;
    if (rarityStr.contains('rare')) return MGColors.success;
    return MGColors.common;
  }

  void _pullSingle() {
    final result = _gacha.pullSingle();
    setState(() {
      _pullResults = [result];
    });
  }

  void _pullTen() {
    final results = _gacha.pullTen();
    setState(() {
      _pullResults = results;
    });
  }
}
