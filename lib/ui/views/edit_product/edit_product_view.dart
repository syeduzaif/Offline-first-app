import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_controller.dart';

class EditProductView extends HookConsumerWidget {
  const EditProductView({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(editProductControllerProvider(product));
    final controller = ref
        .read(editProductControllerProvider(product).notifier);

    // Pre-populate text controllers from the product (hooks rule)
    final titleCtrl = useTextEditingController();
    final descCtrl = useTextEditingController();
    final priceCtrl = useTextEditingController();
    final brandCtrl = useTextEditingController();
    final stockCtrl = useTextEditingController();
    final selectedCategory = useState<String?>(
      product.category.isNotEmpty ? product.category : null,
    );

    // Set initial values once on mount
    useEffect(() {
      titleCtrl.text = product.title;
      descCtrl.text = product.description;
      priceCtrl.text = product.price.toString();
      brandCtrl.text = product.brand;
      stockCtrl.text = product.stock.toString();
      return null;
    }, const []);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.editProduct),
        actions: [
          TextButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    final error = await controller.saveProduct(
                      title: titleCtrl.text,
                      description: descCtrl.text,
                      price: priceCtrl.text,
                      brand: brandCtrl.text,
                      stock: stockCtrl.text,
                      category: selectedCategory.value,
                    );
                    if (!context.mounted) return;
                    if (error != null) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    } else {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                              ProductStrings.saveSuccess),
                        ),
                      );
                      context.pop();
                    }
                  },
            child: Text(
              CommonStrings.actionSave,
              style: const TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPaddings.allBase,
        child: ProductForm(
          titleController: titleCtrl,
          descriptionController: descCtrl,
          priceController: priceCtrl,
          brandController: brandCtrl,
          stockController: stockCtrl,
          categories: state.categories,
          selectedCategory: selectedCategory.value,
          onCategoryChanged: (slug) =>
              selectedCategory.value = slug,
        ),
      ),
    );
  }
}
