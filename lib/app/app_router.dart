import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_view.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_view.dart';
import 'package:offline_first_app/ui/views/main/main_view.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_view.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const _RouteErrorView(),
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const MainView(),
        routes: [
          GoRoute(
            path: 'product/add',
            name: 'addProduct',
            builder: (context, state) => const AddProductView(),
          ),
          GoRoute(
            path: 'product/:id',
            name: 'productDetail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) return const _RouteErrorView();
              return ProductDetailView(productId: id);
            },
            routes: [
              GoRoute(
                path: 'edit',
                name: 'editProduct',
                builder: (context, state) {
                  final id = int.tryParse(state.pathParameters['id'] ?? '');
                  if (id == null) return const _RouteErrorView();
                  return EditProductView(productId: id);
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _RouteErrorView extends StatelessWidget {
  const _RouteErrorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Page not found')),
    );
  }
}
