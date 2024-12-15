import 'package:booksy_app/add_book/add_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../book_details/book_details_screen.dart';
import '../model/book.dart';
import '../service/book_service.dart';
import '../state.dart';

class BookshelfScreen extends StatelessWidget {
  const BookshelfScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookshelfBloc, BookshelfState>(
        builder: (context, bookshelfState) {
          var emptyListWidget =  Center(
              child: Text(
                "No hay libros en tu estante",
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ));
          var mainWidget = bookshelfState.bookIds.isEmpty
              ? emptyListWidget
              : MyBooksGrid(bookshelfState.bookIds);

      return Column(
        children: [
          Expanded(child: mainWidget),
          ElevatedButton(onPressed: (){
            _navigateToAddNewBookScreen(context);
          },style:
          ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text("Agregar un Libro", style: TextStyle(color: Colors.white),))
        ],
      );
    });
  }
}

void _navigateToAddNewBookScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const AddBookScreen()),
  );
}

class MyBooksGrid extends StatelessWidget{
  final List<String> bookIds;
  const MyBooksGrid(this.bookIds , {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        itemCount: bookIds.length,
        itemBuilder: (context, index) {
          return BookCoverItem(bookIds[index]);
        },
      ),
    );
  }

}

class BookCoverItem extends StatefulWidget {
  final String _bookId;

  const BookCoverItem(this._bookId, {super.key});

  @override
  State<BookCoverItem> createState() => _BookCoverItemState();
}

class _BookCoverItemState extends State<BookCoverItem> {
  Book? _book;

  @override
  void initState() {
    super.initState();
    _fetchBook(widget._bookId);
  }
  void _fetchBook(String bookId) async {
    var book = await BooksService().getBook(bookId); // Fetch book data
    setState(() {
      _book = book;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_book == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: () => _openBookDetail(_book!, context), // Navigation on tap
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10), // Adds rounded corners
        child: _getImageWidget(_book!.coverUrl),
      ),
    );
  }

  Widget _getImageWidget(String coverUrl) {
    if (coverUrl.startsWith("http")) {
      return Image.network(
        coverUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.broken_image, size: 50);
        },
      );
    } else {
      return Image.asset(
        coverUrl,
        fit: BoxFit.cover,
      );
    }
  }

  void _openBookDetail(Book book, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailsScreen(book),
      ),
    );
  }
}
