import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_layout.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({
    super.key,
    required this.images,
    required this.thumbnail,
  });

  final List<String> images;
  final String thumbnail;

  @override
  State<ProductImageGallery> createState() =>
      _ProductImageGalleryState();
}

class _ProductImageGalleryState
    extends State<ProductImageGallery> {
  int _currentPage = 0;
  late final PageController _controller;

  List<String> get _allImages {
    if (widget.images.isNotEmpty) return widget.images;
    if (widget.thumbnail.isNotEmpty) {
      return [widget.thumbnail];
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imgs = _allImages;
    if (imgs.isEmpty) {
      return SizedBox(
        height: AppLayout.height200,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: AppLayout.iconSizeXl,
            color: AppColors.grayLight,
          ),
        ),
      );
    }
    return Column(
      children: [
        SizedBox(
          height: AppLayout.height200,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) =>
                setState(() => _currentPage = i),
            itemCount: imgs.length,
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: imgs[i],
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.broken_image_outlined,
                size: AppLayout.iconSizeXl,
                color: AppColors.grayLight,
              ),
            ),
          ),
        ),
        if (imgs.length > 1)
          Padding(
            padding: EdgeInsets.only(
                top: AppPaddings.verticalBase),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                imgs.length,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.symmetric(
                      horizontal: AppPaddings.smallest / 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage
                        ? AppColors.primary
                        : AppColors.grayVeryLight,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
