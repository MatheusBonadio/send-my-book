enum ReadingStatus { unread, reading, read, wishlist }

extension ReadingStatusExtension on ReadingStatus {
  String get label {
    switch (this) {
      case ReadingStatus.unread:
        return 'Não lido';
      case ReadingStatus.reading:
        return 'Lendo';
      case ReadingStatus.read:
        return 'Lido';
      case ReadingStatus.wishlist:
        return 'Lista de desejos';
    }
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String? description;
  final String? genre;
  final int? publishYear;
  final ReadingStatus status;
  final DateTime addedAt;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.genre,
    this.publishYear,
    this.status = ReadingStatus.unread,
    required this.addedAt,
  });

  Book copyWith({
    String? title,
    String? author,
    String? description,
    String? genre,
    int? publishYear,
    ReadingStatus? status,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      publishYear: publishYear ?? this.publishYear,
      status: status ?? this.status,
      addedAt: addedAt,
    );
  }
}
