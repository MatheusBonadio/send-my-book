import '../../models/book.dart';

/// Interface (alvo) do Adapter de persistência de livros.
///
/// [BookProvider] depende desta abstração, permitindo trocar a
/// implementação concreta (local, Firestore, SQLite, etc.) sem
/// alterar a camada de estado.
abstract class BookDataSource {
  List<Book> getAll();
  void add(Book book);
  void update(Book book);
  void delete(String id);
  String generateId();
}
