import 'package:flutter/foundation.dart';
import '../adapters/book/book_data_source.dart';
import '../models/book.dart';

/// Gerencia o estado da biblioteca de livros.
///
/// Depende de [BookDataSource] (não de nenhuma implementação concreta),
/// seguindo o padrão Adapter para desacoplar persistência do estado.
class BookProvider extends ChangeNotifier {
  final BookDataSource _dataSource;

  BookProvider(this._dataSource);

  List<Book> get books => _dataSource.getAll();

  List<Book> get library =>
      books.where((b) => b.status != ReadingStatus.wishlist).toList();

  List<Book> get wishlist =>
      books.where((b) => b.status == ReadingStatus.wishlist).toList();

  Book? getById(String id) {
    try {
      return books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void addBook(Book book) {
    _dataSource.add(book);
    notifyListeners();
  }

  void updateBook(Book updated) {
    _dataSource.update(updated);
    notifyListeners();
  }

  void deleteBook(String id) {
    _dataSource.delete(id);
    notifyListeners();
  }

  void updateStatus(String id, ReadingStatus status) {
    final book = getById(id);
    if (book != null) {
      _dataSource.update(book.copyWith(status: status));
      notifyListeners();
    }
  }

  String generateId() => _dataSource.generateId();
}
