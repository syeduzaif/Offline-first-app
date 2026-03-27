import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/product_editor/product_editor_view.dart';

class AddProductView extends StatelessWidget {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProductEditorView(
      title: ProductStrings.addProduct,
      successMessage: ProductStrings.createSuccess,
    );
  }
}
