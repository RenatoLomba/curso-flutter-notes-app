import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notes_app/note.dart';

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
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  Future<List<Note>> _getNotes() async {
    List<Note> notes = [
      Note.fromMap({
        'id': 1,
        'title': 'Teste 1',
        'description': 'lorem ipsum dolor sit amet',
        'createdAt': DateTime.now(),
      }),
      Note.fromMap({
        'id': 2,
        'title': 'Teste 2',
        'description': 'lorem ipsum dolor sit amet',
        'createdAt': DateTime.now(),
      }),
    ];

    return Future.delayed(const Duration(milliseconds: 1000), () {
      return notes;
    });
  }

  _createNote() {
    Navigator.pop(context);
  }

  _updateNote(int id) {
    Navigator.pop(context);
  }

  _showNoteManagementDialog(ManagementDialogType type, {int? id}) {
    var isCreating = type == ManagementDialogType.create;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            '${isCreating ? 'Adicionar' : 'Atualizar'} anotação'
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.pop(ctx);
              },
            ),
            TextButton(
              child: Text(isCreating ? 'Adicionar' : 'Atualizar'),
              onPressed: () {
                if (isCreating) {
                  _createNote();
                } else {
                  _updateNote(id!);
                }
              },
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(label: Text('Título')),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(label: Text('Descrição')),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          shape: const BeveledRectangleBorder(),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text('Anotações', style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNoteManagementDialog(ManagementDialogType.create);
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Note>>(
        initialData: const [],
        future: _getNotes(),
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

              return Expanded(
                child: ListView.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, idx) => const Divider(
                    height: 2,
                    color: Colors.black12,
                  ),
                  itemBuilder: (ctx, idx) {
                    var note = notes[idx];

                    var day = note.createdAt.day.toString().padLeft(2, '0');
                    var month = note.createdAt.month.toString().padLeft(2, '0');
                    var year = note.createdAt.year;
                    var hour = note.createdAt.hour.toString().padLeft(2, '0');
                    var minutes = note.createdAt.minute.toString().padLeft(2, '0');

                    return ListTile(
                      title: Text(note.title),
                      subtitle: Text(
                        '$day/$month/$year às $hour:$minutes - ${note.description}',
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
