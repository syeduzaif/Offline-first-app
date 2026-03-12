import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:offline_first_app/domain/models/sync_status.dart';

part 'product.freezed.dart';
part 'product.g.dart';

@freezed
abstract class Product with _$Product {
  const factory Product({
    required int id,
    required String title,
    @Default('') String description,
    @Default(0) double price,
    @Default(0) double discountPercentage,
    @Default(0) double rating,
    @Default(0) int stock,
    @Default('') String brand,
    @Default('') String category,
    @Default('') String thumbnail,
    @Default([]) List<String> images,
    @Default(SyncStatus.synced) SyncStatus syncStatus,
    DateTime? lastModified,
    int? remoteId,
    @Default(false) bool isLocalOnly,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
