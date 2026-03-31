class ReportState {
  final bool isLoading;
  final String? error;

  const ReportState({
    this.isLoading = false,
    this.error,
  });

  ReportState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
