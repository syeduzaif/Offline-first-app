// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attendanceRecordsDaoHash() =>
    r'd8e9e48f73c0cb4f95a8b9d09ef36915bd5087b9';

/// See also [attendanceRecordsDao].
@ProviderFor(attendanceRecordsDao)
final attendanceRecordsDaoProvider = Provider<AttendanceRecordsDao>.internal(
  attendanceRecordsDao,
  name: r'attendanceRecordsDaoProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceRecordsDaoHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttendanceRecordsDaoRef = ProviderRef<AttendanceRecordsDao>;
String _$attendanceRepositoryHash() =>
    r'4f90437bad5eaa4db90f8115e60767054490d4ec';

/// See also [attendanceRepository].
@ProviderFor(attendanceRepository)
final attendanceRepositoryProvider = Provider<AttendanceRepository>.internal(
  attendanceRepository,
  name: r'attendanceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$attendanceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AttendanceRepositoryRef = ProviderRef<AttendanceRepository>;
String _$attendanceForClassHash() =>
    r'5f270287230ae6382c3a1a73badfd08e02f66da4';

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

/// See also [attendanceForClass].
@ProviderFor(attendanceForClass)
const attendanceForClassProvider = AttendanceForClassFamily();

/// See also [attendanceForClass].
class AttendanceForClassFamily
    extends Family<AsyncValue<List<AttendanceRecord>>> {
  /// See also [attendanceForClass].
  const AttendanceForClassFamily();

  /// See also [attendanceForClass].
  AttendanceForClassProvider call(int classId, String date) {
    return AttendanceForClassProvider(classId, date);
  }

  @override
  AttendanceForClassProvider getProviderOverride(
    covariant AttendanceForClassProvider provider,
  ) {
    return call(provider.classId, provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'attendanceForClassProvider';
}

/// See also [attendanceForClass].
class AttendanceForClassProvider
    extends AutoDisposeStreamProvider<List<AttendanceRecord>> {
  /// See also [attendanceForClass].
  AttendanceForClassProvider(int classId, String date)
    : this._internal(
        (ref) =>
            attendanceForClass(ref as AttendanceForClassRef, classId, date),
        from: attendanceForClassProvider,
        name: r'attendanceForClassProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$attendanceForClassHash,
        dependencies: AttendanceForClassFamily._dependencies,
        allTransitiveDependencies:
            AttendanceForClassFamily._allTransitiveDependencies,
        classId: classId,
        date: date,
      );

  AttendanceForClassProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.classId,
    required this.date,
  }) : super.internal();

  final int classId;
  final String date;

  @override
  Override overrideWith(
    Stream<List<AttendanceRecord>> Function(AttendanceForClassRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttendanceForClassProvider._internal(
        (ref) => create(ref as AttendanceForClassRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        classId: classId,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<AttendanceRecord>> createElement() {
    return _AttendanceForClassProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceForClassProvider &&
        other.classId == classId &&
        other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, classId.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AttendanceForClassRef
    on AutoDisposeStreamProviderRef<List<AttendanceRecord>> {
  /// The parameter `classId` of this provider.
  int get classId;

  /// The parameter `date` of this provider.
  String get date;
}

class _AttendanceForClassProviderElement
    extends AutoDisposeStreamProviderElement<List<AttendanceRecord>>
    with AttendanceForClassRef {
  _AttendanceForClassProviderElement(super.provider);

  @override
  int get classId => (origin as AttendanceForClassProvider).classId;
  @override
  String get date => (origin as AttendanceForClassProvider).date;
}

String _$attendanceForStudentHash() =>
    r'5c17e6360d2b089183bc6221d927178370d64351';

/// See also [attendanceForStudent].
@ProviderFor(attendanceForStudent)
const attendanceForStudentProvider = AttendanceForStudentFamily();

/// See also [attendanceForStudent].
class AttendanceForStudentFamily
    extends Family<AsyncValue<List<AttendanceRecord>>> {
  /// See also [attendanceForStudent].
  const AttendanceForStudentFamily();

  /// See also [attendanceForStudent].
  AttendanceForStudentProvider call(int studentId) {
    return AttendanceForStudentProvider(studentId);
  }

  @override
  AttendanceForStudentProvider getProviderOverride(
    covariant AttendanceForStudentProvider provider,
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
  String? get name => r'attendanceForStudentProvider';
}

/// See also [attendanceForStudent].
class AttendanceForStudentProvider
    extends AutoDisposeStreamProvider<List<AttendanceRecord>> {
  /// See also [attendanceForStudent].
  AttendanceForStudentProvider(int studentId)
    : this._internal(
        (ref) =>
            attendanceForStudent(ref as AttendanceForStudentRef, studentId),
        from: attendanceForStudentProvider,
        name: r'attendanceForStudentProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$attendanceForStudentHash,
        dependencies: AttendanceForStudentFamily._dependencies,
        allTransitiveDependencies:
            AttendanceForStudentFamily._allTransitiveDependencies,
        studentId: studentId,
      );

  AttendanceForStudentProvider._internal(
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
    Stream<List<AttendanceRecord>> Function(AttendanceForStudentRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttendanceForStudentProvider._internal(
        (ref) => create(ref as AttendanceForStudentRef),
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
  AutoDisposeStreamProviderElement<List<AttendanceRecord>> createElement() {
    return _AttendanceForStudentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceForStudentProvider &&
        other.studentId == studentId;
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
mixin AttendanceForStudentRef
    on AutoDisposeStreamProviderRef<List<AttendanceRecord>> {
  /// The parameter `studentId` of this provider.
  int get studentId;
}

class _AttendanceForStudentProviderElement
    extends AutoDisposeStreamProviderElement<List<AttendanceRecord>>
    with AttendanceForStudentRef {
  _AttendanceForStudentProviderElement(super.provider);

  @override
  int get studentId => (origin as AttendanceForStudentProvider).studentId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
