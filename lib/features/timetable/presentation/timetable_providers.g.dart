// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timetable_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$timetableEntriesDaoHash() =>
    r'21fd01f9f79714f11dee4040044bb0ab1dd6e07d';

/// See also [timetableEntriesDao].
@ProviderFor(timetableEntriesDao)
final timetableEntriesDaoProvider = Provider<TimetableEntriesDao>.internal(
  timetableEntriesDao,
  name: r'timetableEntriesDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timetableEntriesDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimetableEntriesDaoRef = ProviderRef<TimetableEntriesDao>;
String _$timetableRepositoryHash() =>
    r'f0bfe2ba85ae1e8ce7b60ced9ec848c20c8eca33';

/// See also [timetableRepository].
@ProviderFor(timetableRepository)
final timetableRepositoryProvider = Provider<TimetableRepository>.internal(
  timetableRepository,
  name: r'timetableRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$timetableRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TimetableRepositoryRef = ProviderRef<TimetableRepository>;
String _$timetableForDayHash() => r'1de58860eb1aefc5aa78e5af48b720a1deb4953d';

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

/// See also [timetableForDay].
@ProviderFor(timetableForDay)
const timetableForDayProvider = TimetableForDayFamily();

/// See also [timetableForDay].
class TimetableForDayFamily extends Family<AsyncValue<List<TimetableEntry>>> {
  /// See also [timetableForDay].
  const TimetableForDayFamily();

  /// See also [timetableForDay].
  TimetableForDayProvider call(String day) {
    return TimetableForDayProvider(day);
  }

  @override
  TimetableForDayProvider getProviderOverride(
    covariant TimetableForDayProvider provider,
  ) {
    return call(provider.day);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'timetableForDayProvider';
}

/// See also [timetableForDay].
class TimetableForDayProvider
    extends AutoDisposeStreamProvider<List<TimetableEntry>> {
  /// See also [timetableForDay].
  TimetableForDayProvider(String day)
    : this._internal(
        (ref) => timetableForDay(ref as TimetableForDayRef, day),
        from: timetableForDayProvider,
        name: r'timetableForDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$timetableForDayHash,
        dependencies: TimetableForDayFamily._dependencies,
        allTransitiveDependencies:
            TimetableForDayFamily._allTransitiveDependencies,
        day: day,
      );

  TimetableForDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.day,
  }) : super.internal();

  final String day;

  @override
  Override overrideWith(
    Stream<List<TimetableEntry>> Function(TimetableForDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: TimetableForDayProvider._internal(
        (ref) => create(ref as TimetableForDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        day: day,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<TimetableEntry>> createElement() {
    return _TimetableForDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is TimetableForDayProvider && other.day == day;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, day.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin TimetableForDayRef on AutoDisposeStreamProviderRef<List<TimetableEntry>> {
  /// The parameter `day` of this provider.
  String get day;
}

class _TimetableForDayProviderElement
    extends AutoDisposeStreamProviderElement<List<TimetableEntry>>
    with TimetableForDayRef {
  _TimetableForDayProviderElement(super.provider);

  @override
  String get day => (origin as TimetableForDayProvider).day;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
