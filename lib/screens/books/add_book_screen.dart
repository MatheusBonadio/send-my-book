import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../services/cover_color_service.dart';
import '../../services/open_library_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_selector.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();
  final _isbnController = TextEditingController();
  ReadingStatus _status = ReadingStatus.unread;

  List<OpenLibraryResult> _searchResults = [];
  bool _isSearching = false;
  bool _isSaving = false;
  String? _coverUrl;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _isbnController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final results = await OpenLibraryService.search(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  void _fillFrom(OpenLibraryResult result) {
    _titleController.text = result.title;
    _authorController.text = result.author;
    _descriptionController.text = result.description ?? '';
    _genreController.text = result.genre ?? '';
    _yearController.text = result.publishYear?.toString() ?? '';
    _isbnController.text = result.isbn ?? '';
    setState(() {
      _coverUrl = result.coverUrl;
      _searchResults = [];
      _isSearching = false;
    });
    _searchController.clear();
    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final spineColor = _coverUrl != null
        ? await CoverColorService.extract(_coverUrl!)
        : null;

    if (!mounted) return;

    final isbnValue = _isbnController.text.trim();
    final bookId = isbnValue.isNotEmpty
        ? isbnValue
        : context.read<BookProvider>().generateId();

    if (isbnValue.isNotEmpty) {
      final alreadyExists =
          await context.read<BookProvider>().bookExists(bookId);
      if (!mounted) return;
      if (alreadyExists) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este livro já está catalogado na sua biblioteca.'),
          ),
        );
        return;
      }
    }

    final book = Book(
      id: bookId,
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      genre: _genreController.text.trim().isEmpty
          ? null
          : _genreController.text.trim(),
      publishYear: _yearController.text.trim().isEmpty
          ? null
          : int.tryParse(_yearController.text.trim()),
      status: _status,
      addedAt: DateTime.now(),
      coverUrl: _coverUrl,
      isbn: _isbnController.text.trim().isEmpty
          ? null
          : _isbnController.text.trim(),
      spineColor: spineColor,
    );

    await context.read<BookProvider>().addBook(book);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro adicionado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar livro'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _SearchSection(
                controller: _searchController,
                isSearching: _isSearching,
                results: _searchResults,
                coverUrl: _coverUrl,
                onChanged: _onSearchChanged,
                onResultTap: _fillFrom,
                onClear: _clearSearch,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      label: 'Título *',
                      controller: _titleController,
                      hint: 'Título do livro',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o título do livro';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Autor *',
                      controller: _authorController,
                      hint: 'Nome do autor',
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o autor do livro';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Gênero',
                      controller: _genreController,
                      hint: 'Ex: Romance, Ficção Científica...',
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Ano de publicação',
                      controller: _yearController,
                      hint: 'Ex: 1984',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final year = int.tryParse(value);
                          if (year == null ||
                              year < 1000 ||
                              year > DateTime.now().year) {
                            return 'Ano inválido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'ISBN',
                      controller: _isbnController,
                      hint: 'Ex: 9788550800653',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                      validator: (value) {
                        if (value != null && value.isNotEmpty &&
                            value.length != 10 && value.length != 13) {
                          return 'ISBN deve ter 10 ou 13 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Descrição',
                      controller: _descriptionController,
                      hint: 'Sinopse ou anotações sobre o livro...',
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Status de leitura',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 12),
                    StatusSelector(
                      selected: _status,
                      onChanged: (s) => setState(() => _status = s),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Adicionar livro'),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final bool isSearching;
  final List<OpenLibraryResult> results;
  final String? coverUrl;
  final ValueChanged<String> onChanged;
  final ValueChanged<OpenLibraryResult> onResultTap;
  final VoidCallback onClear;

  const _SearchSection({
    required this.controller,
    required this.isSearching,
    required this.results,
    required this.coverUrl,
    required this.onChanged,
    required this.onResultTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Buscar no Open Library...',
            prefixIcon: isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: onClear,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
            ),
            filled: true,
            fillColor: AppTheme.surface,
          ),
        ),
        if (coverUrl != null && results.isEmpty && !isSearching) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  coverUrl!,
                  width: 40,
                  height: 54,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Capa importada do Open Library',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
        if (results.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: results.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, i) {
                final r = results[i];
                return ListTile(
                  onTap: () => onResultTap(r),
                  leading: _ResultCover(coverUrl: r.coverUrl, title: r.title),
                  title: Text(
                    r.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    r.author.isNotEmpty ? r.author : 'Autor desconhecido',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: r.publishYear != null
                      ? Text(
                          r.publishYear.toString(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ResultCover extends StatelessWidget {
  final String? coverUrl;
  final String title;

  const _ResultCover({this.coverUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    if (coverUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          coverUrl!,
          width: 36,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 36,
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Text(
          title.isNotEmpty ? title[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
