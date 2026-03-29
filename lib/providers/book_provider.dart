import 'package:flutter/foundation.dart';
import '../models/book.dart';

class BookProvider extends ChangeNotifier {
  final List<Book> _books = [
    Book(
      id: '1',
      title: 'Dom Casmurro',
      author: 'Machado de Assis',
      description:
          'Um dos maiores clássicos da literatura brasileira, narrado por Bentinho '
          'que, já velho, relembra seu amor por Capitu e a tragédia que os separou.',
      genre: 'Romance',
      publishYear: 1899,
      status: ReadingStatus.read,
      addedAt: DateTime(2024, 1, 10),
    ),
    Book(
      id: '2',
      title: 'O Cortiço',
      author: 'Aluísio Azevedo',
      description:
          'Obra naturalista que retrata a vida coletiva em um cortiço carioca do século XIX, '
          'explorando questões sociais, raciais e humanas.',
      genre: 'Naturalismo',
      publishYear: 1890,
      status: ReadingStatus.reading,
      addedAt: DateTime(2024, 2, 5),
    ),
    Book(
      id: '3',
      title: 'Grande Sertão: Veredas',
      author: 'João Guimarães Rosa',
      description:
          'Considerado o maior romance da literatura brasileira, narra as aventuras '
          'de Riobaldo, um ex-jagunço que reflete sobre sua vida no sertão.',
      genre: 'Romance',
      publishYear: 1956,
      status: ReadingStatus.unread,
      addedAt: DateTime(2024, 3, 1),
    ),
    Book(
      id: '4',
      title: '1984',
      author: 'George Orwell',
      description:
          'Distopia clássica que retrata um futuro totalitário onde o governo controla '
          'todos os aspectos da vida dos cidadãos.',
      genre: 'Ficção Científica',
      publishYear: 1949,
      status: ReadingStatus.wishlist,
      addedAt: DateTime(2024, 3, 15),
    ),
    Book(
      id: '5',
      title: 'O Senhor dos Anéis',
      author: 'J.R.R. Tolkien',
      description:
          'A épica aventura de Frodo Bolseiro e seus companheiros na missão de destruir '
          'o Um Anel e derrotar o Senhor das Trevas Sauron.',
      genre: 'Fantasia',
      publishYear: 1954,
      status: ReadingStatus.wishlist,
      addedAt: DateTime(2024, 4, 2),
    ),
  ];

  List<Book> get books => List.unmodifiable(_books);

  List<Book> get library =>
      _books.where((b) => b.status != ReadingStatus.wishlist).toList();

  List<Book> get wishlist =>
      _books.where((b) => b.status == ReadingStatus.wishlist).toList();

  Book? getById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void addBook(Book book) {
    _books.add(book);
    notifyListeners();
  }

  void updateBook(Book updated) {
    final index = _books.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      _books[index] = updated;
      notifyListeners();
    }
  }

  void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void updateStatus(String id, ReadingStatus status) {
    final index = _books.indexWhere((b) => b.id == id);
    if (index != -1) {
      _books[index] = _books[index].copyWith(status: status);
      notifyListeners();
    }
  }

  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
