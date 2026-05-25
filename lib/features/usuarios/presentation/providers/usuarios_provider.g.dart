// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuarios_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(usuarioRepository)
final usuarioRepositoryProvider = UsuarioRepositoryProvider._();

final class UsuarioRepositoryProvider
    extends
        $FunctionalProvider<
          UsuarioRepositoryImpl,
          UsuarioRepositoryImpl,
          UsuarioRepositoryImpl
        >
    with $Provider<UsuarioRepositoryImpl> {
  UsuarioRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuarioRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuarioRepositoryHash();

  @$internal
  @override
  $ProviderElement<UsuarioRepositoryImpl> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UsuarioRepositoryImpl create(Ref ref) {
    return usuarioRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UsuarioRepositoryImpl value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UsuarioRepositoryImpl>(value),
    );
  }
}

String _$usuarioRepositoryHash() => r'1ba8006e47d0bc037897d1d827cd7415199d18b7';

@ProviderFor(Usuarios)
final usuariosProvider = UsuariosProvider._();

final class UsuariosProvider
    extends $AsyncNotifierProvider<Usuarios, List<UsuarioEntity>> {
  UsuariosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuariosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuariosHash();

  @$internal
  @override
  Usuarios create() => Usuarios();
}

String _$usuariosHash() => r'9f4a904fe7f16d639aa3c3c8b55a3673223255de';

abstract class _$Usuarios extends $AsyncNotifier<List<UsuarioEntity>> {
  FutureOr<List<UsuarioEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<UsuarioEntity>>, List<UsuarioEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<UsuarioEntity>>, List<UsuarioEntity>>,
              AsyncValue<List<UsuarioEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(UsuarioFiltroRol)
final usuarioFiltroRolProvider = UsuarioFiltroRolProvider._();

final class UsuarioFiltroRolProvider
    extends $NotifierProvider<UsuarioFiltroRol, String> {
  UsuarioFiltroRolProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuarioFiltroRolProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuarioFiltroRolHash();

  @$internal
  @override
  UsuarioFiltroRol create() => UsuarioFiltroRol();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$usuarioFiltroRolHash() => r'0d7c13f18a799d3de7ac3bcaaf0c23ab3e146f16';

abstract class _$UsuarioFiltroRol extends $Notifier<String> {
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

@ProviderFor(UsuariosPaginados)
final usuariosPaginadosProvider = UsuariosPaginadosProvider._();

final class UsuariosPaginadosProvider
    extends $NotifierProvider<UsuariosPaginados, int> {
  UsuariosPaginadosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuariosPaginadosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuariosPaginadosHash();

  @$internal
  @override
  UsuariosPaginados create() => UsuariosPaginados();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$usuariosPaginadosHash() => r'047355eafdbf1fe973d1fe5664146a090f0b9f79';

abstract class _$UsuariosPaginados extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(usuariosFiltrados)
final usuariosFiltradosProvider = UsuariosFiltradosProvider._();

final class UsuariosFiltradosProvider
    extends
        $FunctionalProvider<
          List<UsuarioEntity>,
          List<UsuarioEntity>,
          List<UsuarioEntity>
        >
    with $Provider<List<UsuarioEntity>> {
  UsuariosFiltradosProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'usuariosFiltradosProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$usuariosFiltradosHash();

  @$internal
  @override
  $ProviderElement<List<UsuarioEntity>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<UsuarioEntity> create(Ref ref) {
    return usuariosFiltrados(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<UsuarioEntity> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<UsuarioEntity>>(value),
    );
  }
}

String _$usuariosFiltradosHash() => r'6d6cd4e065910f177af09fc82cad17c490e6d547';
