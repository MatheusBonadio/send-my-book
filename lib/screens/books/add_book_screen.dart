import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
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
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _genreController = TextEditingController();
  final _yearController = TextEditingController();
  ReadingStatus _status = ReadingStatus.unread;

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final book = Book(
      id: context.read<BookProvider>().generateId(),
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
    );

    context.read<BookProvider>().addBook(book);

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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
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
                  onPressed: _save,
                  child: const Text('Adicionar livro'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
