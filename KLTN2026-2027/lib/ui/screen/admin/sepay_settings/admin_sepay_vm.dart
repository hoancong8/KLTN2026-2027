import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../app/provider.dart';
import '../../../../domain/exceptions/app_exception.dart';
import 'admin_sepay_state.dart';

final adminSepayViewModelProvider =
    StateNotifierProvider.autoDispose<AdminSepayViewModel, AdminSepayState>((
      ref,
    ) {
      return AdminSepayViewModel(ref);
    });

class AdminSepayViewModel extends StateNotifier<AdminSepayState> {
  final Ref ref;

  AdminSepayViewModel(this.ref) : super(const AdminSepayState()) {
    loadApplication();
  }

  Future<bool> loadApplication({bool reportError = true}) async {
    state = state.copyWith(
      isLoading: true,
      clearMessages: true,
      clearApplication: true,
      isRevisionConflict: false,
    );
    try {
      final app = await ref.read(getSepayApplicationUseCaseProvider).execute();
      state = state.copyWith(
        isLoading: false,
        application: app,
        isRevisionConflict: false,
      );
      return true;
    } on AppException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: reportError ? e.message : null,
        errorMessageKey: reportError && e.message == null
            ? 'sepay_load_configuration_failed'
            : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessageKey: reportError ? 'error_system_retry' : null,
      );
      return false;
    }
  }

  Future<void> _reloadAfterRevisionConflict() async {
    final reloaded = await loadApplication(reportError: false);
    state = state.copyWith(
      isSaving: false,
      isRevisionConflict: true,
      clearMessages: reloaded,
    );
  }

  Future<bool> saveApplication({
    required String clientId,
    String? clientSecret,
    required String publicApiBaseUrl,
    required String frontendBaseUrl,
    required bool enabled,
  }) async {
    state = state.copyWith(isSaving: true, clearMessages: true);
    try {
      final currentRevision = state.application?.revision;
      final trimmedSecret = clientSecret?.trim();
      final secretToSend = (trimmedSecret != null && trimmedSecret.isNotEmpty)
          ? trimmedSecret
          : null;

      final updated = await ref
          .read(configureSepayApplicationUseCaseProvider)
          .execute(
            clientId: clientId.trim(),
            clientSecret: secretToSend,
            publicApiBaseUrl: publicApiBaseUrl.trim(),
            frontendBaseUrl: frontendBaseUrl.trim(),
            enabled: enabled,
            revision: currentRevision,
          );

      state = state.copyWith(
        isSaving: false,
        application: updated,
        isRevisionConflict: false,
        successMessageKey: 'sepay_save_configuration_succeeded',
      );
      return true;
    } on DioException catch (e) {
      final isConflict = e.response?.statusCode == 409;
      if (isConflict) {
        await _reloadAfterRevisionConflict();
        return false;
      }
      state = state.copyWith(
        isSaving: false,
        isRevisionConflict: false,
        errorMessage:
            e.response?.data is Map && e.response?.data['detail'] != null
            ? e.response?.data['detail'].toString()
            : null,
        errorMessageKey:
            e.response?.data is Map && e.response?.data['detail'] != null
            ? null
            : 'sepay_save_configuration_failed',
      );
      return false;
    } on AppException catch (e) {
      final original = e.originalError;
      if (original is DioException && original.response?.statusCode == 409) {
        await _reloadAfterRevisionConflict();
        return false;
      }
      state = state.copyWith(
        isSaving: false,
        isRevisionConflict: false,
        errorMessage: e.message,
        errorMessageKey: e.message == null
            ? 'sepay_save_configuration_failed'
            : null,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        isRevisionConflict: false,
        errorMessageKey: 'error_system_retry',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}
