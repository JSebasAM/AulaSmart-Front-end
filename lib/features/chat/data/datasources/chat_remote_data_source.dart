import 'package:dio/dio.dart';

class ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSource(this.dio);

  Future<String> sendMessage(String message) async {
    final response = await dio.post('/chat', data: {'mensaje': message});
    final data = response.data;
    if (data is String) return data;
    if (data is Map) {
      return (data['respuesta'] ?? data['message'] ?? data['data'] ?? '').toString();
    }
    return data.toString();
  }
}
