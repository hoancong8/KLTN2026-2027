import 'package:ierp_mobile/domain/entities/employee.dart';

class HomeState {
  final bool isLoading;
  final String? error;
  final bool didLogout;
  final Employee? employee;
  final bool isInitialized;

  const HomeState({
    this.isLoading = false,
    this.error,
    this.didLogout = false,
    this.employee,
    this.isInitialized = false,
  });

  HomeState copyWith({
    bool? isLoading,
    String? error,
    bool? didLogout,
    Employee? employee,
    bool? isInitialized,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      didLogout: didLogout ?? this.didLogout,
      employee: employee ?? this.employee,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}
