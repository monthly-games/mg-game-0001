import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/widgets/gacha/gacha.dart';
import 'package:mg_common_game/systems/gacha/gacha_pool.dart';
import '../../features/gacha/gacha_adapter.dart';


/// Gacha Screen -- powered by mg_common_game GachaPullAnimation widget
class GachaScreen extends StatefulWidget {
  const GachaScreen({super.key});

  @override
  State<GachaScreen> createState() => _GachaScreenState();
}

class _GachaScreenState extends State<GachaScreen> {
  late final TowerGachaAdapter _gacha;
  List<GachaItem> _pullResults = [];
  bool _showAnimation = false;

  @override
  void initState() {
    super.initState();
    _gacha = GetIt.I<TowerGachaAdapter>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0f0f23),
      appBar: AppBar(
        title: const Text('Tower Summon'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _showAnimation
          ? GachaPullAnimation(
              results: _pullResults,
              onComplete: () => setState(() => _showAnimation = false),
            )
          : ListenableBuilder(
              listenable: _gacha,
              builder: (context, _) => _buildMainView(),
            ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(MGSpacing.md),
      child: Column(
        children: [
          // Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(MGSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  MGColors.gem.withValues(alpha: 0.3),
                  MGColors.gem.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: MGColors.gem.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_awesome, size: 48, color: Colors.white),
                SizedBox(height: MGSpacing.sm),
                const Text('Tower Summon',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: MGSpacing.xs),
                const Text('Featured: Legendary Tower Archer',
                    style: TextStyle(fontSize: 14, color: Colors.white70)),
              ],
            ),
          ),
          SizedBox(height: MGSpacing.lg),
          // Pity
          Container(
            padding: EdgeInsets.symmetric(horizontal: MGSpacing.md, vertical: MGSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pity Counter', style: TextStyle(color: Colors.white70, fontSize: 14)),
                Text('${_gacha.totalPulls % 90} / 90',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: MGSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_gacha.totalPulls % 90) / 90,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation<Color>(MGColors.gem),
              minHeight: 6,
            ),
          ),
          SizedBox(height: MGSpacing.lg),
          // Pull buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final r = _gacha.pullSingle();
                    if (r != null) {
                      setState(() { _pullResults = [r]; _showAnimation = true; });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: MGSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: MGColors.gem.withValues(alpha: 0.5)),
                    ),
                  ),
                  child: const Text('Summon x1'),
                ),
              ),
              SizedBox(width: MGSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final r = _gacha.pullTen();
                    setState(() { _pullResults = r; _showAnimation = true; });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MGColors.gem,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: MGSpacing.md),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Summon x10'),
                ),
              ),
            ],
          ),
          SizedBox(height: MGSpacing.lg),
          // Results
          if (_pullResults.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Last Results', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: MGSpacing.sm),
            ..._pullResults.map((item) => Container(
              margin: EdgeInsets.only(bottom: MGSpacing.xs),
              padding: EdgeInsets.all(MGSpacing.sm),
              decoration: BoxDecoration(
                color: _rarityColor(item.rarity).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _rarityColor(item.rarity).withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Icon(Icons.star, color: _rarityColor(item.rarity), size: 20),
                SizedBox(width: MGSpacing.sm),
                Text(item.nameKr, style: TextStyle(color: _rarityColor(item.rarity), fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(item.rarity.name.toUpperCase(), style: TextStyle(color: _rarityColor(item.rarity), fontSize: 12)),
              ]),
            )),
          ],
        ],
      ),
    );
  }

  Color _rarityColor(GachaRarity r) => switch (r) {
    GachaRarity.legendary => MGColors.legendary,
    GachaRarity.superRare => MGColors.epic,
    GachaRarity.ultraRare => MGColors.epic,
    GachaRarity.superRare => MGColors.rare,
    GachaRarity.rare => MGColors.uncommon,
    GachaRarity.normal => MGColors.common,
  };
}
