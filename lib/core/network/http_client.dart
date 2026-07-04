import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class HttpClient {
  HttpClient({Dio? dio})
      : dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio dio;

  void configure({required String baseUrl}) {
    dio.options.baseUrl = baseUrl;
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: true,
        ),
      );
    }
  }
}
