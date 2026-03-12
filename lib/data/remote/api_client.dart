import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:offline_first_app/data/remote/api_constants.dart';

class ApiClient {
  ApiClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(RetryInterceptor(
      dio: _dio,
      retries: 3,
      retryDelays: const [
        Duration(seconds: 1),
        Duration(seconds: 2),
        Duration(seconds: 4),
      ],
    ));
  }

  late final Dio _dio;

  Future<Response<dynamic>> getProducts({
    int limit = 20,
    int skip = 0,
  }) =>
      _dio.get(
        ApiConstants.products,
        queryParameters: {'limit': limit, 'skip': skip},
      );

  Future<Response<dynamic>> getProduct(int id) =>
      _dio.get('${ApiConstants.products}/$id');

  Future<Response<dynamic>> searchProducts(
    String query, {
    int limit = 20,
    int skip = 0,
  }) =>
      _dio.get(
        ApiConstants.productsSearch,
        queryParameters: {'q': query, 'limit': limit, 'skip': skip},
      );

  Future<Response<dynamic>> getProductsByCategory(
    String category, {
    int limit = 20,
    int skip = 0,
  }) =>
      _dio.get(
        '${ApiConstants.products}/category/$category',
        queryParameters: {'limit': limit, 'skip': skip},
      );

  Future<Response<dynamic>> createProduct(
    Map<String, dynamic> data,
  ) =>
      _dio.post(ApiConstants.addProduct, data: data);

  Future<Response<dynamic>> updateProduct(
    int id,
    Map<String, dynamic> data,
  ) =>
      _dio.put('${ApiConstants.products}/$id', data: data);

  Future<Response<dynamic>> deleteProduct(int id) =>
      _dio.delete('${ApiConstants.products}/$id');

  Future<Response<dynamic>> getCategories() =>
      _dio.get(ApiConstants.categories);
}
