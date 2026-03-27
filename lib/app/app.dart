import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_view.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_view.dart';
import 'package:offline_first_app/ui/views/main/main_view.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => const _ErrorView(),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainView(),
    ),
    GoRoute(
      path: '/product/add',
      builder: (context, state) => const AddProductView(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        if (id == null) return const _ErrorView();
        return ProductDetailView(productId: id);
      },
      routes: [
        GoRoute(
          path: 'edit',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) return const _ErrorView();
            return EditProductView(productId: id);
          },
        ),
      ],
    ),
  ],
);

class _ErrorView extends StatelessWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Page not found')),
    );
  }
}
