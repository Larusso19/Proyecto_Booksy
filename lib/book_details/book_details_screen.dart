import 'package:booksy_app/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../add_book/edit_book_screen.dart';
import '../model/book.dart';
import '../service/book_service.dart';

class BookDetailsScreen extends StatelessWidget {
  final Book _book;

  const BookDetailsScreen(this._book, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del libro'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BookCoverWidget(_book.coverUrl),
            BookInfoWidget(_book.name, _book.author, _book.summary),
            BottomActionWidget(_book), // Aquí pasamos el objeto completo.
          ],
        ),
      ),
    );
  }
}


class BottomActionWidget extends StatelessWidget {
  final Book book;

  const BottomActionWidget(this.book, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BlocBuilder<BookshelfBloc, BookshelfState>(
            builder: (context, bookshelfState) {
              var action = () => _addToBookshelf(context, book.id);
              var label = 'Agregar a mi Estante';
              var color = Colors.green;
              if (bookshelfState.bookIds.contains(book.id)) {
                action = () => _removeFromBookshelf(context, book.id);
                label = 'Eliminar de mi Estante';
                color = Colors.amber;
              }
              return ElevatedButton(
                onPressed: action,
                style: ElevatedButton.styleFrom(backgroundColor: color),
                child: Text(label, style: const TextStyle(color: Colors.white)),
              );
            }),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _deleteBook(context, book.id),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar Libro', style: TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditBookScreen(book: book),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('Editar Libro', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _addToBookshelf(BuildContext context, String bookId) {
    var bookshelfBloc = context.read<BookshelfBloc>();
    bookshelfBloc.add(AddBookToBookshelf(bookId));
  }

  void _removeFromBookshelf(BuildContext context, String bookId) {
    var bookshelfBloc = context.read<BookshelfBloc>();
    bookshelfBloc.add(RemoveBookFromBookshelf(bookId));
  }

  void _deleteBook(BuildContext context, String bookId) async {
    try {
      await BooksService().deleteBook(bookId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Libro eliminado correctamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el libro: $e')),
      );
    }
  }
}


class BookInfoWidget extends StatelessWidget {
  final String _name;
  final String _author;
  final String _description;

  const BookInfoWidget(this._name, this._author, this._description, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        children: [
          Text(_name, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 10),
          Text(_author, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Text(_description, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}

class BookCoverWidget extends StatelessWidget {
  final String _coverUrl;

  const BookCoverWidget(this._coverUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      width: 230,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 20,
          ),
        ],
      ),
      child: _coverUrl.startsWith("http")
          ? Image.network(
        _coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      )
          : Image.asset(_coverUrl),
    );
  }
}
