import 'package:notes_app/note.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static const notesTableName = 'notes';
  static final AppDatabase _appDatabase = AppDatabase._();
  Database? _db;

  factory AppDatabase() => _appDatabase;

  AppDatabase._();

  Future<Database> get db async {
    _db ??= await _databaseInit();
    return _db!;
  }

  Future<void> _onCreateDatabase(Database database, int version) async {
    String sql = 'CREATE TABLE $notesTableName (id INTEGER PRIMARY KEY AUTOINCREMENT, title VARCHAR, description TEXT, createdAt DATETIME)';
    await database.execute(sql);
  }

  Future<Database> _databaseInit() async {
    final String dbPath = await getDatabasesPath();
    final String localDbPath = join(dbPath, 'notes_app.db');

    var database = await openDatabase(
      localDbPath,
      version: 1,
      onCreate: _onCreateDatabase,
    );

    return database;
  }

  Future<Note> createNote(String title, String description) async {
    var database = await db;

    Note newNote = Note.create(title: title, description: description);
    int newNoteId = await database.insert(notesTableName, newNote.toMap());
    newNote.id = newNoteId;
    return newNote;
  }

  Future<List<Note>> getNotes() async {
    var database = await db;

    var data = await database.query(
      notesTableName,
      columns: ['id', 'title', 'description', 'createdAt'],
      limit: 15,
      orderBy: 'createdAt DESC',
    );

    List<Note> notes = data.map((d) => Note.fromMap(d)).toList();
    return notes;
  }

  Future<Note?> getNote(int id) async {
    var database = await db;

    var data = await database.query(
      notesTableName,
      columns: ['id', 'title', 'description', 'createdAt'],
      where: 'id = ?',
      whereArgs: [id],
    );
    var row = data[0];

    return Note.fromMap(row);
  }

  Future<void> updateNote(int id, String title, String description) async {
    var database = await db;

    await database.update(
      notesTableName,
      {
        'title': title,
        'description': description,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteNote(int id) async {
    var database = await db;

    await database.delete(
      notesTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
