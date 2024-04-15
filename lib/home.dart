import 'dart:async';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/material.dart';

import 'package:notes_app/database.dart';
import 'package:notes_app/note.dart';
import 'package:notes_app/note_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum ManagementDialogType {
  create,
  update,
}

class _MyHomePageState extends State<MyHomePage> {
  final AppDatabase _appDatabase = AppDatabase();
  Future<List<Note>>? _futureGetNotes;

  Future<List<Note>> _getNotes() async => _appDatabase.getNotes();

  Future<void> _createNote(String title, String description) async {
    await _appDatabase.createNote(title, description);

    setState(() {
      _futureGetNotes = _getNotes();
    });
  }

  Future<void> _updateNote(int id, String title, String description) async {
    await _appDatabase.updateNote(id, title, description);

    setState(() {
      _futureGetNotes = _getNotes();
    });
  }

  Future<void> _deleteNote(int id) async {
    await _appDatabase.deleteNote(id);

    setState(() {
      _futureGetNotes = _getNotes();
    });
  }

  Future<void> _showNoteManagementDialog(ManagementDialogType type, {int? id}) async {
    var isCreating = type == ManagementDialogType.create;

    Note? note;

    if (!isCreating) {
      note = await _appDatabase.getNote(id!);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) {
        return NoteDialog(
          titleFieldInitialValue: note?.title,
          descriptionFieldInitialValue: note?.description,
          title: '${isCreating ? 'Adicionar' : 'Atualizar'} anotação',
          onPressed: (title, description) async {
            if (isCreating) {
              await _createNote(title, description);
            } else {
              await _updateNote(id!, title, description);
            }
          },
          confirmButtonText: isCreating ? 'Adicionar' : 'Atualizar'
        );
      }
    );
  }

  String _formatDatetime(DateTime date) {
    initializeDateFormatting('pt_BR', null);
    Intl.defaultLocale = 'pt_BR';

    var formatter = DateFormat.yMd().add_Hm();
    return formatter.format(date);
  }

  void _showDeleteNoteConfirmationDialog(int id, String title) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Tem certeza que deseja remover a anotação "$title"?'),
          backgroundColor: Colors.white,
          shape: const BeveledRectangleBorder(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteNote(id);

                if(mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Sim'),
            ),
          ],
        );
      }
    );
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _futureGetNotes = _getNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text('Anotações', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await _showNoteManagementDialog(ManagementDialogType.create);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Note>>(
              initialData: const [],
              future: _futureGetNotes,
              builder: (_, snapshot) {
                switch(snapshot.connectionState) {
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.lightGreen),
                    );
                  case ConnectionState.active:
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar anotações.'));
                    }

                    var notes = snapshot.data;

                    if (notes == null || notes.isEmpty) {
                      return const Center(child: Text('Nenhuma anotação encontrada.'));
                    }

                    return ListView.builder(
                      itemCount: notes.length,
                      itemBuilder: (ctx, idx) {
                        final Note note = notes[idx];

                        return Card(
                          color: Colors.white,
                          child: ListTile(
                            title: Text(note.title),
                            subtitle: Text(
                              '${_formatDatetime(note.createdAt)} - ${note.description}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () async {
                                    await _showNoteManagementDialog(
                                      ManagementDialogType.update,
                                      id: note.id,
                                    );
                                  },
                                  color: Colors.green,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _showDeleteNoteConfirmationDialog(
                                      note.id!,
                                      note.title,
                                    );
                                  },
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
