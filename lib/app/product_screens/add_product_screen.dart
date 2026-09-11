import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jippymart_restaurant/app/product_screens/add_from_catalog_screen.dart';
import 'package:jippymart_restaurant/app/product_screens/edit_product_screen.dart';
import 'package:jippymart_restaurant/models/product_model.dart';

class AddProductScreen extends StatelessWidget {
  final ProductModel? product;
  final int? productId;

  const AddProductScreen({super.key, this.product, this.productId});

  @override
  Widget build(BuildContext context) {
    int? resolvedProductId = productId ?? int.tryParse(product?.id ?? '');

    if (resolvedProductId == null || resolvedProductId <= 0) {
      final args = ModalRoute.of(context)?.settings.arguments ?? Get.arguments;
      if (args != null) {
        if (args is int) {
          resolvedProductId = args;
        } else if (args is Map) {
          final pId = args['productId'] ?? args['id'];
          if (pId != null) {
            resolvedProductId = int.tryParse(pId.toString());
          } else {
            final p = args['productModel'] ?? args['product'];
            if (p is ProductModel) {
              resolvedProductId = int.tryParse(p.id ?? '');
            }
          }
        }
      }
    }

    if (resolvedProductId != null && resolvedProductId > 0) {
      return EditProductScreen(productId: resolvedProductId);
    }

    return const AddFromCatalogScreen();
  }
}