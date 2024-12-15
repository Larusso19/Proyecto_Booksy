class Book {
  final String id;
  final String name;
  final String author;
  final String summary;
  final String coverUrl;

  Book({
    required this.id,
    required this.name,
    required this.author,
    required this.summary,
    required this.coverUrl,
  });

  // Método toJson y fromJson para Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'author': author,
      'summary': summary,
      'coverUrl': coverUrl,
    };
  }

  factory Book.fromJson(String id, Map<String, dynamic> json) {
    return Book(
      id: id,
      name: json['name'] ?? '',
      author: json['author'] ?? '',
      summary: json['summary'] ?? '',
      coverUrl: json['coverUrl'] ?? '',
    );
  }

  copyWith({required String name, required String author, required String summary}) {
    // Método copyWith
    Book copyWith({
      String? name,
      String? author,
      String? summary,
      String? coverUrl,
    }) {
      return Book(
        id: id, // El ID no cambia
        name: name ?? this.name,
        author: author ?? this.author,
        summary: summary ?? this.summary,
        coverUrl: coverUrl ?? this.coverUrl,
      );
    }

  }
}

