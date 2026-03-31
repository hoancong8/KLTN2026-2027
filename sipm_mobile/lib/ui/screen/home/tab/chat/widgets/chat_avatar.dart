import 'package:flutter/material.dart';
import 'package:sipm_mobile/app/consts/app_colcor.dart';

class ChatAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final String? imageUrl;
  final bool isOnline;

  const ChatAvatar({
    super.key,
    required this.name,
    this.radius = 22,
    this.imageUrl,
    this.isOnline = false,
  });

  Color _getAvatarColor(String name) {
    final colors = [
      AppColor.cMain,
      AppColor.cBlue,
      AppColor.cYanPrimary,
      AppColor.cMainApp,
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFFFF5722),
      const Color(0xFF795548),
    ];
    final index = name.isNotEmpty ? name.codeUnitAt(0) % colors.length : 0;
    return colors[index];
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _getAvatarColor(name);

    return Stack(
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            color: imageUrl == null ? avatarColor.withValues(alpha: 0.15) : null,
            shape: BoxShape.circle,
            border: Border.all(
              color: avatarColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: imageUrl != null
              ? ClipOval(
            child: Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitial(avatarColor),
            ),
          )
              : _buildInitial(avatarColor),
        ),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.45,
              height: radius * 0.45,
              decoration: BoxDecoration(
                color: AppColor.cMain,
                shape: BoxShape.circle,
                border: Border.all(color: AppColor.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInitial(Color color) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.55,
          color: color,
        ),
      ),
    );
  }
}
