import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/ui/views/product_editor/product_editor_view.dart';
import 'package:offline_first_app/ui/widgets/error_retry_wdiget.dart';
import 'package:offline_first_app/ui/widgets/loading_indicator_wdiget.dart';

class EditProductView extends ConsumerWidget {
  const EditProductView({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));

    return productAsync.when(
      loading: () => const Scaffold(body: LoadingIndicator()),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorRetry(
          message: CommonStrings.labelError,
          onRetry: () => ref.invalidate(productDetailProvider(productId)),
        ),
      ),
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text(ProductStrings.noProducts)),
          );
        }
        return ProductEditorView(
          title: ProductStrings.editProduct,
          successMessage: ProductStrings.saveSuccess,
          initialProduct: product,
        );
      },
    );
  }
}
