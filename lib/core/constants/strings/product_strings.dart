class ProductStrings {
  ProductStrings._();

  static const String titleProducts = 'Products';
  static const String searchProducts = 'Search products...';
  static const String allCategories = 'All';
  static const String addProduct = 'Add Product';
  static const String editProduct = 'Edit Product';
  static const String deleteProduct = 'Delete Product';
  static const String productTitle = 'Title';
  static const String productDescription = 'Description';
  static const String productPrice = 'Price';
  static const String productBrand = 'Brand';
  static const String productCategory = 'Category';
  static const String productStock = 'Stock';
  static const String productRating = 'Rating';
  static const String productDiscount = 'Discount';
  static const String inStock = 'In Stock';
  static const String outOfStock = 'Out of Stock';
  static const String noProducts = 'No products found';
  static const String confirmDelete =
      'Are you sure you want to delete this product?';
  static const String deleteSuccess = 'Product deleted';
  static const String saveSuccess = 'Product saved';
  static const String createSuccess = 'Product created';

  // Validation errors
  static const String errorTitleRequired = 'Title is required';
  static const String errorInvalidPrice =
      'Price must be 0 or greater';
  static const String errorInvalidStock =
      'Stock must be 0 or greater';
  static const String errorCategoryRequired =
      'Please select a category';
  static const String errorSaveFailed =
      'Failed to save. Please try again';
  static const String errorDeleteFailed =
      'Failed to delete. Please try again';

  static String priceLabel(double price) =>
      '\$${price.toStringAsFixed(2)}';
  static String discountLabel(double pct) =>
      '${pct.toStringAsFixed(0)}% OFF';
  static String stockCount(int count) => '$count in stock';
  static String ratingLabel(double rating) =>
      rating.toStringAsFixed(1);
}
