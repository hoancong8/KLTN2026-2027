import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sipm_mobile/app/consts/app_color.dart';
import 'package:sipm_mobile/app/provider/localization_provider.dart';
import 'package:sipm_mobile/ui/screen/home/tab/report/report_vm/report_state.dart';
import '../report_vm/report_vm.dart';

class ReportTablet extends StatefulWidget {
  final ReportState state;
  final Future<void> Function() onRefresh;

  const ReportTablet({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  @override
  State<ReportTablet> createState() => _ReportTabletState();
}

class _ReportTabletState extends State<ReportTablet> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.cMain),
      );
    }

    if (widget.state.error != null) {
      return _buildErrorState(widget.state.error!);
    }

    return Scaffold(
      backgroundColor: AppColor.cBgr,
      body: Row(
        children: [
          // 2. Sub-menu (Danh sách các loại báo cáo)
          Container(
            width: 280,
            decoration: const BoxDecoration(
              color: AppColor.white,
              border: Border(right: BorderSide(color: AppColor.cDivider)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubMenuHeader(),
                const SizedBox(height: 16),
                _buildSubMenuItem(0, Icons.dashboard_outlined, context.l10n.dashboard),
                _buildSubMenuItem(1, Icons.bar_chart, context.l10n.revenue_report),
                _buildSubMenuItem(
                    2, Icons.pie_chart_outline,context.l10n.expense_report),
                _buildSubMenuItem(3, Icons.show_chart, context.l10n.performance_report),
              ],
            ),
          ),

          // 3. Main Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: widget.onRefresh,
              child: ListView(
                padding: const EdgeInsets.all(32),
                children: [
                  _buildContentHeader(),
                  const SizedBox(height: 32),
                  _buildReportDetailContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuHeader() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColor.cMain.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bar_chart, color: AppColor.cMain, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.report,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.cTitle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.data_statistics_and_analysis,
            style: TextStyle(fontSize: 13, color: AppColor.cMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildSubMenuItem(int index, IconData icon, String title) {
    bool isActive = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color:
              isActive ? AppColor.cMain.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColor.cMain : AppColor.cMuted,
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColor.cMain : AppColor.cTitle,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentHeader() {
    String title = context.l10n.report;
    if (_selectedIndex == 1) title = context.l10n.revenue_report;
    if (_selectedIndex == 2) title = context.l10n.expense_report;
    if (_selectedIndex == 3) title = context.l10n.performance_report;

    return Row(
      children: [
        Icon(Icons.dashboard_outlined, color: AppColor.cMuted, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColor.cBlack,
          ),
        ),
      ],
    );
  }

  Widget _buildReportDetailContent() {
    if (_selectedIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 2.2,
            children: [
              _buildStatCard(
                  Icons.trending_up, '0', context.l10n.revenue, AppColor.cMain),
              _buildStatCard(
                  Icons.receipt_long, '0', context.l10n.orders, AppColor.cBlue),
              _buildStatCard(
                  Icons.people_alt, '0', context.l10n.client, AppColor.cYanPrimary),
              _buildStatCard(
                  Icons.inventory_2, '0', context.l10n.products, AppColor.cMainApp),
            ],
          ),
        ],
      );
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColor.cDivider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(Icons.hourglass_empty,
                size: 24, color: AppColor.cMuted.withOpacity(0.5)),
            const SizedBox(height: 20),
            Text(
              context.l10n.this_feature_is_under_development,
              style: TextStyle(fontSize: 18, color: AppColor.cMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColor.cDivider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColor.cTitle,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontSize: 15, color: AppColor.cMuted),
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, color: AppColor.cDivider, size: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: AppColor.cError, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: AppColor.cError)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                widget.onRefresh,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}
