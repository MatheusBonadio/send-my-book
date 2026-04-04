import 'dart:async';
import 'package:flutter/foundation.dart';
import '../adapters/book/book_data_source.dart';
import '../models/book.dart';

/// Gerencia o estado da biblioteca de livros.
///
/// Depende de [BookDataSource] via Adapter pattern. O data source pode ser
/// trocado em tempo de execução (ex: ao autenticar) via [switchDataSource].
class BookProvider extends ChangeNotifier {
  BookDataSource _dataSource;
  StreamSubscription<List<Book>>? _subscription;

  List<Book> _books = [];
  bool _isLoading = true;
  String? _currentUid;

  BookProvider(this._dataSource) {
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    _books = [];
    _isLoading = true;
    notifyListeners();
    _subscription = _dataSource.watchAll().listen((books) {
      _books = books;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Troca o data source quando o usuário faz login/logout.
  /// O [uid] é usado como chave — só recria a assinatura se o uid mudou.
  void switchDataSource(String? uid, BookDataSource newSource) {
    if (uid == _currentUid) return;
    _currentUid = uid;
    _dataSource = newSource;
    _subscribe();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Todos os livros do catálogo (books), com ou sem vínculo na library.
  List<Book> get books => _books;
  bool get isLoading => _isLoading;

  /// Livros que o usuário adicionou à biblioteca pessoal (exceto wishlist).
  List<Book> get library => _books
      .where((b) => b.inLibrary && b.status != ReadingStatus.wishlist)
      .toList();

  /// Livros na lista de desejos do usuário.
  List<Book> get wishlist =>
      _books.where((b) => b.inLibrary && b.status == ReadingStatus.wishlist).toList();

  Book? getById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> bookExists(String id) => _dataSource.exists(id);

  Future<void> addBook(Book book) => _dataSource.add(book);

  Future<void> updateBook(Book updated) => _dataSource.update(updated);

  Future<void> deleteBook(String id) => _dataSource.delete(id);

  Future<void> updateStatus(String id, ReadingStatus status) {
    final book = getById(id);
    if (book != null) return _dataSource.update(book.copyWith(status: status));
    return Future.value();
  }

  String generateId() => _dataSource.generateId();
}
