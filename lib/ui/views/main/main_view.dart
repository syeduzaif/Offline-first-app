import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/ui/views/main/main_state.dart';
import 'package:offline_first_app/ui/views/main/widgets/bottom_navbar_wdiget.dart';
import 'package:offline_first_app/ui/views/products/products_view.dart';
import 'package:offline_first_app/ui/views/sync_queue/sync_queue_view.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mainControllerProvider);
    final controller =
        ref.read(mainControllerProvider.notifier);

    const screens = [
      ProductsView(),
      SyncQueueView(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: state.currentIndex,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              selectedIndex: state.currentIndex,
              onTabChange: controller.onTabChanged,
              pendingSyncCount: state.pendingSyncCount,
            ),
          ),
        ],
      ),
    );
  }
}
