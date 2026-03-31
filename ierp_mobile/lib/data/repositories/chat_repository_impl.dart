import '../../domain/entities/chat_friend.dart';
import '../../domain/entities/chat_upload_result.dart';
import '../../domain/entities/user_lookup.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/repositories/token_storage_repository.dart';
import '../datasource/remote/abstract/chat_remote_datasource.dart';
import '../mapper/chat_mapper.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDatasource remoteDatasource;
  final TokenStorageRepository tokenStorageRepository;

  ChatRepositoryImpl(this.remoteDatasource, this.tokenStorageRepository);

  @override
  Future<List<ChatFriend>> getChatFriends() async {
    final response = await remoteDatasource.getChatFriends();
    return ChatMapper.toEntityList(response.friends);
  }

  @override
  Future<void> blockUser(int userId, int? tenantId) async {
    final effectiveTenantId =
        tenantId ?? await tokenStorageRepository.getTenantId();
    await remoteDatasource.blockUser(userId, effectiveTenantId);
  }

  @override
  Future<void> unblockUser(int userId, int? tenantId) async {
    final effectiveTenantId =
        tenantId ?? await tokenStorageRepository.getTenantId();
    await remoteDatasource.unblockUser(userId, effectiveTenantId);
  }

  @override
  Future<ChatUploadResult> uploadFile(String filePath, String fileName) async {
    final response = await remoteDatasource.uploadFile(filePath, fileName);
    return ChatUploadResult(
      id: response.result.id,
      name: response.result.name,
      contentType: response.result.contentType,
    );
  }

  @override
  Future<List<UserLookup>> findUsers(
      String filter,
      int maxResultCount,
      int skipCount,
      ) async {
    final response = await remoteDatasource.findUsers(
      filter,
      maxResultCount,
      skipCount,
    );
    return response.result.items
        .map(
          (dto) =>
          UserLookup(name: dto.name, userId: int.tryParse(dto.value) ?? 0),
    )
        .toList();
  }

  @override
  Future<void> createFriendshipRequest(int userId, int? tenantId) async {
    final effectiveTenantId =
        tenantId ?? await tokenStorageRepository.getTenantId();
    await remoteDatasource.createFriendshipRequest(userId, effectiveTenantId);
  }
}