import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Compresses images before multimodal AI upload to reduce latency and tokens.
abstract final class ImageCompressor {
  static const defaultMaxEdge = 1024;
  static const defaultQuality = 82;

  static Future<CompressedImage> fromFile(
    File file, {
    int maxEdge = defaultMaxEdge,
    int quality = defaultQuality,
  }) async {
    final bytes = await file.readAsBytes();
    return fromBytes(
      bytes,
      mimeType: _mimeFromPath(file.path),
      maxEdge: maxEdge,
      quality: quality,
    );
  }

  static Future<CompressedImage> fromBytes(
    Uint8List bytes, {
    required String mimeType,
    int maxEdge = defaultMaxEdge,
    int quality = defaultQuality,
  }) async {
    return compute(
      _compressIsolate,
      _CompressArgs(
        bytes: bytes,
        mimeType: mimeType,
        maxEdge: maxEdge,
        quality: quality,
      ),
    );
  }

  static CompressedImage _compressIsolate(_CompressArgs args) {
    final decoded = img.decodeImage(args.bytes);
    if (decoded == null) {
      return CompressedImage(
        bytes: args.bytes,
        mimeType: args.mimeType,
        width: 0,
        height: 0,
        wasCompressed: false,
      );
    }

    final resized = img.copyResize(
      decoded,
      width: decoded.width > decoded.height ? args.maxEdge : null,
      height: decoded.height >= decoded.width ? args.maxEdge : null,
      interpolation: img.Interpolation.linear,
    );

    final jpeg = img.encodeJpg(resized, quality: args.quality);
    return CompressedImage(
      bytes: Uint8List.fromList(jpeg),
      mimeType: 'image/jpeg',
      width: resized.width,
      height: resized.height,
      wasCompressed: true,
    );
  }

  static String _mimeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

class CompressedImage {
  const CompressedImage({
    required this.bytes,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.wasCompressed,
  });

  final Uint8List bytes;
  final String mimeType;
  final int width;
  final int height;
  final bool wasCompressed;
}

class _CompressArgs {
  const _CompressArgs({
    required this.bytes,
    required this.mimeType,
    required this.maxEdge,
    required this.quality,
  });

  final Uint8List bytes;
  final String mimeType;
  final int maxEdge;
  final int quality;
}
