import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import '../../../app/consts/app_color.dart';
import 'add_friend_vm.dart';

class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addFriendViewModelProvider);

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        backgroundColor: AppColor.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: AppColor.cTitle,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.l10n.chat_add_friend,
          style: TextStyle(
            color: AppColor.cTitle,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                ref
                    .read(addFriendViewModelProvider.notifier)
                    .searchUsers(value);
              },
              decoration: InputDecoration(
                hintText: context.l10n.chat_search_friend_hint,
                hintStyle: TextStyle(color: AppColor.cMuted),
                prefixIcon: Icon(Icons.search, color: AppColor.cMuted),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColor.cMuted),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(addFriendViewModelProvider.notifier)
                              .searchUsers('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColor.cGray_50,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColor.cMain, width: 1),
                ),
              ),
            ),
          ),

          // Results
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(AddFriendState state) {
    if (_searchController.text.trim().isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: AppColor.cMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.chat_enter_name_or_email_to_search,
              style: TextStyle(color: AppColor.cMuted, fontSize: 15),
            ),
          ],
        ),
      );
    }

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColor.cError, size: 48),
              const SizedBox(height: 12),
              Text(
                state.error!,
                style: TextStyle(color: AppColor.cError, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(addFriendViewModelProvider.notifier)
                      .searchUsers(_searchController.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.cMain,
                  foregroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.com_retry),
              ),
            ],
          ),
        ),
      );
    }

    if (state.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined, size: 48, color: AppColor.cMuted),
            const SizedBox(height: 12),
            Text(
              context.l10n.chat_no_user_found,
              style: TextStyle(color: AppColor.cMuted, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: state.users.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = state.users[index];
        final isAdding = state.addingUserIds.contains(user.userId);
        final isAdded = state.addedUserIds.contains(user.userId);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColor.cGray_50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColor.cMain.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _getInitials(user.name),
                    style: TextStyle(
                      color: AppColor.cMain,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Name
              Expanded(
                child: Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColor.cTitle,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Add button
              if (isAdded)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColor.cGreen_50.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: AppColor.cGreen_50, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        context.l10n.chat_already_added,
                        style: TextStyle(
                          color: AppColor.cGreen_50,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isAdding)
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () async {
                    final success = await ref
                        .read(addFriendViewModelProvider.notifier)
                        .addFriend(user.userId);

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? context.l10n.chat_add_success(user.name)
                              : context.l10n.chat_add_error,
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: success
                            ? AppColor.cMain
                            : AppColor.cError,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.cMain,
                    foregroundColor: AppColor.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    context.l10n.com_add,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    // name format: "FullName (email)" — extract first part
    final displayName = name.contains('(')
        ? name.substring(0, name.indexOf('(')).trim()
        : name;
    final parts = displayName.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
