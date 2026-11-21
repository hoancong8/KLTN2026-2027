import 'dart:typed_data';
import '../../../../domain/entities/payment/personal_fee.dart';
import '../../../../domain/exceptions/app_exception.dart';

class FeeDetailState {
  final PersonalFee? fee;
  final Uint8List? qrBytes;
  final bool isLoading;
  final bool isQrLoading;
  final bool isOperating;
  final AppException? error;
  final AppException? qrError;
  final String? successMessage;

  const FeeDetailState({
    this.fee,
    this.qrBytes,
    this.isLoading = false,
    this.isQrLoading = false,
    this.isOperating = false,
    this.error,
    this.qrError,
    this.successMessage,
  });

  FeeDetailState copyWith({
    PersonalFee? fee,
    Uint8List? qrBytes,
    bool clearQr = false,
    bool? isLoading,
    bool? isQrLoading,
    bool? isOperating,
    AppException? error,
    bool clearError = false,
    AppException? qrError,
    bool clearQrError = false,
    String? successMessage,
    bool clearSuccess = false,
  }) => FeeDetailState(
    fee: fee ?? this.fee,
    qrBytes: clearQr ? null : qrBytes ?? this.qrBytes,
    isLoading: isLoading ?? this.isLoading,
    isQrLoading: isQrLoading ?? this.isQrLoading,
    isOperating: isOperating ?? this.isOperating,
    error: clearError ? null : error ?? this.error,
    qrError: clearQrError ? null : qrError ?? this.qrError,
    successMessage: clearSuccess ? null : successMessage ?? this.successMessage,
  );
}
