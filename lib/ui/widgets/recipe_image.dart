import 'package:cookbook_app/core/utils/util_functions.dart';
import 'package:flutter/material.dart';

class RecipeImage extends StatelessWidget {
  final String imagePath;
  final double cacheSize = 300;
  final bool isFullSize;

  const RecipeImage({
    super.key,
    required this.imagePath,
    this.isFullSize = false,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider provider = getImageProvider(imagePath);

    if (!isFullSize) {
      provider = ResizeImage(provider, width: cacheSize.toInt());
    }

    return Image(
      image: provider,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        color: Colors.grey[200],
        child: const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
