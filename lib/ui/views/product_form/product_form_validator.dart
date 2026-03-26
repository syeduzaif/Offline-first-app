import 'package:offline_first_app/core/constants/strings/app_strings.dart';

class ProductFormValidator {
  ProductFormValidator._();

  static String? validate({
    required String title,
    required String price,
    required String stock,
    required String? selectedCategory,
  }) {
    if (title.trim().isEmpty) {
      return ProductStrings.errorTitleRequired;
    }

    final parsedPrice = double.tryParse(price.trim());
    if (parsedPrice == null || parsedPrice < 0) {
      return ProductStrings.errorInvalidPrice;
    }

    final parsedStock = int.tryParse(stock.trim());
    if (parsedStock == null || parsedStock < 0) {
      return ProductStrings.errorInvalidStock;
    }

    if (selectedCategory == null || selectedCategory.isEmpty) {
      return ProductStrings.errorCategoryRequired;
    }

    return null;
  }
}
