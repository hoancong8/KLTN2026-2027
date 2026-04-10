import 'package:dio/dio.dart';
import '../../../app/utils/app_exception_handler.dart';
import '../../../domain/exceptions/app_exception.dart';
import '../../../domain/exceptions/auth_exceptions.dart';

abstract class BaseRemoteDatasource {
  /// Bóc tách dữ liệu từ trường 'result' của ABP Framework.
  /// Hỗ trợ cả trường hợp kết quả là Object đơn lẻ.
  T handleResponse<T>(Response response, T Function(dynamic) fromJson) {
    final data = response.data;

    // 1. Kiểm tra an toàn bảo mật (HTML response)
    checkSecurity(data);

    if (data is Map<String, dynamic>) {
      // ABP thường bọc data trong trường 'result'
      if (data.containsKey('result')) {
        final result = data['result'];
        if (result == null) {
          return null as T; 
        }
        return fromJson(result);
      }
      // Nếu không có result field, parse trực tiếp từ data
      return fromJson(data);
    }

    // Fallback cho các kiểu dữ liệu primitive (String, int...)
    if (data is T) return data;

    throw const InvalidResponseException();
  }

  /// Bóc tách danh sách từ trường 'result' -> 'items' (PagedResult của ABP).
  List<T> handleListResponse<T>(Response response, T Function(dynamic) fromJson) {
    final data = response.data;

    checkSecurity(data);

    if (data is Map<String, dynamic>) {
      final result = data['result'] ?? data;
      if (result is Map<String, dynamic> && result['items'] is List) {
        final items = result['items'] as List;
        return items.map((item) => fromJson(item)).toList();
      }
      // Trường hợp result chính là mảng items
      if (result is List) {
        return result.map((item) => fromJson(item)).toList();
      }
    }

    return [];
  }

  /// Hàm tiện ích giúp chuẩn hóa lỗi ngay tại Datasource.
  AppException handleError(Object e) => AppExceptionHandler.handle(e);

  /// Kiểm tra nếu Server trả về trang HTML (thường do session expired hoặc lỗi server cấu hình sai).
  void checkSecurity(dynamic data) {
    if (data is String && data.contains('<!DOCTYPE html>')) {
      throw SessionExpiredException();
    }
  }
}
