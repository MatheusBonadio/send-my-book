import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppTheme.onPrimary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Send My Book',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            _Section(
              title: 'Objetivo',
              child: const Text(
                'O Send My Book é um aplicativo de gerenciamento de biblioteca pessoal. '
                'Organize seus livros, acompanhe seu progresso de leitura, '
                'crie uma lista de desejos e compartilhe sua paixão pela leitura.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Funcionalidades',
              child: Column(
                children: const [
                  _FeatureItem(
                      icon: Icons.library_books_outlined,
                      text: 'Gerenciamento da biblioteca pessoal'),
                  _FeatureItem(
                      icon: Icons.menu_book_rounded,
                      text: 'Controle de status de leitura'),
                  _FeatureItem(
                      icon: Icons.favorite_border_rounded,
                      text: 'Lista de desejos'),
                  _FeatureItem(
                      icon: Icons.edit_outlined,
                      text: 'Adição e edição de livros'),
                  _FeatureItem(
                      icon: Icons.lock_outlined,
                      text: 'Autenticação segura com Firebase'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Equipe de Desenvolvimento',
              child: Column(
                children: const [
                  _MemberItem(name: 'Integrante 1', role: 'Desenvolvedor'),
                  _MemberItem(name: 'Integrante 2', role: 'Desenvolvedor'),
                  _MemberItem(name: 'Integrante 3', role: 'Desenvolvedor'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Section(
              title: 'Informações Acadêmicas',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _InfoRow(label: 'Disciplina', value: 'Desenvolvimento Mobile'),
                  _InfoRow(label: 'Instituição', value: 'Nome da Instituição'),
                  _InfoRow(label: 'Professor', value: 'Nome do Professor'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.secondary),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
                fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _MemberItem extends StatelessWidget {
  final String name;
  final String role;

  const _MemberItem({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onBackground),
              ),
              Text(
                role,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.onBackground),
            ),
          ),
        ],
      ),
    );
  }
}
