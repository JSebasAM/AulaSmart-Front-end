import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository repository;

  SendMessage(this.repository);

  Future<String> call(String message) async {
    return repository.sendMessage(message);
  }
}
