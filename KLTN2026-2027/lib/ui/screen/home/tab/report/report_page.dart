import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/widgets/report_mobile.dart';
import 'package:kltn2026_2027/ui/screen/home/tab/report/widgets/report_tablet.dart';
import 'package:kltn2026_2027/widget/responsive_layout.dart';
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
        child: ResponsiveLayout(
          mobile: ReportMobile(
            state: state,
            onRefresh: () async {
              await ref.read(reportViewModelProvider.notifier).loadData();
            },
          ),
          tablet: ReportTablet(
            state: state,
            onRefresh: () async {
              await ref.read(reportViewModelProvider.notifier).loadData();
            },
          ),
        ));
  }
}
