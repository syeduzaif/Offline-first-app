import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:offline_first_app/ui/views/main/main_view.dart';
import 'package:offline_first_app/ui/views/product_detail/product_detail_view.dart';
import 'package:offline_first_app/ui/views/add_product/add_product_view.dart';
import 'package:offline_first_app/ui/views/edit_product/edit_product_view.dart';
import 'package:offline_first_app/ui/views/sync_queue/sync_queue_view.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: MainView, initial: true),
    MaterialRoute(page: ProductDetailView),
    MaterialRoute(page: AddProductView),
    MaterialRoute(page: EditProductView),
    MaterialRoute(page: SyncQueueView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: SnackbarService),
  ],
)
class App {}
