import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_paddings.dart';
import 'package:offline_first_app/core/constants/strings/app_strings.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_controller.dart';
import 'package:offline_first_app/ui/views/add_product/widgets/product_form_wdiget.dart';

class AddProductView extends HookConsumerWidget {
  const AddProductView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addProductControllerProvider);
    final controller =
        ref.read(addProductControllerProvider.notifier);

    // UI-layer text controllers (hooks rule: useTextEditingController)
    final titleCtrl = useTextEditingController();
    final descCtrl = useTextEditingController();
    final priceCtrl = useTextEditingController();
    final brandCtrl = useTextEditingController();
    final stockCtrl = useTextEditingController();
    final selectedCategory = useState<String?>(null);

    return Scaffold(
      appBar: AppBar(
        title: const Text(ProductStrings.addProduct),
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
                              ProductStrings.createSuccess),
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
