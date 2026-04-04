import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/book.dart';
import 'book_data_source.dart';

/// Adapter Firestore com separação entre catálogo e métricas pessoais:
///
/// `books/{id}` — catálogo compartilhado (todos os livros da plataforma).
///   Contém: título, autor, capa, isbn, etc.
///
/// `users/{uid}/library/{id}` — métricas pessoais do usuário.
///   Contém apenas: { status, addedAt }.
///
/// `watchAll()` combina as duas coleções em tempo real:
///   - Todos os livros de `books` são emitidos (inLibrary = false por padrão).
///   - Livros presentes em `library` recebem status/addedAt do usuário
///     e inLibrary = true.
class FirestoreBookAdapter implements BookDataSource {
  final FirebaseFirestore _firestore;
  final String _uid;

  FirestoreBookAdapter(this._uid, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _catalog =>
      _firestore.collection('books');

  CollectionReference<Map<String, dynamic>> get _library =>
      _firestore.collection('users').doc(_uid).collection('library');

  @override
  Stream<List<Book>> watchAll() {
    final controller = StreamController<List<Book>>();

    QuerySnapshot<Map<String, dynamic>>? latestCatalog;
    QuerySnapshot<Map<String, dynamic>>? latestLibrary;

    void combine() {
      if (latestCatalog == null) return;

      final metrics = latestLibrary != null
          ? {for (final d in latestLibrary!.docs) d.id: d.data()}
          : <String, Map<String, dynamic>>{};

      final books = latestCatalog!.docs.map((d) {
        final m = metrics[d.id];
        return Book.fromMap(d.id, {
          ...d.data(),
          if (m != null) ...m,
          'inLibrary': m != null,
        });
      }).toList();

      if (!controller.isClosed) controller.add(books);
    }

    StreamSubscription? catalogSub, librarySub;

    controller.onListen = () {
      catalogSub = _catalog.snapshots().listen((snap) {
        latestCatalog = snap;
        combine();
      });
      librarySub = _library.snapshots().listen((snap) {
        latestLibrary = snap;
        combine();
      });
    };

    controller.onCancel = () {
      catalogSub?.cancel();
      librarySub?.cancel();
    };

    return controller.stream;
  }

  @override
  Future<bool> exists(String id) async {
    final doc = await _library.doc(id).get();
    return doc.exists;
  }

  @override
  Future<void> add(Book book) async {
    final batch = _firestore.batch();

    // Catálogo compartilhado — dados do livro sem métricas
    batch.set(_catalog.doc(book.id), _catalogData(book), SetOptions(merge: true));

    // Biblioteca pessoal — somente métricas
    batch.set(_library.doc(book.id), _metricsData(book));

    await batch.commit();
  }

  @override
  Future<void> update(Book book) async {
    final batch = _firestore.batch();
    // set+merge evita erro caso o documento não exista no catálogo
    batch.set(_catalog.doc(book.id), _catalogData(book), SetOptions(merge: true));
    batch.set(_library.doc(book.id), _metricsData(book), SetOptions(merge: true));
    await batch.commit();
  }

  /// Atualiza apenas as métricas pessoais — não toca no catálogo compartilhado.
  Future<void> updateMetrics(String id, Map<String, dynamic> metrics) =>
      _library.doc(id).update(metrics);

  @override
  Future<void> delete(String id) => _library.doc(id).delete();

  @override
  String generateId() => _catalog.doc().id;

  Map<String, dynamic> _catalogData(Book book) => {
        'title': book.title,
        'author': book.author,
        if (book.description != null) 'description': book.description,
        if (book.genre != null) 'genre': book.genre,
        if (book.publishYear != null) 'publishYear': book.publishYear,
        if (book.coverUrl != null) 'coverUrl': book.coverUrl,
        if (book.isbn != null) 'isbn': book.isbn,
        if (book.spineColor != null) 'spineColor': book.spineColor,
      };

  Map<String, dynamic> _metricsData(Book book) => {
        'status': book.status.name,
        'addedAt': book.addedAt.toIso8601String(),
      };
}
