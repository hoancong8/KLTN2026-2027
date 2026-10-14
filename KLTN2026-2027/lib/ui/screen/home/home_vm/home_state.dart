class HomeState {
  final bool isLoading;
  final String? error;
  final bool didLogout;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.didLogout = false,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    bool? didLogout,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      didLogout: didLogout ?? this.didLogout,
    );
  }
}
