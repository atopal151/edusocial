import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

class ApiService extends GetxService {
  late dio.Dio _dio;
  
  @override
  void onInit() {
    super.onInit();
    _dio = dio.Dio(dio.BaseOptions(
      baseUrl: 'https://stageapi.edusocial.pl/mobile',
      connectTimeout: const Duration(seconds: 60), // 30'dan 60'a çıkarıldı
      receiveTimeout: const Duration(seconds: 60), // 30'dan 60'a çıkarıldı
    ));
  }

  Future<dio.Response> get(String path, {Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.get(path, options: dio.Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dio.Response> post(String path, dynamic data, {Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.post(path, data: data, options: dio.Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dio.Response> put(String path, dynamic data, {Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.put(path, data: data, options: dio.Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<dio.Response> delete(String path, {Map<String, dynamic>? headers}) async {
    try {
      final response = await _dio.delete(path, options: dio.Options(headers: headers));
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
