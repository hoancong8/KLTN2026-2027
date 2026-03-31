import '../../entities/chat_friend.dart';
import '../../repositories/chat_repository.dart';

class GetChatFriendsUseCase {
  final ChatRepository repository;

  GetChatFriendsUseCase(this.repository);

  Future<List<ChatFriend>> execute() {
    return repository.getChatFriends();
  }
}