import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/core/network/dio_client.dart';
import 'package:aulasmart_front_end/features/chat/domain/entities/chat_message_entity.dart';
import 'package:aulasmart_front_end/features/chat/domain/usecases/send_message.dart';
import 'package:aulasmart_front_end/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:aulasmart_front_end/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:aulasmart_front_end/features/chat/domain/repositories/chat_repository.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  final dioChat = Dio(dio.options.copyWith(
    baseUrl: ApiUrls.chat,
    receiveTimeout: const Duration(minutes: 2),
  ));
  dioChat.interceptors.addAll(dio.interceptors);
  return ChatRemoteDataSource(dioChat);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remote = ref.read(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource: remote);
});

final sendMessageProvider = Provider((ref) {
  final repo = ref.read(chatRepositoryProvider);
  return SendMessage(repo);
});

class ChatNotifier extends Notifier<List<ChatMessageEntity>> {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  @override
  List<ChatMessageEntity> build() => [];

  void addUserMessage(String text) {
    state = [
      ...state,
      ChatMessageEntity(text: text, isUser: true, timestamp: DateTime.now()),
    ];
  }

  Future<void> send(String message) async {
    if (message.trim().isEmpty) return;

    addUserMessage(message);
    _isLoading = true;

    try {
      final useCase = ref.read(sendMessageProvider);
      final response = await useCase.call(message.trim());
      _isLoading = false;
      state = [
        ...state,
        ChatMessageEntity(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    } on DioException catch (e) {
      _isLoading = false;
      final msg = e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout
          ? 'El servidor tardo mucho en responder. Intenta de nuevo.'
          : e.type == DioExceptionType.connectionError
              ? 'No se pudo conectar con el asistente. Verifica que el servidor este activo.'
              : 'Error del servidor: ${e.response?.statusCode ?? ""} ${e.message ?? ""}';
      state = [
        ...state,
        ChatMessageEntity(
          text: msg.trim(),
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    } catch (e) {
      _isLoading = false;
      state = [
        ...state,
        ChatMessageEntity(
          text: 'Error inesperado: $e',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];
    }
  }
}

final chatProvider =
    NotifierProvider<ChatNotifier, List<ChatMessageEntity>>(ChatNotifier.new);

final chatLoadingProvider = Provider<bool>((ref) {
  return ref.watch(chatProvider.notifier).isLoading;
});
