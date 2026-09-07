import 'package:cached_network_image/cached_network_image.dart';
import 'package:jippymart_restaurant/constant/constant.dart';
import 'package:jippymart_restaurant/themes/responsive.dart';
import 'package:flutter/material.dart';
import 'package:jippymart_restaurant/utils/app_image_cache_manager.dart';

class NetworkImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Widget? errorWidget;
  final BoxFit? fit;
  final double? borderRadius;
  final Color? color;

  const NetworkImageWidget({
    super.key,
    this.height,
    this.width,
    this.fit,
    required this.imageUrl,
    this.borderRadius,
    this.errorWidget,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the imageUrl is invalid (empty or the string "null")
    if (imageUrl.isEmpty || imageUrl == "null") {
      return errorWidget ??
          Container(
            height: height ?? Responsive.height(8, context),
            width: width ?? Responsive.width(15, context),
            color: Colors.grey[300],
            child: Icon(Icons.error_outline, color: Colors.grey),
          );
    }

    final effectiveHeight = height ?? Responsive.height(8, context);
    final effectiveWidth = width ?? Responsive.width(15, context);

    // Decode the network image at roughly its rendered size instead of the
    // full server resolution. This cuts memory usage and scroll jank with no
    // visible change — the image is downscaled for a screen that is often
    // 5-10x smaller than the original.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final memCacheWidth = (effectiveWidth * dpr).round();
    final memCacheHeight = (effectiveHeight * dpr).round();

    return CachedNetworkImage(
      imageUrl: imageUrl,
      cacheManager: AppImageCacheManager.instance,
      fit: fit ?? BoxFit.fitWidth,
      height: effectiveHeight,
      width: effectiveWidth,
      color: color,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: memCacheWidth,
      maxHeightDiskCache: memCacheHeight,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          Constant.loader(),
      errorWidget: (context, url, error) =>
      errorWidget ??
          Container(
            height: effectiveHeight,
            width: effectiveWidth,
            color: Colors.grey[300],
            child: Icon(Icons.error_outline, color: Colors.grey),
          ),
    );
  }
}