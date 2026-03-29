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
      return Image.asset(imagePath, fit: BoxFit.cover);
    }

    return CachedNetworkImage(
      imageUrl: imagePath,
      fit: BoxFit.cover,
      memCacheWidth: isFullSize ? null : 400,
      memCacheHeight: isFullSize ? null : 400,
      fadeInDuration: const Duration(milliseconds: 300),
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[200],
        child: Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }
}
