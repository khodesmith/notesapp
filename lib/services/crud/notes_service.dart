import 'package:flutter/foundation.dart';
import "package:sqflite/sqflite.dart";
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

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

const idColumn = "id";
const emailColumn = "email";
const userIdColumn = "user_id";
const noteTextColumn = "note_text";
const isSyncedWithCloudColumn = "is_synced_with_cloud_column";
