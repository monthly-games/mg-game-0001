import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tower_defense/features/leaderboard/leaderboard_manager.dart';

void main() {
  group('LeaderboardEntry', () {
    test('serializes to firestore-compatible json', () {
      final timestamp = DateTime.utc(2026, 5, 22, 12, 30);
      final entry = LeaderboardEntry(
        userId: 'user-1',
        username: 'Player One',
        score: 12500,
        wave: 18,
        timestamp: timestamp,
      );

      final json = entry.toJson();

      expect(json['userId'], 'user-1');
      expect(json['username'], 'Player One');
      expect(json['score'], 12500);
      expect(json['wave'], 18);
      expect(json['timestamp'], isA<Timestamp>());
      expect((json['timestamp'] as Timestamp).toDate().toUtc(), timestamp);
    });

    test('parses firestore json without losing rank data', () {
      final timestamp = DateTime.utc(2026, 5, 22, 9, 15);

      final entry = LeaderboardEntry.fromJson({
        'userId': 'user-2',
        'username': 'Runner',
        'score': 9800,
        'wave': 14,
        'timestamp': Timestamp.fromDate(timestamp),
      });

      expect(entry.userId, 'user-2');
      expect(entry.username, 'Runner');
      expect(entry.score, 9800);
      expect(entry.wave, 14);
      expect(entry.timestamp.toUtc(), timestamp);
    });
  });
}
