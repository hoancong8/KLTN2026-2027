import '../../app/consts/app_messages.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasource/remote/abstract/auth_2fa_remote_datasource.dart';
import '../datasource/remote/abstract/auth_remote_datasource.dart';
import '../dto/auth/change_password_request_dto.dart';
import '../dto/auth/login_request_dto.dart';
import '../dto/auth/otp_login_request_dto.dart';
import '../mapper/auth_mapper.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remote;
  final Auth2FARemoteDatasource auth2faRemote;

  AuthRepositoryImpl(this.remote, this.auth2faRemote);

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    try {
      final dto = LoginRequestDto(
        userNameOrEmailAddress: username,
        password: password,
      );

      final res = await remote.login(dto);

      if (res.requiresTwoFactorVerification) {
        throw RequiresTwoFactorException();
      }

      return AuthMapper.toEntity(res);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final success = await remote.changePassword(
        ChangePasswordRequestDto(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );

      if (!success) {
        throw ChangePasswordFailedException();
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ChangePasswordFailedException(AppMessages.unauthorized);
      }

      throw ChangePasswordFailedException();
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remote.logout();
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }


  @override
  Future<AuthToken> loginWithOtp({required String username,
    required String password, required String code}) async {
    try {
      final res = await auth2faRemote.loginWithOtp(
        OtpLoginRequestDto(
          username: username,
          password: password,
          code: code,
        ),
      );

      return AuthMapper.toEntity(res);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<void> sendOtp({required String provider}) async {
    try {
      return await auth2faRemote.sendOtp(provider: provider);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  @override
  Future<AuthToken> refreshToken(String refreshToken) async {
    try {
      final res = await remote.refreshToken(refreshToken);
      return AuthMapper.toEntity(res);
    } on DioException catch (e) {
      _handleDioException(e);
    }
  }

  Never _handleDioException(DioException e) {
    if (e.type == DioExceptionType.cancel) {
      throw SessionExpiredException();
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    String? message;

    if (data is Map) {
      final err = data['error'];
      if (err is Map) {
        message = err['message']?.toString();
      }
      message ??= data['message']?.toString();
    } else if (data is String) {
      message = data;
    } else if (data is List) {
      message = data.isNotEmpty ? data.first.toString() : null;
    }

    message ??= e.message;

    if (message == 'RequiresTwoFactorAuthentication') {
      throw RequiresTwoFactorException();
    }
    switch (statusCode) {
      case 401:
        throw AuthFailedException(message ?? AppMessages.unauthorized);
      case 403:
        throw AuthFailedException(message ?? AppMessages.forbidden);
      case 404:
        throw AuthFailedException(message ?? AppMessages.notFound);
      case 500:
        throw AuthFailedException(message ?? AppMessages.serverError);
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          throw AuthFailedException(AppMessages.connectionTimeout);
        } else if (e.type == DioExceptionType.receiveTimeout) {
          throw AuthFailedException(AppMessages.receiveTimeout);
        } else if (e.type == DioExceptionType.connectionError) {
          throw AuthFailedException(AppMessages.networkError);
        }
        throw AuthFailedException(message ?? AppMessages.unknownError);
    }
  }
}
