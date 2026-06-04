import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RecipeImage extends StatelessWidget {
  final String imagePath;
  final bool isFullSize;

  const RecipeImage({
    super.key,
    required this.imagePath,
    this.isFullSize = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!imagePath.startsWith('http')) {
      if (!imagePath.contains('data')) {
        return Image.asset(imagePath, fit: BoxFit.cover);
      }
      return Image.file(File(imagePath), fit: BoxFit.cover);
    }

    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      memCacheWidth: isFullSize ? null : 400,
      memCacheHeight: isFullSize ? null : 400,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainer,
        highlightColor: Theme.of(context).colorScheme.surfaceBright,
        child: Container(color: Theme.of(context).colorScheme.surfaceContainer),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
