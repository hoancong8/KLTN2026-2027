class SettingsState {
  final bool isLoading;
  final String? error;

  const SettingsState({
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
