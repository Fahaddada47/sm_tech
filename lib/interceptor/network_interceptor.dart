import 'package:dio/dio.dart' as dio;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sm_task/interceptor/network_response.dart';

class NetworkCaller {
  static final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    connectTimeout: const Duration(seconds: 300),
    receiveTimeout: const Duration(seconds: 300),
  ))
    ..interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
    ));

  static Future<NetworkResponse> getRequest(String path,
      {Map<String, dynamic>? queryParams,}) async {
    return _handleRequest(
          () async => _dio.get(
        path,
        queryParameters: queryParams,
        options: dio.Options(),
      ),
    );
  }



  static Future<NetworkResponse> _handleRequest(
      Future<dio.Response> Function() request) async {
    try {
      final dio.Response response = await request();

      final int statusCode = response.statusCode ?? -1;

      if (statusCode == 200) {
        return NetworkResponse.success(response.data, statusCode);
      } else if (statusCode == 401) {
        return NetworkResponse.failure('Unauthorized access', statusCode);
      } else {
        return NetworkResponse.failure(
          response.statusMessage ?? 'Request failed',
          statusCode,
        );
      }
    } catch (e) {
      if (e is dio.DioException) {
        return NetworkResponse.failure(e.message.toString(), e.response?.statusCode ?? -1);
      } else {
        return NetworkResponse.failure('An unexpected error occurred');
      }
    }
  }
}
