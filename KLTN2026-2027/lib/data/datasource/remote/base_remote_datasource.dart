import 'package:dio/dio.dart';
import '../../../app/utils/app_exception_handler.dart';
import '../../../domain/exceptions/app_exception.dart';
import '../../../domain/exceptions/auth_exceptions.dart';

abstract class BaseRemoteDatasource {
  /// Bóc tách dữ liệu từ trường 'result' của ABP Framework hoặc Object JSON trực tiếp.
  /// Hỗ trợ cả trường hợp kết quả là Object đơn lẻ hoặc mảng List.
  T handleResponse<T>(Response response, T Function(dynamic) fromJson) {
    final data = response.data;

    // 1. Kiểm tra an toàn bảo mật (HTML response)
    checkSecurity(data);

    // 2. Trường hợp data là Map
    if (data is Map) {
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

    // 3. Trường hợp data chính là List
    if (data is List) {
      return fromJson(data);
    }

    // 4. Fallback cho các kiểu dữ liệu primitive (String, int...)
    if (data is T) return data;

    throw InvalidResponseException(originalError: data);
  }

  /// Bóc tách danh sách từ mảng List trực tiếp hoặc trường 'result' / 'items' (PagedResult).
  List<T> handleListResponse<T>(
    Response response,
    T Function(dynamic) fromJson,
  ) {
    final data = response.data;

    checkSecurity(data);

    // 1. Trường hợp data là JSON List trực tiếp: [ {...}, {...} ]
    if (data is List) {
      return data.map((item) => fromJson(item)).toList();
    }

    // 2. Trường hợp data là Map (bọc trong 'result' hoặc 'items')
    if (data is Map) {
      final result = data['result'] ?? data;
      if (result is List) {
        return result.map((item) => fromJson(item)).toList();
      }
      if (result is Map && result['items'] is List) {
        final items = result['items'] as List;
        return items.map((item) => fromJson(item)).toList();
      }
    }

    // Nếu data bị parse lỗi hoặc cấu trúc không khớp:
    throw InvalidResponseException(originalError: data);
  }

  /// Hàm tiện ích giúp chuẩn hóa lỗi ngay tại Datasource.
  AppException handleError(Object e) => AppExceptionHandler.handle(e);

  /// Kiểm tra nếu Server trả về trang HTML (thường do session expired hoặc lỗi server cấu hình sai).
  void checkSecurity(dynamic data) {
    if (data is String && data.contains('<!DOCTYPE html>')) {
      throw const SessionExpiredException();
    }
  }
}
