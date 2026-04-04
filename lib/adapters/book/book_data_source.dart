import '../../models/book.dart';

/// Interface (alvo) do Adapter de persistência de livros.
///
/// [BookProvider] depende desta abstração, permitindo trocar a
/// implementação concreta (local, Firestore, SQLite, etc.) sem
/// alterar a camada de estado.
abstract class BookDataSource {
  /// Emite a lista de livros e re-emite a cada alteração.
  Stream<List<Book>> watchAll();
  Future<bool> exists(String id);
  Future<void> add(Book book);
  Future<void> update(Book book);
  Future<void> delete(String id);
  String generateId();
}
