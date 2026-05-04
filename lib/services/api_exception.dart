import 'package:dio/dio.dart';

class ApiException {

  final  String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  factory ApiException.fromDioException(DioException e) {
    switch(e.type){
      // Manejo de errores de conexión y tiempo de espera
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Tiempo de recepción agotado',
          statusCode: 408,
          );
      // Manejo de errores de conexión
      case DioExceptionType.connectionError:
        return const ApiException(
          message:    'Sin conexión al servidor',
          statusCode: 503,
        );
      // Manejo de errores de respuesta del servidor
        default:
        final statusCode = e.response?.statusCode;
        final message    = e.response?.data?['message']
                        ?? e.response?.data?['error']
                        ?? 'Error inesperado';
        return ApiException(message: message, statusCode: statusCode);
    }
  }
  @override
  String toString() => message;
}