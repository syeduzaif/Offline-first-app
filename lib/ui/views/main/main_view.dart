import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/providers/core_providers.dart';
import 'package:offline_first_app/ui/views/main/main_controller.dart';
import 'package:offline_first_app/ui/views/main/widgets/bottom_navbar_wdiget.dart';
import 'package:offline_first_app/ui/views/products/products_view.dart';
import 'package:offline_first_app/ui/views/sync_queue/sync_queue_view.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(mainTabProvider);
    final pendingSyncCount =
        ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

    // ignore: prefer_const_constructors_in_immutables
    final screens = <Widget>[
      const ProductsView(),
      const SyncQueueView(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              selectedIndex: currentIndex,
              onTabChange: (index) =>
                  ref.read(mainTabProvider.notifier).state = index,
              pendingSyncCount: pendingSyncCount,
            ),
          ),
        ],
      ),
    );
  }
}
