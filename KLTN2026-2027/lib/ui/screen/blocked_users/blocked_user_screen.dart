import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kltn2026_2027/app/provider/localization_provider.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/chat/widgets/chat_avatar.dart';
import '../../../app/consts/app_color.dart';
import 'blocked_user_vm.dart';

class BlockedUsersScreen extends ConsumerStatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  ConsumerState<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends ConsumerState<BlockedUsersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blockedUsersViewModelProvider.notifier).loadBlockedUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blockedUsersViewModelProvider);

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
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.chat_blocked_list,
          style: TextStyle(
            color: AppColor.cTitle,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
              ),
            )
          : state.blockedUsers.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.block, size: 48, color: AppColor.cMuted),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.chat_no_blocked_users,
                    style: TextStyle(color: AppColor.cMuted, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.blockedUsers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final user = state.blockedUsers[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.cGray_50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ChatAvatar(name: user.userName, radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColor.cTitle,
                              ),
                            ),
                            if (user.tenancyName != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                user.tenancyName!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColor.cMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(blockedUsersViewModelProvider.notifier)
                              .unblockUser(user.userId, user.tenantId);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColor.cMain,
                        ),
                        child: Text(context.l10n.chat_unblock),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
