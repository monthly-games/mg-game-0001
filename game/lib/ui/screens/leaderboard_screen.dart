import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/leaderboard/leaderboard_manager.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _leaderboardManager = LeaderboardManager();
  List<LeaderboardEntry> _topScores = [];
  LeaderboardEntry? _userBestScore;
  int? _userRank;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    final scores = await _leaderboardManager.getTopScores();
    final userBest = await _leaderboardManager.getUserBestScore();
    final rank = await _leaderboardManager.getUserRank();

    setState(() {
      _topScores = scores;
      _userBestScore = userBest;
      _userRank = rank;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: const Color(0xFF16213e),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFe94560)),
            )
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: Column(
                children: [
                  if (_userBestScore != null) _buildUserScoreCard(),
                  Expanded(child: _buildLeaderboardList()),
                ],
              ),
            ),
    );
  }

  Widget _buildUserScoreCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFe94560), Color(0xFF0f3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFe94560).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Best Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_userBestScore!.score}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.military_tech, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Rank: #${_userRank ?? "?"}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.waves, color: Colors.cyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Wave: ${_userBestScore!.wave}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardList() {
    if (_topScores.isEmpty) {
      return const Center(
        child: Text(
          'No scores yet. Be the first!',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _topScores.length,
      itemBuilder: (context, index) {
        final entry = _topScores[index];
        final rank = index + 1;

        return _buildLeaderboardItem(rank, entry);
      },
    );
  }

  Widget _buildLeaderboardItem(int rank, LeaderboardEntry entry) {
    Color rankColor;
    IconData rankIcon;

    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey;
      rankIcon = Icons.military_tech;
    } else if (rank == 3) {
      rankColor = Colors.brown;
      rankIcon = Icons.military_tech;
    } else {
      rankColor = Colors.white54;
      rankIcon = Icons.star_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213e),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rank <= 3 ? rankColor.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(rankIcon, color: rankColor, size: 28)
                  : Text(
                      '#$rank',
                      style: TextStyle(
                        color: rankColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.waves, color: Colors.cyan, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Wave ${entry.wave}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: Color(0xFFe94560),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
