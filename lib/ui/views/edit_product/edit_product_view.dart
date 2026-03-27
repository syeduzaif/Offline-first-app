import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/product_editor/product_editor_view.dart';

class EditProductView extends StatelessWidget {
  const EditProductView({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ProductEditorView(
      title: ProductStrings.editProduct,
      successMessage: ProductStrings.saveSuccess,
      initialProduct: product,
    );
  }
}
