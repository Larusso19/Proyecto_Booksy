import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import '../model/book.dart';

class BooksService {
  final bookRef = FirebaseFirestore.instance.collection('books').withConverter(
      fromFirestore: (snapshot, _) =>
          Book.fromJson(snapshot.id, snapshot.data()!),
      toFirestore: (book, _) => book.toJson());

  Future<List<Book>> getLastBooks() async {
    var result = await bookRef.limit(3).get().then((value) => value);
    List<Book> books = [];
    for (var doc in result.docs) {
      books.add(doc.data());
    }
    return Future.value(books);
  }

  Future<Book> getBook(String bookId) async {
    var result = await bookRef.doc(bookId).get().then((value) => value);
    if (result.exists) {
      return Future.value(result.data());
    }
    throw Exception('Book not found');
  }

  Future<String> saveBook(String name, String autor, String summary) async {
    var reference = FirebaseFirestore.instance.collection("books");
    var result = await reference.add({
      'name': name,
      'author': autor,
      'summary': summary,
    });
    return Future.value(result.id);
  }

  Future<String> uploadBookCover(String imagePath, String newBookId) async {
    try {
      var newBookRef = 'books/$newBookId.jpg';
      File image = File(imagePath);
      var task = await FirebaseStorage.instance
          .ref(newBookRef)
          .putFile(image);

      var downloadUrl = await task.ref.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint(e.message);
      rethrow;
    }
  }

  Future<void> updateCoverBook(String newBookId, String imageUrl) async {
    var reference = FirebaseFirestore.instance.collection("books").doc(newBookId);
    return reference.update({
      'coverUrl': imageUrl,
    });
  }

  Future<void> deleteBook(String bookId) async {
    var reference = FirebaseFirestore.instance.collection("books").doc(bookId);
    try {
      // Eliminar datos del libro
      await reference.delete();
      // Eliminar la imagen de la portada del libro
      var coverRef = FirebaseStorage.instance.ref().child('books/$bookId.jpg');
      await coverRef.delete();
    } on FirebaseException catch (e) {
      debugPrint("Error deleting book: ${e.message}");
      rethrow;
    }
  }

  Future<void> updateBookDetail(String bookId, String name, String author, String summary) async {
    var reference = FirebaseFirestore.instance.collection("books").doc(bookId);
    try {
      await reference.update({
        'name': name,
        'author': author,
        'summary': summary,
      });
    } on FirebaseException catch (e) {
      debugPrint("Error updating book: ${e.message}");
      rethrow;
    }
  }
}
