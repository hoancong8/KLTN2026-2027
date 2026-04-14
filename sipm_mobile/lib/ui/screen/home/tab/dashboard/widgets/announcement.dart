import 'package:flutter/material.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';

class AnnouncementWidget extends StatelessWidget {
  const AnnouncementWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final announcements = _getMockAnnouncements();

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.cDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.cMain,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_outlined,
                    color: AppColor.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thông báo chung',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColor.cTitle,
                            ),
                      ),
                      Text(
                        '${announcements.length} thông báo mới',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: AppColor.cMuted),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: AppColor.cMain),
                  child: const Text('Xem tất cả'),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColor.cDivider),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: announcements.length > 3 ? 3 : announcements.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColor.cDivider),
            itemBuilder: (context, index) {
              final item = announcements[index];
              return _AnnouncementItem(announcement: item);
            },
          ),
        ],
      ),
    );
  }

  List<_AnnouncementData> _getMockAnnouncements() {
    return [
      _AnnouncementData(
        title: 'Lịch nghỉ Tết Nguyên Đán 2025',
        content: 'Công ty thông báo lịch nghỉ Tết từ 27/01 đến 03/02/2025',
        time: '2 giờ trước',
        isImportant: true,
        icon: Icons.event,
      ),
      _AnnouncementData(
        title: 'Cập nhật chính sách bảo hiểm',
        content: 'Áp dụng chính sách bảo hiểm mới từ tháng 2/2025',
        time: '1 ngày trước',
        isImportant: false,
        icon: Icons.health_and_safety,
      ),
      _AnnouncementData(
        title: 'Team building Q1/2025',
        content: 'Đăng ký tham gia team building tại Đà Nẵng',
        time: '2 ngày trước',
        isImportant: false,
        icon: Icons.groups,
      ),
    ];
  }
}

class _AnnouncementData {
  final String title;
  final String content;
  final String time;
  final bool isImportant;
  final IconData icon;

  _AnnouncementData({
    required this.title,
    required this.content,
    required this.time,
    required this.isImportant,
    required this.icon,
  });
}

class _AnnouncementItem extends StatelessWidget {
  final _AnnouncementData announcement;

  const _AnnouncementItem({required this.announcement});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.cMain.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(announcement.icon, size: 20, color: AppColor.cMain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (announcement.isImportant) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColor.cMain,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Quan trọng',
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          announcement.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColor.cTitle,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColor.cMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    announcement.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColor.cMuted.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColor.cMuted.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}
