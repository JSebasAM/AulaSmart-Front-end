// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aulas_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(aulaRepository)
final aulaRepositoryProvider = AulaRepositoryProvider._();

final class AulaRepositoryProvider
    extends
        $FunctionalProvider<
          AulaRepositoryImpl,
          AulaRepositoryImpl,
          AulaRepositoryImpl
        >
    with $Provider<AulaRepositoryImpl> {
  AulaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aulaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aulaRepositoryHash();

  @$internal
  @override
  $ProviderElement<AulaRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AulaRepositoryImpl create(Ref ref) {
    return aulaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AulaRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AulaRepositoryImpl>(value),
    );
  }
}

String _$aulaRepositoryHash() => r'6462fa4cc1e3218eebf6ffd2a822629c2059775b';

@ProviderFor(Aulas)
final aulasProvider = AulasProvider._();

final class AulasProvider
    extends $AsyncNotifierProvider<Aulas, List<AulaEntity>> {
  AulasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aulasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aulasHash();

  @$internal
  @override
  Aulas create() => Aulas();
}

String _$aulasHash() => r'b6f787a08f7305119c8a4bec04b4e49fc06583c2';

abstract class _$Aulas extends $AsyncNotifier<List<AulaEntity>> {
  FutureOr<List<AulaEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<AulaEntity>>, List<AulaEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AulaEntity>>, List<AulaEntity>>,
              AsyncValue<List<AulaEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(CategoriaFiltro)
final categoriaFiltroProvider = CategoriaFiltroProvider._();

final class CategoriaFiltroProvider
    extends $NotifierProvider<CategoriaFiltro, String> {
  CategoriaFiltroProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriaFiltroProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriaFiltroHash();

  @$internal
  @override
  CategoriaFiltro create() => CategoriaFiltro();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$categoriaFiltroHash() => r'5609cd09236b5b62067a42c16d22abc1aafcc1c4';

abstract class _$CategoriaFiltro extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(aulasFiltradas)
final aulasFiltradasProvider = AulasFiltradasProvider._();

final class AulasFiltradasProvider
    extends
        $FunctionalProvider<
          List<AulaEntity>,
          List<AulaEntity>,
          List<AulaEntity>
        >
    with $Provider<List<AulaEntity>> {
  AulasFiltradasProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'aulasFiltradasProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$aulasFiltradasHash();

  @$internal
  @override
  $ProviderElement<List<AulaEntity>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<AulaEntity> create(Ref ref) {
    return aulasFiltradas(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AulaEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AulaEntity>>(value),
    );
  }
}

String _$aulasFiltradasHash() => r'8dbbd9ab399f8fd68e5bddf2a73031203d46904b';
