import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class LeaderboardEntry {
  final String userId;
  final String username;
  final int score;
  final int wave;
  final DateTime timestamp;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.score,
    required this.wave,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'score': score,
      'wave': wave,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['userId'] as String,
      username: json['username'] as String,
      score: json['score'] as int,
      wave: json['wave'] as int,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}

class LeaderboardManager {
  static final LeaderboardManager _instance = LeaderboardManager._internal();
  factory LeaderboardManager() => _instance;
  LeaderboardManager._internal();

  final _logger = Logger();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  static const String _collectionName = 'leaderboard';
  static const int _topScores = 100;

  Future<bool> submitScore({
    required String username,
    required int score,
    required int wave,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _logger.w('No authenticated user found');
        return false;
      }

      final entry = LeaderboardEntry(
        userId: user.uid,
        username: username,
        score: score,
        wave: wave,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .set(entry.toJson(), SetOptions(merge: true));

      _logger.i('Score submitted: $score (wave: $wave)');
      return true;
    } catch (e) {
      _logger.e('Failed to submit score: $e');
      return false;
    }
  }

  Future<List<LeaderboardEntry>> getTopScores() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .orderBy('score', descending: true)
          .limit(_topScores)
          .get();

      final entries = snapshot.docs.map((doc) {
        return LeaderboardEntry.fromJson(doc.data());
      }).toList();

      _logger.i('Retrieved ${entries.length} top scores');
      return entries;
    } catch (e) {
      _logger.e('Failed to get top scores: $e');
      return [];
    }
  }

  Future<LeaderboardEntry?> getUserBestScore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final doc = await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return LeaderboardEntry.fromJson(doc.data()!);
    } catch (e) {
      _logger.e('Failed to get user best score: $e');
      return null;
    }
  }

  Future<int?> getUserRank() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return null;
      }

      final userDoc = await _firestore
          .collection(_collectionName)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return null;
      }

      final userScore = userDoc.data()?['score'] as int?;
      if (userScore == null) {
        return null;
      }

      final countSnapshot = await _firestore
          .collection(_collectionName)
          .where('score', isGreaterThan: userScore)
          .count()
          .get();

      return (countSnapshot.count ?? 0) + 1;
    } catch (e) {
      _logger.e('Failed to get user rank: $e');
      return null;
    }
  }

  Future<List<LeaderboardEntry>> getNearbyRanks({int range = 5}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return [];
      }

      final userRank = await getUserRank();
      if (userRank == null) {
        return [];
      }

      final startRank = (userRank - range).clamp(1, 999999).toInt();
      final endRank = userRank + range;

      final allScores = await _firestore
          .collection(_collectionName)
          .orderBy('score', descending: true)
          .get();

      final entries = allScores.docs
          .skip(startRank - 1)
          .take(range * 2 + 1)
          .map((doc) => LeaderboardEntry.fromJson(doc.data()))
          .toList();

      return entries;
    } catch (e) {
      _logger.e('Failed to get nearby ranks: $e');
      return [];
    }
  }
}
