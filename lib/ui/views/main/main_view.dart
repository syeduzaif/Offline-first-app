import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:offline_first_app/core/providers/providers.dart';
import 'package:offline_first_app/ui/views/main/widgets/bottom_navbar_wdiget.dart';
import 'package:offline_first_app/ui/views/products/products_view.dart';
import 'package:offline_first_app/ui/views/sync_queue/sync_queue_view.dart';

class MainView extends ConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabProvider);
    final pendingCount =
        ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

    const screens = [
      ProductsView(),
      SyncQueueView(),
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
              onTabChange: (i) =>
                  ref.read(currentTabProvider.notifier).state = i,
              pendingSyncCount: pendingCount,
            ),
          ),
        ],
      ),
    );
  }
}
