import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenLibraryResult {
  final String title;
  final String author;
  final String? description;
  final String? genre;
  final int? publishYear;
  final String? coverUrl;
  final String? isbn;

  const OpenLibraryResult({
    required this.title,
    required this.author,
    this.description,
    this.genre,
    this.publishYear,
    this.coverUrl,
    this.isbn,
  });
}

/// Busca livros via Open Library API (sem chave, sem cota).
/// Docs: https://openlibrary.org/dev/docs/api
class OpenLibraryService {
  static const _searchUrl = 'https://openlibrary.org/search.json';
  static const _coverUrl = 'https://covers.openlibrary.org/b/id';

  static Future<List<OpenLibraryResult>> search(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$_searchUrl?q=${Uri.encodeQueryComponent(query)}&limit=10&fields=title,author_name,first_publish_year,cover_i,isbn',
    );

    try {
      final response =
          await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final docs = data['docs'] as List<dynamic>?;
      if (docs == null) return [];

      return docs.map((doc) {
        final map = doc as Map<String, dynamic>;
        final authors =
            (map['author_name'] as List<dynamic>?)?.cast<String>() ?? [];
        final coverId = map['cover_i'];
        final year = map['first_publish_year'] as int?;
        final isbns =
            (map['isbn'] as List<dynamic>?)?.cast<String>() ?? [];

        String? cover;
        if (coverId != null) {
          cover = '$_coverUrl/$coverId-M.jpg';
        }

        // Prefere ISBN-13 (13 dígitos), caso contrário usa o primeiro disponível
        final isbn = isbns.firstWhere(
          (i) => i.length == 13,
          orElse: () => isbns.isNotEmpty ? isbns.first : '',
        );

        return OpenLibraryResult(
          title: map['title'] as String? ?? '',
          author: authors.take(2).join(', '),
          publishYear: year,
          coverUrl: cover,
          isbn: isbn.isNotEmpty ? isbn : null,
        );
      }).where((b) => b.title.isNotEmpty).toList();
    } catch (_) {
      return [];
    }
  }
}
