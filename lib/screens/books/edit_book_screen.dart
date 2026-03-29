import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../../providers/book_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/status_selector.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;

  const EditBookScreen({super.key, required this.book});

  @override
  State<EditBookScreen> createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _genreController;
  late final TextEditingController _yearController;
  late ReadingStatus _status;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleController = TextEditingController(text: b.title);
    _authorController = TextEditingController(text: b.author);
    _descriptionController =
        TextEditingController(text: b.description ?? '');
    _genreController = TextEditingController(text: b.genre ?? '');
    _yearController =
        TextEditingController(text: b.publishYear?.toString() ?? '');
    _status = b.status;
  }

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

    final updated = widget.book.copyWith(
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
    );

    context.read<BookProvider>().updateBook(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Livro atualizado com sucesso!')),
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar livro'),
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
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Ano de publicação',
                  controller: _yearController,
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
                  child: const Text('Salvar alterações'),
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
