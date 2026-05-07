// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'students_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$studentsDaoHash() => r'8655fd8bc59458792436ea336dc1c14215202f3d';

/// See also [studentsDao].
@ProviderFor(studentsDao)
final studentsDaoProvider = Provider<StudentsDao>.internal(
  studentsDao,
  name: r'studentsDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studentsDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentsDaoRef = ProviderRef<StudentsDao>;
String _$studentsRepositoryHash() =>
    r'1e087e1ec73f2b6f0326458c885204c0ead8b67d';

/// See also [studentsRepository].
@ProviderFor(studentsRepository)
final studentsRepositoryProvider = Provider<StudentsRepository>.internal(
  studentsRepository,
  name: r'studentsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$studentsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentsRepositoryRef = ProviderRef<StudentsRepository>;
String _$studentsStreamHash() => r'7265ef23eb46bd2b77eef65d1f5f78b5562318e7';

/// See also [studentsStream].
@ProviderFor(studentsStream)
final studentsStreamProvider =
    AutoDisposeStreamProvider<List<Student>>.internal(
      studentsStream,
      name: r'studentsStreamProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$studentsStreamHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StudentsStreamRef = AutoDisposeStreamProviderRef<List<Student>>;
String _$studentDetailHash() => r'4c418c61a1584e82e84b50d4005580bec1dfa81d';

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

/// See also [studentDetail].
@ProviderFor(studentDetail)
const studentDetailProvider = StudentDetailFamily();

/// See also [studentDetail].
class StudentDetailFamily extends Family<AsyncValue<Student?>> {
  /// See also [studentDetail].
  const StudentDetailFamily();

  /// See also [studentDetail].
  StudentDetailProvider call(int studentId) {
    return StudentDetailProvider(studentId);
  }

  @override
  StudentDetailProvider getProviderOverride(
    covariant StudentDetailProvider provider,
  ) {
    return call(provider.studentId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'studentDetailProvider';
}

/// See also [studentDetail].
class StudentDetailProvider extends AutoDisposeStreamProvider<Student?> {
  /// See also [studentDetail].
  StudentDetailProvider(int studentId)
    : this._internal(
        (ref) => studentDetail(ref as StudentDetailRef, studentId),
        from: studentDetailProvider,
        name: r'studentDetailProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$studentDetailHash,
        dependencies: StudentDetailFamily._dependencies,
        allTransitiveDependencies:
            StudentDetailFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  StudentDetailProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.studentId,
  }) : super.internal();

  final int studentId;

  @override
  Override overrideWith(
    Stream<Student?> Function(StudentDetailRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: StudentDetailProvider._internal(
        (ref) => create(ref as StudentDetailRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        studentId: studentId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<Student?> createElement() {
    return _StudentDetailProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is StudentDetailProvider && other.studentId == studentId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, studentId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin StudentDetailRef on AutoDisposeStreamProviderRef<Student?> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _StudentDetailProviderElement
    extends AutoDisposeStreamProviderElement<Student?>
    with StudentDetailRef {
  _StudentDetailProviderElement(super.provider);

  @override
  int get studentId => (origin as StudentDetailProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
