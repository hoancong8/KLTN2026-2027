// lib/widget/keep_alive_wrapper.dart

import 'package:flutter/material.dart';

/// Widget wrapper để giữ trạng thái cho các page trong PageView hoặc TabBarView,
/// tránh bị unmount và mất dữ liệu khi chuyển qua lại giữa các tab.
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({
    super.key,
    required this.child,
  });

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

