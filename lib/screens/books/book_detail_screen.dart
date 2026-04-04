import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/book_cover.dart';
import 'edit_book_screen.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  Color _statusColor(ReadingStatus status) {
    switch (status) {
      case ReadingStatus.reading:
        return AppTheme.statusReading;
      case ReadingStatus.read:
        return AppTheme.statusRead;
      case ReadingStatus.unread:
        return AppTheme.statusUnread;
      case ReadingStatus.wishlist:
        return AppTheme.statusWishlist;
    }
  }

  Future<void> _confirmDelete(BuildContext context, Book book) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remover livro'),
        content: Text(
            'Deseja remover "${book.title}" da sua biblioteca? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<BookProvider>().deleteBook(book.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Livro removido.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final book = context.watch<BookProvider>().getById(bookId);

    if (book == null) {
      return const Scaffold(
        body: Center(child: Text('Livro não encontrado.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditBookScreen(book: book)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Remover',
            onPressed: () => _confirmDelete(context, book),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: BookCoverWidget(
                book: book,
                width: 120,
                height: 160,
                animate: true,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              book.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppTheme.onBackground,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              book.author,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.circle,
                  label: book.status.label,
                  color: _statusColor(book.status),
                ),
                if (book.genre != null)
                  _InfoChip(
                    icon: Icons.style_outlined,
                    label: book.genre!,
                    color: AppTheme.secondary,
                  ),
                if (book.publishYear != null)
                  _InfoChip(
                    icon: Icons.calendar_today_outlined,
                    label: book.publishYear.toString(),
                    color: AppTheme.textSecondary,
                  ),
                if (book.isbn != null)
                  _InfoChip(
                    icon: Icons.qr_code_outlined,
                    label: 'ISBN ${book.isbn!}',
                    color: AppTheme.textSecondary,
                  ),
              ],
            ),
            if (book.description != null) ...[
              const SizedBox(height: 28),
              const Text(
                'Sobre o livro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onBackground,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                book.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
            const SizedBox(height: 28),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Atualizar status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.onBackground,
              ),
            ),
            const SizedBox(height: 12),
            _StatusButtons(book: book),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StatusButtons extends StatelessWidget {
  final Book book;

  const _StatusButtons({required this.book});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      (ReadingStatus.unread, 'Não lido', Icons.bookmark_border_rounded),
      (ReadingStatus.reading, 'Lendo', Icons.menu_book_rounded),
      (ReadingStatus.read, 'Lido', Icons.check_circle_outline_rounded),
      (ReadingStatus.wishlist, 'Desejos', Icons.favorite_border_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: statuses.map((s) {
        final isActive = book.status == s.$1;
        return FilterChip(
          avatar: Icon(s.$3,
              size: 16,
              color: isActive ? AppTheme.onPrimary : AppTheme.textSecondary),
          label: Text(s.$2),
          selected: isActive,
          selectedColor: AppTheme.primary,
          backgroundColor: AppTheme.background,
          checkmarkColor: Colors.transparent,
          showCheckmark: false,
          labelStyle: TextStyle(
            color: isActive ? AppTheme.onPrimary : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
              color: isActive ? AppTheme.primary : AppTheme.divider),
          onSelected: isActive
              ? null
              : (_) async {
                  await context
                      .read<BookProvider>()
                      .updateStatus(book.id, s.$1);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Status atualizado: ${s.$2}')),
                    );
                  }
                },
        );
      }).toList(),
    );
  }
}
