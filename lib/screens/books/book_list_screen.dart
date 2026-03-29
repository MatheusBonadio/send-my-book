import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/book_card.dart';
import 'add_book_screen.dart';
import 'book_detail_screen.dart';

class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  ReadingStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final library = bookProvider.library;

    final filtered = _selectedFilter == null
        ? library
        : library
            .where((b) => b.status == _selectedFilter)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Biblioteca'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${library.length} livro${library.length != 1 ? 's' : ''}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            selected: _selectedFilter,
            onSelected: (status) =>
                setState(() => _selectedFilter = status),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(hasFilter: _selectedFilter != null)
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final book = filtered[index];
                      return BookCard(
                        book: book,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookDetailScreen(bookId: book.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBookScreen()),
        ),
        tooltip: 'Adicionar livro',
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final ReadingStatus? selected;
  final ValueChanged<ReadingStatus?> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final filters = [
      (null, 'Todos'),
      (ReadingStatus.reading, 'Lendo'),
      (ReadingStatus.read, 'Lidos'),
      (ReadingStatus.unread, 'Não lidos'),
    ];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: filters.map((f) {
          final isSelected = selected == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f.$2),
              selected: isSelected,
              onSelected: (_) => onSelected(isSelected ? null : f.$1),
              selectedColor: AppTheme.primary.withValues(alpha: 0.12),
              checkmarkColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;

  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilter
                ? Icons.filter_list_off_rounded
                : Icons.library_books_outlined,
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter
                ? 'Nenhum livro nesta categoria'
                : 'Sua biblioteca está vazia',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Tente outro filtro'
                : 'Adicione seu primeiro livro!',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
