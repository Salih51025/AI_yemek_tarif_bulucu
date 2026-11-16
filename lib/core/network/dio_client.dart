/// Dio HTTP client configuration for API requests.
///
/// Provides a centralized HTTP client with interceptors,
/// timeout configurations, and error handling for all
/// external API communications.
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Configured Dio client instance for making HTTP requests.
///
/// This client is pre-configured with:
/// - Connection, receive, and send timeouts
/// - Default headers for JSON content
/// - Error interceptor for exception handling
/// - Internet connectivity check before requests
class DioClient {
  final Dio _dio;
  final Connectivity _connectivity;

  /// Creates a new DioClient with optional custom Dio instance.
  DioClient([Dio? dio, Connectivity? connectivity])
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(
                  milliseconds: ApiConstants.connectionTimeoutMs),
              receiveTimeout:
                  const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
              sendTimeout:
                  const Duration(milliseconds: ApiConstants.sendTimeoutMs),
              headers: ApiConstants.defaultHeaders,
            )),
        _connectivity = connectivity ?? Connectivity() {
    _setupInterceptors();
  }

  /// Returns the underlying Dio instance.
  Dio get dio => _dio;

  /// Checks if the device has an active internet connection.
  ///
  /// Returns true if connected to a network, false otherwise.
  Future<bool> _hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // If connectivity check fails, assume no connection
      return false;
    }
  }

  /// Sets up interceptors for request/response/error handling.
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Check internet connectivity before making request
          final hasConnection = await _hasInternetConnection();
          if (!hasConnection) {
            handler.reject(DioException(
              requestOptions: options,
              error: const NetworkException(message: 'No internet connection'),
              type: DioExceptionType.connectionError,
            ));
            return;
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // Convert Dio errors to custom exceptions
          final exception = _handleDioError(error);
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: exception,
            response: error.response,
            type: error.type,
          ));
        },
      ),
    );
  }

  /// Converts Dio errors to custom application exceptions.
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(message: 'Connection timeout');
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        return ServerException(
          message: error.response?.statusMessage ?? 'Server error',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request cancelled');
      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Invalid SSL certificate');
      case DioExceptionType.unknown:
        return NetworkException(
            message: error.message ?? 'Unknown network error');
    }
  }

  /// Performs a GET request.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error ?? const NetworkException(message: 'GET request failed');
    }
  }

  /// Performs a POST request.
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error ?? const NetworkException(message: 'POST request failed');
    }
  }

  /// Performs a PUT request.
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error ?? const NetworkException(message: 'PUT request failed');
    }
  }

  /// Performs a DELETE request.
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error ?? const NetworkException(message: 'DELETE request failed');
    }
  }
}
