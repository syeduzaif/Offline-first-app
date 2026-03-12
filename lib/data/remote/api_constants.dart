class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const String products = '/products';
  static const String productsSearch = '/products/search';
  static const String categories = '/products/categories';
  static const String addProduct = '/products/add';

  static const int defaultLimit = 20;
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
