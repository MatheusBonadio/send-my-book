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
  final String? coverUrl;
  final String? isbn;
  final int? spineColor;

  /// Indica se o livro está na biblioteca pessoal do usuário.
  /// Campo runtime — não é persistido no Firestore.
  final bool inLibrary;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.genre,
    this.publishYear,
    this.status = ReadingStatus.unread,
    required this.addedAt,
    this.coverUrl,
    this.isbn,
    this.spineColor,
    this.inLibrary = true,
  });

  Book copyWith({
    String? title,
    String? author,
    String? description,
    String? genre,
    int? publishYear,
    ReadingStatus? status,
    String? coverUrl,
    String? isbn,
    int? spineColor,
    bool? inLibrary,
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
      coverUrl: coverUrl ?? this.coverUrl,
      isbn: isbn ?? this.isbn,
      spineColor: spineColor ?? this.spineColor,
      inLibrary: inLibrary ?? this.inLibrary,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'author': author,
        if (description != null) 'description': description,
        if (genre != null) 'genre': genre,
        if (publishYear != null) 'publishYear': publishYear,
        'status': status.name,
        'addedAt': addedAt.toIso8601String(),
        if (coverUrl != null) 'coverUrl': coverUrl,
        if (isbn != null) 'isbn': isbn,
        if (spineColor != null) 'spineColor': spineColor,
      };

  factory Book.fromMap(String id, Map<String, dynamic> map) => Book(
        id: id,
        title: map['title'] as String? ?? '',
        author: map['author'] as String? ?? '',
        description: map['description'] as String?,
        genre: map['genre'] as String?,
        publishYear: map['publishYear'] as int?,
        status: ReadingStatus.values.firstWhere(
          (s) => s.name == map['status'],
          orElse: () => ReadingStatus.unread,
        ),
        addedAt: DateTime.tryParse(map['addedAt'] as String? ?? '') ??
            DateTime.now(),
        coverUrl: map['coverUrl'] as String?,
        isbn: map['isbn'] as String?,
        spineColor: map['spineColor'] as int?,
        inLibrary: map['inLibrary'] as bool? ?? true,
      );
}
