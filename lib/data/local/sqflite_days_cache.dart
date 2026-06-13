import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

import '/data/models/day.dart';
import '/data/local/offline_cache.dart';

/// SQLite-backed cache for programme days (Phase 4).
class SqfliteDaysCache implements OfflineDaysCache {
  SqfliteDaysCache._(this._db);

  final Database _db;
  static SqfliteDaysCache? _instance;

  static Future<SqfliteDaysCache> open() async {
    if (_instance != null) return _instance!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, 'paedia_days.db');
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE days (
            dayNumber INTEGER PRIMARY KEY,
            title TEXT,
            subtitle TEXT,
            preamble TEXT,
            scripture TEXT,
            callToPrayer TEXT,
            encouragementToRead TEXT,
            reflectionTitle TEXT,
            reflection TEXT,
            questionsTitle TEXT,
            questions TEXT,
            finalWord TEXT,
            illustration TEXT,
            updatedAt INTEGER
          )
        ''');
      },
    );
    _instance = SqfliteDaysCache._(db);
    return _instance!;
  }

  @override
  Future<Day?> getDay(int dayNumber) async {
    final rows = await _db.query(
      'days',
      where: 'dayNumber = ?',
      whereArgs: [dayNumber],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<void> putDay(Day day) async {
    await _db.insert(
      'days',
      _toRow(day),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> clear() async {
    await _db.delete('days');
  }

  Day _fromRow(Map<String, Object?> row) {
    return Day(
      dayNumber: row['dayNumber']! as int,
      title: row['title'] as String? ?? '',
      subtitle: row['subtitle'] as String? ?? '',
      preamble: row['preamble'] as String? ?? '',
      scripture: row['scripture'] as String? ?? '',
      callToPrayer: row['callToPrayer'] as String? ?? '',
      encouragementToRead: row['encouragementToRead'] as String? ?? '',
      reflectionTitle: row['reflectionTitle'] as String? ?? '',
      reflection: row['reflection'] as String? ?? '',
      questionsTitle: row['questionsTitle'] as String? ?? '',
      questions: row['questions'] as String? ?? '',
      finalWord: row['finalWord'] as String? ?? '',
      illustration: row['illustration'] as String? ?? '',
    );
  }

  Map<String, Object?> _toRow(Day day) {
    return {
      'dayNumber': day.dayNumber,
      'title': day.title,
      'subtitle': day.subtitle,
      'preamble': day.preamble,
      'scripture': day.scripture,
      'callToPrayer': day.callToPrayer,
      'encouragementToRead': day.encouragementToRead,
      'reflectionTitle': day.reflectionTitle,
      'reflection': day.reflection,
      'questionsTitle': day.questionsTitle,
      'questions': day.questions,
      'finalWord': day.finalWord,
      'illustration': day.illustration,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
