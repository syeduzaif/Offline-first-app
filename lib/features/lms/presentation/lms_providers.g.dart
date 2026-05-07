// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lms_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$lmsClassesDaoHash() => r'472468065dd7befb7d5010ab33b1d766164ed6dd';

/// See also [lmsClassesDao].
@ProviderFor(lmsClassesDao)
final lmsClassesDaoProvider = Provider<LmsClassesDao>.internal(
  lmsClassesDao,
  name: r'lmsClassesDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lmsClassesDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LmsClassesDaoRef = ProviderRef<LmsClassesDao>;
String _$lmsClassworkItemsDaoHash() =>
    r'ccb8a627b55b3435fb51bb703dc4956e059d1212';

/// See also [lmsClassworkItemsDao].
@ProviderFor(lmsClassworkItemsDao)
final lmsClassworkItemsDaoProvider = Provider<LmsClassworkItemsDao>.internal(
  lmsClassworkItemsDao,
  name: r'lmsClassworkItemsDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lmsClassworkItemsDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LmsClassworkItemsDaoRef = ProviderRef<LmsClassworkItemsDao>;
String _$lmsRepositoryHash() => r'cc528b0ec7250f9a7ad939d26fff99a4d3496cb2';

/// See also [lmsRepository].
@ProviderFor(lmsRepository)
final lmsRepositoryProvider = Provider<LmsRepository>.internal(
  lmsRepository,
  name: r'lmsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lmsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LmsRepositoryRef = ProviderRef<LmsRepository>;
String _$lmsClassesStreamHash() => r'fc3731081d9be83fce931d653a6f56d8594d6794';

/// See also [lmsClassesStream].
@ProviderFor(lmsClassesStream)
final lmsClassesStreamProvider =
    AutoDisposeStreamProvider<List<LmsClass>>.internal(
      lmsClassesStream,
      name: r'lmsClassesStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$lmsClassesStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LmsClassesStreamRef = AutoDisposeStreamProviderRef<List<LmsClass>>;
String _$lmsClassDetailHash() => r'e21093eba30a586aded461fc2b067bf58f2de018';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [lmsClassDetail].
@ProviderFor(lmsClassDetail)
const lmsClassDetailProvider = LmsClassDetailFamily();

/// See also [lmsClassDetail].
class LmsClassDetailFamily extends Family<AsyncValue<LmsClass?>> {
  /// See also [lmsClassDetail].
  const LmsClassDetailFamily();

  /// See also [lmsClassDetail].
  LmsClassDetailProvider call(int classId) {
    return LmsClassDetailProvider(classId);
  }

  @override
  LmsClassDetailProvider getProviderOverride(
    covariant LmsClassDetailProvider provider,
  ) {
    return call(provider.classId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lmsClassDetailProvider';
}

/// See also [lmsClassDetail].
class LmsClassDetailProvider extends AutoDisposeStreamProvider<LmsClass?> {
  /// See also [lmsClassDetail].
  LmsClassDetailProvider(int classId)
    : this._internal(
        (ref) => lmsClassDetail(ref as LmsClassDetailRef, classId),
        from: lmsClassDetailProvider,
        name: r'lmsClassDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$lmsClassDetailHash,
        dependencies: LmsClassDetailFamily._dependencies,
        allTransitiveDependencies:
            LmsClassDetailFamily._allTransitiveDependencies,
        classId: classId,
      );

  LmsClassDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final int classId;

  @override
  Override overrideWith(
    Stream<LmsClass?> Function(LmsClassDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LmsClassDetailProvider._internal(
        (ref) => create(ref as LmsClassDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<LmsClass?> createElement() {
    return _LmsClassDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LmsClassDetailProvider && other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LmsClassDetailRef on AutoDisposeStreamProviderRef<LmsClass?> {
  /// The parameter `classId` of this provider.
  int get classId;
}

class _LmsClassDetailProviderElement
    extends AutoDisposeStreamProviderElement<LmsClass?>
    with LmsClassDetailRef {
  _LmsClassDetailProviderElement(super.provider);

  @override
  int get classId => (origin as LmsClassDetailProvider).classId;
}

String _$lmsClassworkForClassHash() =>
    r'5f0f2cb62a4dd76342e1ae746dcf28cbec9da4cb';

/// See also [lmsClassworkForClass].
@ProviderFor(lmsClassworkForClass)
const lmsClassworkForClassProvider = LmsClassworkForClassFamily();

/// See also [lmsClassworkForClass].
class LmsClassworkForClassFamily
    extends Family<AsyncValue<List<LmsClassworkItem>>> {
  /// See also [lmsClassworkForClass].
  const LmsClassworkForClassFamily();

  /// See also [lmsClassworkForClass].
  LmsClassworkForClassProvider call(int classId) {
    return LmsClassworkForClassProvider(classId);
  }

  @override
  LmsClassworkForClassProvider getProviderOverride(
    covariant LmsClassworkForClassProvider provider,
  ) {
    return call(provider.classId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lmsClassworkForClassProvider';
}

/// See also [lmsClassworkForClass].
class LmsClassworkForClassProvider
    extends AutoDisposeStreamProvider<List<LmsClassworkItem>> {
  /// See also [lmsClassworkForClass].
  LmsClassworkForClassProvider(int classId)
    : this._internal(
        (ref) => lmsClassworkForClass(ref as LmsClassworkForClassRef, classId),
        from: lmsClassworkForClassProvider,
        name: r'lmsClassworkForClassProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$lmsClassworkForClassHash,
        dependencies: LmsClassworkForClassFamily._dependencies,
        allTransitiveDependencies:
            LmsClassworkForClassFamily._allTransitiveDependencies,
        classId: classId,
      );

  LmsClassworkForClassProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
  }) : super.internal();

  final int classId;

  @override
  Override overrideWith(
    Stream<List<LmsClassworkItem>> Function(LmsClassworkForClassRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LmsClassworkForClassProvider._internal(
        (ref) => create(ref as LmsClassworkForClassRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<LmsClassworkItem>> createElement() {
    return _LmsClassworkForClassProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LmsClassworkForClassProvider && other.classId == classId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LmsClassworkForClassRef
    on AutoDisposeStreamProviderRef<List<LmsClassworkItem>> {
  /// The parameter `classId` of this provider.
  int get classId;
}

class _LmsClassworkForClassProviderElement
    extends AutoDisposeStreamProviderElement<List<LmsClassworkItem>>
    with LmsClassworkForClassRef {
  _LmsClassworkForClassProviderElement(super.provider);

  @override
  int get classId => (origin as LmsClassworkForClassProvider).classId;
}

String _$lmsClassworkItemDetailHash() =>
    r'7c95ea9703a05038a394c3582da9adb21c38c079';

/// See also [lmsClassworkItemDetail].
@ProviderFor(lmsClassworkItemDetail)
const lmsClassworkItemDetailProvider = LmsClassworkItemDetailFamily();

/// See also [lmsClassworkItemDetail].
class LmsClassworkItemDetailFamily
    extends Family<AsyncValue<LmsClassworkItem?>> {
  /// See also [lmsClassworkItemDetail].
  const LmsClassworkItemDetailFamily();

  /// See also [lmsClassworkItemDetail].
  LmsClassworkItemDetailProvider call(int itemId) {
    return LmsClassworkItemDetailProvider(itemId);
  }

  @override
  LmsClassworkItemDetailProvider getProviderOverride(
    covariant LmsClassworkItemDetailProvider provider,
  ) {
    return call(provider.itemId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'lmsClassworkItemDetailProvider';
}

/// See also [lmsClassworkItemDetail].
class LmsClassworkItemDetailProvider
    extends AutoDisposeStreamProvider<LmsClassworkItem?> {
  /// See also [lmsClassworkItemDetail].
  LmsClassworkItemDetailProvider(int itemId)
    : this._internal(
        (ref) =>
            lmsClassworkItemDetail(ref as LmsClassworkItemDetailRef, itemId),
        from: lmsClassworkItemDetailProvider,
        name: r'lmsClassworkItemDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$lmsClassworkItemDetailHash,
        dependencies: LmsClassworkItemDetailFamily._dependencies,
        allTransitiveDependencies:
            LmsClassworkItemDetailFamily._allTransitiveDependencies,
        itemId: itemId,
      );

  LmsClassworkItemDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.itemId,
  }) : super.internal();

  final int itemId;

  @override
  Override overrideWith(
    Stream<LmsClassworkItem?> Function(LmsClassworkItemDetailRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LmsClassworkItemDetailProvider._internal(
        (ref) => create(ref as LmsClassworkItemDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        itemId: itemId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<LmsClassworkItem?> createElement() {
    return _LmsClassworkItemDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LmsClassworkItemDetailProvider && other.itemId == itemId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, itemId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin LmsClassworkItemDetailRef
    on AutoDisposeStreamProviderRef<LmsClassworkItem?> {
  /// The parameter `itemId` of this provider.
  int get itemId;
}

class _LmsClassworkItemDetailProviderElement
    extends AutoDisposeStreamProviderElement<LmsClassworkItem?>
    with LmsClassworkItemDetailRef {
  _LmsClassworkItemDetailProviderElement(super.provider);

  @override
  int get itemId => (origin as LmsClassworkItemDetailProvider).itemId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
