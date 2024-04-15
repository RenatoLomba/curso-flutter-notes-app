import 'package:flutter/material.dart';

class NoteDialog extends StatefulWidget {
  const NoteDialog({
    super.key,
    required this.title,
    required this.onPressed,
    required this.confirmButtonText,
    this.titleFieldInitialValue,
    this.descriptionFieldInitialValue,
  });

  final String title;
  final String confirmButtonText;
  final Future<void> Function(String title, String description) onPressed;
  final String? titleFieldInitialValue;
  final String? descriptionFieldInitialValue;

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _close() {
    _titleController.clear();
    _descriptionController.clear();
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();

    if (widget.titleFieldInitialValue != null) {
      _titleController.text = widget.titleFieldInitialValue!;
    }

    if (widget.descriptionFieldInitialValue != null) {
      _descriptionController.text = widget.descriptionFieldInitialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      actions: [
        TextButton(
          onPressed: _close,
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () async {
            await widget.onPressed(
              _titleController.text,
              _descriptionController.text,
            );

            _close();
          },
          child: Text(widget.confirmButtonText),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              label: Text('Título'),
              hintText: 'Digite o título',
            ),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              label: Text('Descrição'),
              hintText: 'Digite a descrição',
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      shape: const BeveledRectangleBorder(),
    );
  }
}
