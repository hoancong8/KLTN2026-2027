import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'report_vm/report_vm.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reportViewModelProvider.notifier).loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportViewModelProvider);

    if (state.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColor.cMain),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColor.cError.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: AppColor.cError,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: TextStyle(color: AppColor.cError),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(reportViewModelProvider.notifier).loadData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.cMain,
                foregroundColor: AppColor.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColor.cMain,
      backgroundColor: AppColor.white,
      onRefresh: () async {
        await ref.read(reportViewModelProvider.notifier).loadData();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSectionTitle(context, 'Tổng quan', Icons.dashboard_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.trending_up,
                  value: '0',
                  label: 'Doanh thu',
                  color: AppColor.cMain,
                  onTap: () => _showComingSoon(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.receipt_long_outlined,
                  value: '0',
                  label: 'Đơn hàng',
                  color: AppColor.cBlue,
                  onTap: () => _showComingSoon(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people_outline,
                  value: '0',
                  label: 'Khách hàng',
                  color: AppColor.cYanPrimary,
                  onTap: () => _showComingSoon(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.inventory_2_outlined,
                  value: '0',
                  label: 'Sản phẩm',
                  color: AppColor.cMainApp,
                  onTap: () => _showComingSoon(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(
            context,
            'Báo cáo chi tiết',
            Icons.analytics_outlined,
          ),
          const SizedBox(height: 12),
          _buildReportItem(
            icon: Icons.bar_chart,
            title: 'Báo cáo doanh thu',
            subtitle: 'Thống kê doanh thu theo thời gian',
            color: AppColor.cMain,
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 12),
          _buildReportItem(
            icon: Icons.pie_chart_outline,
            title: 'Báo cáo chi phí',
            subtitle: 'Phân tích chi phí hoạt động',
            color: AppColor.cBlue,
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 12),
          _buildReportItem(
            icon: Icons.show_chart,
            title: 'Báo cáo hiệu suất',
            subtitle: 'Đánh giá hiệu suất công việc',
            color: AppColor.cYanPrimary,
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tính năng đang được phát triển'),
        backgroundColor: AppColor.cMain,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColor.cMain.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.bar_chart, color: AppColor.cMain, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Báo cáo',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColor.cTitle,
                ),
              ),
              Text(
                'Báo cáo tổng hợp và phân tích',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColor.cMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.cMain.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColor.cMain, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColor.cTitle,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.cDivider),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColor.cTitle,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: AppColor.cMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColor.cDivider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColor.cTitle,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: AppColor.cMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColor.cMuted),
          ],
        ),
      ),
    );
  }
}
