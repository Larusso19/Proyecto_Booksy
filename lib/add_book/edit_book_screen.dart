import 'package:flutter/material.dart';
import '../model/book.dart';
import '../service/book_service.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({required this.book, super.key});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _author;
  late String _summary;

  @override
  void initState() {
    super.initState();
    _name = widget.book.name;
    _author = widget.book.author;
    _summary = widget.book.summary;
  }

  void _updateBook() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await BooksService().updateBookDetail(
          widget.book.id,
          _name,
          _author,
          _summary,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Libro actualizado correctamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar el libro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Libro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _author,
                decoration: const InputDecoration(labelText: 'Autor'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un autor';
                  }
                  return null;
                },
                onSaved: (value) => _author = value!,
              ),
              TextFormField(
                initialValue: _summary,
                decoration: const InputDecoration(labelText: 'Resumen'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un resumen';
                  }
                  return null;
                },
                onSaved: (value) => _summary = value!,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateBook,
                child: const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
