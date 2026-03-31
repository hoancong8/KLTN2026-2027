import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sipm_mobile/domain/entities/user_lookup.dart';
import 'package:sipm_mobile/app/provider.dart';

import '../../../domain/usecases/friend/create_friendship_request_usecase.dart';
import '../../../domain/usecases/friend/find_users_usecase.dart';

class AddFriendState {
  final bool isLoading;
  final List<UserLookup> users;
  final String? error;
  final Set<int> addingUserIds;
  final Set<int> addedUserIds;

  const AddFriendState({
    this.isLoading = false,
    this.users = const [],
    this.error,
    this.addingUserIds = const {},
    this.addedUserIds = const {},
  });

  AddFriendState copyWith({
    bool? isLoading,
    List<UserLookup>? users,
    String? error,
    Set<int>? addingUserIds,
    Set<int>? addedUserIds,
  }) {
    return AddFriendState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      error: error,
      addingUserIds: addingUserIds ?? this.addingUserIds,
      addedUserIds: addedUserIds ?? this.addedUserIds,
    );
  }
}

final addFriendViewModelProvider =
StateNotifierProvider.autoDispose<AddFriendViewModel, AddFriendState>((
    ref,
    ) {
  return AddFriendViewModel(
    findUsersUseCase: ref.watch(findUsersUseCaseProvider),
    createFriendshipRequestUseCase: ref.watch(
      createFriendshipRequestUseCaseProvider,
    ),
  );
});

class AddFriendViewModel extends StateNotifier<AddFriendState> {
  final FindUsersUseCase findUsersUseCase;
  final CreateFriendshipRequestUseCase createFriendshipRequestUseCase;
  Timer? _debounceTimer;

  AddFriendViewModel({
    required this.findUsersUseCase,
    required this.createFriendshipRequestUseCase,
  }) : super(const AddFriendState());

  void searchUsers(String filter) {
    _debounceTimer?.cancel();

    if (filter.trim().isEmpty) {
      state = state.copyWith(isLoading: false, users: [], error: null);
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final users = await findUsersUseCase.execute(filter.trim());
        if (!mounted) return;
        state = state.copyWith(isLoading: false, users: users);
      } catch (e) {
        if (!mounted) return;
        state = state.copyWith(
          isLoading: false,
          error: 'Không thể tìm kiếm. Vui lòng thử lại.',
        );
      }
    });
  }

  Future<bool> addFriend(int userId) async {
    state = state.copyWith(addingUserIds: {...state.addingUserIds, userId});

    try {
      await createFriendshipRequestUseCase.execute(userId, null);
      if (!mounted) return false;
      state = state.copyWith(
        addingUserIds: {...state.addingUserIds}..remove(userId),
        addedUserIds: {...state.addedUserIds, userId},
      );
      return true;
    } catch (e) {
      if (!mounted) return false;
      state = state.copyWith(
        addingUserIds: {...state.addingUserIds}..remove(userId),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
