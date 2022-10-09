import 'package:flutter/foundation.dart';
import "package:sqflite/sqflite.dart";
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

class DatabaseAlreadyOpenException implements Exception {}

class UnableToGetDocumentsDirectory implements Exception {}

class NotesService {
  Database? _db;

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;

//create the user table
      const createuserTable = '''
          CREATE TABLE IF NOT EXISTS "user" (
            "id"	INTEGER NOT NULL,
            "email"	TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id" AUTOINCREMENT)
          );
''';

      await db.execute(createuserTable);

//create note table
      const createnoteTable = '''
                CREATE TABLE IF NOT EXISTS "note" (
                  "id"	INTEGER NOT NULL,
                  "user_id"	INTEGER NOT NULL,
                  "note_text"	TEXT,
                  "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
                  FOREIGN KEY("user_id") REFERENCES "user"("id"),
                  PRIMARY KEY("id" AUTOINCREMENT)
                );
              ''';
      await db.execute(createnoteTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => "Person, ID =$id, email = $email";

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNote {
  final int id;
  final int userId;
  final String noteText;
  final bool isSyncedWithCloud;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.noteText,
    required this.isSyncedWithCloud,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        noteText = map[noteTextColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Note, ID = $id, userId = $userId, isSyncedWithCloud = $isSyncedWithCloud";

  @override
  bool operator ==(covariant DatabaseNote other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const dbName = "notes.db";
const notesTable = "note";
const userTable = "user";

const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const noteTextColumn = "note_text";
const isSyncedWithCloudColumn = "is_synced_with_cloud_column";
