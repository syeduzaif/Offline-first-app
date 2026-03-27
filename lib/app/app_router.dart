import 'package:go_router/go_router.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_view.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_view.dart';
import 'package:offline_first_app/ui/views/main/main_view.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_view.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainView(),
    ),
    GoRoute(
      path: '/product-detail/:id',
      builder: (context, state) => ProductDetailView(
        productId: int.parse(state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/product-add',
      builder: (context, state) => const AddProductView(),
    ),
    GoRoute(
      path: '/product-edit',
      builder: (context, state) =>
          EditProductView(product: state.extra! as Product),
    ),
  ],
);
