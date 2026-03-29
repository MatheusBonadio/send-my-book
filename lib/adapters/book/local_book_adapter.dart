import '../../models/book.dart';
import 'book_data_source.dart';

/// Adapter concreto que adapta uma lista em memória (adaptee)
/// para a interface [BookDataSource] (alvo) esperada pelo [BookProvider].
///
/// Para usar Firestore ou SQLite basta criar um novo adapter que
/// implemente [BookDataSource] e injetá-lo em [BookProvider].
class LocalBookAdapter implements BookDataSource {
  final List<Book> _books = _buildInitialBooks();

  @override
  List<Book> getAll() => List.unmodifiable(_books);

  @override
  void add(Book book) => _books.add(book);

  @override
  void update(Book book) {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) _books[index] = book;
  }

  @override
  void delete(String id) => _books.removeWhere((b) => b.id == id);

  @override
  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

List<Book> _buildInitialBooks() => [
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
            'Obra naturalista que retrata a vida coletiva em um cortiço carioca do '
            'século XIX, explorando questões sociais, raciais e humanas.',
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
            'A épica aventura de Frodo Bolseiro e seus companheiros na missão de '
            'destruir o Um Anel e derrotar o Senhor das Trevas Sauron.',
        genre: 'Fantasia',
        publishYear: 1954,
        status: ReadingStatus.wishlist,
        addedAt: DateTime(2024, 4, 2),
      ),
    ];
