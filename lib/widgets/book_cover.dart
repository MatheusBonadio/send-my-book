import 'package:flutter/material.dart';
import '../models/book.dart';
import '../theme/app_theme.dart';

/// Capa de livro realista com espinha, cantos retos e páginas visíveis.
/// A cor da espinha vem de [book.spineColor], calculada uma única vez no cadastro.
/// Quando [animate] é true, executa o efeito de abertura ao ser exibido.
class BookCoverWidget extends StatefulWidget {
  final Book book;
  final double width;
  final double height;
  final bool animate;

  const BookCoverWidget({
    super.key,
    required this.book,
    required this.width,
    required this.height,
    this.animate = false,
  });

  @override
  State<BookCoverWidget> createState() => _BookCoverWidgetState();
}

class _BookCoverWidgetState extends State<BookCoverWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _open;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _open = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    if (widget.animate) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        _controller.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 250), () {
            if (mounted) _controller.reverse();
          });
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spineW = (widget.width * 0.13).clamp(5.0, 14.0);
    final coverW = widget.width - spineW;
    final spineColor = widget.book.spineColor != null
        ? Color(widget.book.spineColor!)
        : AppTheme.primary;

    return AnimatedBuilder(
      animation: _open,
      builder: (_, __) {
        final angle = _open.value * 0.40;

        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Páginas reveladas atrás da capa
              Positioned(
                left: spineW,
                top: 0,
                width: coverW,
                height: widget.height,
                child: _Pages(fraction: _open.value),
              ),

              // Sombra projetada ao abrir
              if (_open.value > 0)
                Positioned(
                  left: spineW + coverW * 0.7,
                  top: widget.height * 0.05,
                  width: coverW * 0.3,
                  height: widget.height * 0.9,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.18 * _open.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // Capa com rotação 3D pivotando na espinha
              Transform(
                alignment: Alignment.centerLeft,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateY(angle),
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.30),
                        blurRadius: 6,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Spine(width: spineW, color: spineColor),
                      Expanded(child: _CoverFace(book: widget.book)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Espinha ────────────────────────────────────────────────────────────────

class _Spine extends StatelessWidget {
  final double width;
  final Color color;

  const _Spine({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: color,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 0.8,
          margin: EdgeInsets.symmetric(vertical: width),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.20),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Face da capa ───────────────────────────────────────────────────────────

class _CoverFace extends StatelessWidget {
  final Book book;

  const _CoverFace({required this.book});

  @override
  Widget build(BuildContext context) {
    final Widget image = book.coverUrl != null
        ? Image.network(
            book.coverUrl!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => _placeholder(),
          )
        : _placeholder();

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        // Reflexo de luz na borda esquerda (junto à espinha)
        Positioned(
          top: 0,
          left: 0,
          bottom: 0,
          width: 4,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Escurecimento gradual para a direita
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.10),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.primary.withValues(alpha: 0.10),
      child: Center(
        child: Text(
          book.title.isNotEmpty ? book.title[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

// ─── Páginas do livro ───────────────────────────────────────────────────────

class _Pages extends StatelessWidget {
  final double fraction;

  const _Pages({required this.fraction});

  @override
  Widget build(BuildContext context) {
    const pageColors = [
      Color(0xFFF7F2E8),
      Color(0xFFF2EDE0),
      Color(0xFFEDE6D6),
      Color(0xFFE8E0CC),
      Color(0xFFE2D9C2),
    ];

    return Stack(
      children: [
        for (var i = pageColors.length - 1; i >= 0; i--)
          Positioned(
            left: (i * 1.2 * fraction).toDouble(),
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: pageColors[i],
                border: Border(
                  right: BorderSide(
                    color: Colors.black.withValues(alpha: 0.07),
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
