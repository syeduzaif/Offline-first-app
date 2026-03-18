import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:offline_first_app/providers/service_providers.dart';
import 'package:offline_first_app/ui/views/main/widgets/bottom_navbar_wdiget.dart';
import 'package:offline_first_app/ui/views/products/products_view.dart';
import 'package:offline_first_app/ui/views/sync_queue/sync_queue_view.dart';

class MainView extends HookConsumerWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = useState(0);
    final pendingCount =
        ref.watch(pendingSyncCountProvider).valueOrNull ?? 0;

    const List<Widget> screens = [ProductsView(), SyncQueueView()];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: currentIndex.value,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              selectedIndex: currentIndex.value,
              onTabChange: (i) => currentIndex.value = i,
              pendingSyncCount: pendingCount,
            ),
          ),
        ],
      ),
    );
  }
}
