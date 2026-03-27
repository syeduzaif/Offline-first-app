import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:offline_first_app/domain/models/product.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_view.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_view.dart';
import 'package:offline_first_app/ui/views/main/main_view.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_view.dart';

final appRouter = GoRouter(
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(),
    body: const Center(child: Text('Page not found')),
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainView(),
    ),
    GoRoute(
      path: '/product-detail',
      builder: (context, state) {
        final productId = state.extra;
        if (productId is! int) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Invalid product')),
          );
        }
        return ProductDetailView(productId: productId);
      },
    ),
    GoRoute(
      path: '/add-product',
      builder: (context, state) => const AddProductView(),
    ),
    GoRoute(
      path: '/edit-product',
      builder: (context, state) {
        final product = state.extra;
        if (product is! Product) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Invalid product')),
          );
        }
        return EditProductView(product: product);
      },
    ),
  ],
);
