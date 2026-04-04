import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/painting.dart';

/// Extrai a cor dominante de uma imagem de capa via URL.
/// Retorna o valor ARGB como int (compatível com [Color.fromARGB]).
/// Retorna null se a imagem não puder ser carregada.
class CoverColorService {
  static Future<int?> extract(String url) async {
    try {
      final completer = Completer<ui.Image>();
      final stream = NetworkImage(url).resolve(
        const ImageConfiguration(size: Size(50, 70), devicePixelRatio: 1.0),
      );

      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!completer.isCompleted) completer.complete(info.image);
          stream.removeListener(listener);
        },
        onError: (_, __) {
          if (!completer.isCompleted) completer.completeError('error');
          stream.removeListener(listener);
        },
      );
      stream.addListener(listener);

      final image = await completer.future
          .timeout(const Duration(seconds: 10));
      final byteData = await image.toByteData();
      if (byteData == null) return null;

      return _dominant(byteData, image.width, image.height);
    } catch (_) {
      return null;
    }
  }

  static int _dominant(ByteData bytes, int w, int h) {
    const step = 4;
    final buckets = <int, int>{};

    for (var y = 0; y < h; y += step) {
      for (var x = 0; x < w; x += step) {
        final offset = (y * w + x) * 4;
        final r = bytes.getUint8(offset);
        final g = bytes.getUint8(offset + 1);
        final b = bytes.getUint8(offset + 2);

        final brightness = (r * 299 + g * 587 + b * 114) ~/ 1000;
        if (brightness > 220 || brightness < 30) continue;

        final key = ((r >> 4) << 16) | ((g >> 4) << 8) | (b >> 4);
        buckets[key] = (buckets[key] ?? 0) + 1;
      }
    }

    if (buckets.isEmpty) return 0xFF343D37; // AppTheme.primary

    final dominant = buckets.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    final r = ((dominant >> 16) & 0xF) << 4;
    final g = ((dominant >> 8) & 0xF) << 4;
    final b = (dominant & 0xF) << 4;

    // Escurece ligeiramente para a espinha ter mais profundidade
    return 0xFF000000 |
        ((r * 0.7).round() << 16) |
        ((g * 0.7).round() << 8) |
        (b * 0.7).round();
  }
}
