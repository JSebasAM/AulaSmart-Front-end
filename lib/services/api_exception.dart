import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
        
        if (kDebugMode) {
          print('API_ERROR_STATUS: $statusCode');
          print('API_ERROR_DATA: ${e.response?.headers}');
        }

        String message = 'Error inesperado';
        
        if (e.response?.data is Map) {
          message = e.response?.data['message']?.toString() 
                 ?? e.response?.data['error']?.toString() 
                 ?? 'Error inesperado';
        } else if (e.response?.data is String) {
          message = e.response?.data;
        }

        if (statusCode == 402) {
          message = 'Pago requerido o cuota excedida (402)';
        } else if (statusCode == 403) {
          message = 'Acceso denegado (403)';
        }
        
        return ApiException(message: message, statusCode: statusCode);
    }
  }
  @override
  String toString() => message;
}