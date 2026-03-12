import 'package:flutter/material.dart';
import 'package:offline_first_app/ui/views/main/main_viewmodel.dart';
import 'package:offline_first_app/ui/views/main/widgets/bottom_navbar_wdiget.dart';
import 'package:offline_first_app/ui/views/products/products_view.dart';
import 'package:offline_first_app/ui/views/sync_queue/sync_queue_view.dart';
import 'package:stacked/stacked.dart';

class MainView extends StackedView<MainViewModel> {
  const MainView({super.key});

  @override
  void onViewModelReady(MainViewModel viewModel) {
    viewModel.initialize();
    super.onViewModelReady(viewModel);
  }

  @override
  Widget builder(
    BuildContext context,
    MainViewModel viewModel,
    Widget? child,
  ) {
    const screens = [
      ProductsView(),
      SyncQueueView(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: viewModel.currentIndex,
            children: screens,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              selectedIndex: viewModel.currentIndex,
              onTabChange: viewModel.onTabChanged,
              pendingSyncCount:
                  viewModel.pendingSyncCount,
            ),
          ),
        ],
      ),
    );
  }

  @override
  MainViewModel viewModelBuilder(BuildContext context) =>
      MainViewModel();
}
