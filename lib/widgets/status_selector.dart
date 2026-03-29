import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

class StatusSelector extends StatelessWidget {
  final ReadingStatus selected;
  final ValueChanged<ReadingStatus> onChanged;

  const StatusSelector(
      {super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ReadingStatus.unread, 'Não lido', Icons.bookmark_border_rounded),
      (ReadingStatus.reading, 'Lendo', Icons.menu_book_rounded),
      (ReadingStatus.read, 'Lido', Icons.check_circle_outline_rounded),
      (ReadingStatus.wishlist, 'Lista de desejos',
          Icons.favorite_border_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((o) {
        final isSelected = selected == o.$1;
        return ChoiceChip(
          avatar: Icon(o.$3,
              size: 16,
              color: isSelected ? AppTheme.primary : AppTheme.textSecondary),
          label: Text(o.$2),
          selected: isSelected,
          onSelected: (_) => onChanged(o.$1),
          selectedColor: AppTheme.primary.withValues(alpha: 0.12),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
