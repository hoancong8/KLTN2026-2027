// lib/ui/screen/home/tab/club/widgets/club_join_by_code_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../app/theme/theme.dart';
import '../../../../club/club_vm/club_context_vm.dart';

class ClubJoinByCodeDialog extends ConsumerStatefulWidget {
  const ClubJoinByCodeDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => const ClubJoinByCodeDialog(),
    );
  }

  @override
  ConsumerState<ClubJoinByCodeDialog> createState() => _ClubJoinByCodeDialogState();
}

class _ClubJoinByCodeDialogState extends ConsumerState<ClubJoinByCodeDialog> {
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập mã Code của nhóm'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final vm = ref.read(clubContextViewModelProvider.notifier);
    final ok = await vm.joinClub(
      clubCode: code,
      nickname: _nicknameController.text.trim().isNotEmpty ? _nicknameController.text.trim() : null,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tham gia câu lạc bộ thành công!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      final err = ref.read(clubContextViewModelProvider).error?.message ?? 'Tham gia thất bại, kiểm tra lại mã Code.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      title: Row(
        children: [
          const Icon(Icons.tag_rounded, color: AppColors.roleSky),
          AppSpacing.gapW8,
          Text('Tham Gia Bằng Mã Code', style: AppTypography.titleLarge.bold),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: AppSpacing.allMd,
              decoration: BoxDecoration(
                color: AppColors.successContainer,
                borderRadius: AppRadius.borderMd,
                border: Border.all(color: AppColors.successBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.roleTeal, size: AppSpacing.iconSm),
                  AppSpacing.gapW8,
                  Expanded(
                    child: Text(
                      'Nhập mã bí mật do Chủ nhiệm nhóm chia sẻ để vào CLB ngay mà không cần chờ duyệt.',
                      style: AppTypography.bodySmall.colored(AppColors.roleTeal),
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapH16,
            Text('Mã Câu Lạc Bộ *', style: AppTypography.labelMedium.bold.colored(AppColors.textPrimary)),
            AppSpacing.gapH8,
            TextField(
              controller: _codeController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Ví dụ: CLB-LEGENDS7',
                hintStyle: AppTypography.bodyMedium.colored(AppColors.textMuted),
                prefixIcon: const Icon(Icons.key_rounded, size: AppSpacing.iconSm, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: const OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
                contentPadding: AppSpacing.allMd,
              ),
            ),
            AppSpacing.gapH12,
            Text('Biệt danh trong nhóm (Tùy chọn)', style: AppTypography.labelMedium.bold.colored(AppColors.textPrimary)),
            AppSpacing.gapH8,
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                hintText: 'Tên bạn bè hay gọi trên sân',
                hintStyle: AppTypography.bodyMedium.colored(AppColors.textMuted),
                prefixIcon: const Icon(Icons.badge_outlined, size: AppSpacing.iconSm, color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.background,
                border: const OutlineInputBorder(borderRadius: AppRadius.borderMd, borderSide: BorderSide.none),
                contentPadding: AppSpacing.allMd,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text('Hủy', style: AppTypography.labelLarge.colored(AppColors.textMuted)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: 0,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          ),
          onPressed: _isSubmitting ? null : _handleSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                )
              : Text('Tham Gia Ngay', style: AppTypography.labelLarge.bold.colored(AppColors.white)),
        ),
      ],
    );
  }
}
