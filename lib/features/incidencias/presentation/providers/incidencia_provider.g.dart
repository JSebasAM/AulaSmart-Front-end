// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incidencia_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(IncidenciasPendientes)
final incidenciasPendientesProvider = IncidenciasPendientesProvider._();

final class IncidenciasPendientesProvider
    extends
        $AsyncNotifierProvider<IncidenciasPendientes, List<IncidenciaEntity>> {
  IncidenciasPendientesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incidenciasPendientesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incidenciasPendientesHash();

  @$internal
  @override
  IncidenciasPendientes create() => IncidenciasPendientes();
}

String _$incidenciasPendientesHash() =>
    r'66ada78f495ebe7faefe6bd5fb6afb8efc248e82';

abstract class _$IncidenciasPendientes
    extends $AsyncNotifier<List<IncidenciaEntity>> {
  FutureOr<List<IncidenciaEntity>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<IncidenciaEntity>>, List<IncidenciaEntity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<IncidenciaEntity>>,
                List<IncidenciaEntity>
              >,
              AsyncValue<List<IncidenciaEntity>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
