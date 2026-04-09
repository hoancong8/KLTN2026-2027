import 'package:flutter/material.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;
  final VoidCallback? onAttachImage;
  final VoidCallback? onAttachFile;

  const MessageInput({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
    this.onAttachImage,
    this.onAttachFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColor.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: AppColor.cGray_50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColor.cDivider),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: TextStyle(color: AppColor.cTitle, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: TextStyle(
                            color: AppColor.cMuted,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => onSend(),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: AppColor.cMuted,
                        size: 22,
                      ),
                      onPressed: () => _showAttachMenu(context),
                      padding: const EdgeInsets.only(right: 4),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            GestureDetector(
              onTap: isSending ? null : onSend,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: isSending ? AppColor.cMuted : AppColor.cMain,
                  shape: BoxShape.circle,
                  boxShadow: isSending
                      ? null
                      : [
                          BoxShadow(
                            color: AppColor.cMain.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: isSending
                    ? Padding(
                        padding: const EdgeInsets.all(13),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColor.white,
                          ),
                        ),
                      )
                    : Icon(Icons.send_rounded, color: AppColor.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMenuItem(
                context,
                icon: Icons.image,
                label: 'Thư viện ảnh',
                onTap: () {
                  Navigator.pop(ctx);
                  onAttachImage?.call();
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.insert_drive_file,
                label: 'Tệp tin',
                onTap: () {
                  Navigator.pop(ctx);
                  onAttachFile?.call();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColor.cMain.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColor.cMain),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColor.cTitle,
        ),
      ),
      onTap: onTap,
    );
  }
}
