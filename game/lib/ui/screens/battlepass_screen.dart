import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mg_common_game/core/ui/theme/mg_colors.dart';
import 'package:mg_common_game/core/ui/layout/mg_spacing.dart';
import 'package:mg_common_game/core/ui/widgets/battlepass/battlepass.dart';
import 'package:mg_common_game/systems/battlepass/battlepass_config.dart';
import '../../features/battlepass/battlepass_adapter.dart';


/// BattlePass Screen -- powered by mg_common_game BattlePass widgets
class BattlepassScreen extends StatefulWidget {
  const BattlepassScreen({super.key});

  @override
  State<BattlepassScreen> createState() => _BattlepassScreenState();
}

class _BattlepassScreenState extends State<BattlepassScreen>
    with SingleTickerProviderStateMixin {
  late final TowerBattlePass _bp;
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _bp = GetIt.I<TowerBattlePass>();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Battle Pass'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: MGColors.gold,
          tabs: const [
            Tab(text: 'Rewards'),
            Tab(text: 'Missions'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _bp,
        builder: (context, _) {
          return Column(
            children: [
              // Header with season info, level, XP, premium CTA
              BattlePassHeader(
                seasonName: _bp.seasonName,
                currentLevel: _bp.currentLevel,
                maxLevel: _bp.maxLevel,
                currentExp: _bp.currentExp,
                expToNextLevel: _bp.expToNextLevel,
                remainingDays: _bp.remainingDays,
                isPremium: _bp.isPremium,
                onPurchasePremium: _bp.isPremium ? null : () {
                  _bp.purchasePremium();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Premium activated!')),
                    );
                  }
                },
              ),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // Tier rewards (horizontal scroll)
                    BattlePassTierList(
                      tiers: _bp.tiers,
                      currentLevel: _bp.currentLevel,
                      isPremium: _bp.isPremium,
                      claimedFreeLevels: _bp.claimedFreeLevels,
                      claimedPremiumLevels: _bp.claimedPremiumLevels,
                      onClaimReward: (level, isPremium) {
                        _bp.claimReward(level, isPremium: isPremium);
                      },
                    ),
                    // Mission list
                    Padding(
                      padding: EdgeInsets.all(MGSpacing.md),
                      child: BattlePassMissionList(
                        missions: _bp.missions,
                        missionProgress: _bp.missionProgress,
                        claimedMissions: _bp.claimedMissions,
                        onClaimMission: (id) => _bp.claimMission(id),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
