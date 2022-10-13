import 'package:flutter/foundation.dart';
import "package:sqflite/sqflite.dart";
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;

import 'crud_exceptions.dart';

class NotesService {
  Database? _db;

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseorThrow();

    await getNote(id: note.id);
    final updateCount = await db.update(notesTable, {
      noteTextColumn: text,
      isSyncedWithCloudColumn: 0,
    });

    if (updateCount == 0) {
      throw CouldNotUpdateNote();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseorThrow();
    final allNote = await db.query(notesTable);

    return allNote.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseorThrow();
    final note = await db.query(
      notesTable,
      limit: 1,
      where: "id = ?",
      whereArgs: [id],
    );
    if (note.isEmpty) {
      throw CouldNotFindNote();
    } else {
      return DatabaseNote.fromRow(note.first);
    }
  }

  Future<int> deleteAllNote() async {
    final db = _getDatabaseorThrow();
    return await db.delete(notesTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseorThrow();

    final deleteCount = await db.delete(
      notesTable,
      where: "id: ?",
      whereArgs: [id],
    );
    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseorThrow();

    //make sure owner exists in the correct database with theright id
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUser();
    }

    const text = "";
    //make the notes
    final noteId = await db.insert(notesTable, {
      userIdColumn: owner.id,
      noteTextColumn: text,
      isSyncedWithCloudColumn: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      noteText: text,
      isSyncedWithCloud: true,
    );
    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseorThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );

    if (result.isEmpty) {
      throw CouldNotFindUser();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseorThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: "email = ?",
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    }
    final userId = await db.insert(
      userTable,
      {emailColumn: email.toLowerCase()},
    );

    return DatabaseUser(
      id: userId,
      email: email,
    );
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseorThrow();
    final deletedCount = db.delete(
      userTable,
      where: "email =?",
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Database _getDatabaseorThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DataBaseIsNotOpenException();
    } else {
      await db.close();
      _db = null;
    }
  }

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
      await db.execute(createuserTable);
//create note table
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
const createuserTable = '''
          CREATE TABLE IF NOT EXISTS "user" (
            "id"	INTEGER NOT NULL,
            "email"	TEXT NOT NULL UNIQUE,
            PRIMARY KEY("id" AUTOINCREMENT)
          );
''';
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
