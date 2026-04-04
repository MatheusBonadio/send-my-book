import 'dart:async';
import '../../models/book.dart';
import 'book_data_source.dart';

/// Adapter em memória — usado como fallback quando o usuário não está autenticado.
class LocalBookAdapter implements BookDataSource {
  final List<Book> _books = [];
  final _controller = StreamController<List<Book>>.broadcast();

  void _emit() => _controller.add(List.unmodifiable(_books));

  @override
  Stream<List<Book>> watchAll() {
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<bool> exists(String id) async =>
      _books.any((b) => b.id == id);

  @override
  Future<void> add(Book book) async {
    _books.add(book);
    _emit();
  }

  @override
  Future<void> update(Book book) async {
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) _books[index] = book;
    _emit();
  }

  @override
  Future<void> delete(String id) async {
    _books.removeWhere((b) => b.id == id);
    _emit();
  }

  @override
  String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}
