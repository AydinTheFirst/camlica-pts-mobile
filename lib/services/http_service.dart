import 'package:camlica_pts/services/toast_service.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '/main.dart';
import 'token_storage.dart';

const urlMapping = {
  "development": "https://87qpbp9f-8080.euw.devtunnels.ms/api",
  "production": "https://camlica-pts.riteknoloji.com/api",
};

String apiUrl = urlMapping["development"]!;

class HttpService {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: apiUrl, // Temel URL
  ))
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // İstek gönderilmeden önce başlıkları düzenle
          final token = await TokenStorage.getToken();
          options.headers['Authorization'] = 'Bearer $token';

          logger.d("Request [${options.method}] => PATH: ${options.path}");
          handler.next(options); // İşleme devam et
        },
        onResponse: (response, handler) {
          // Yanıt başarılı olduğunda
          logger.i(
              "Response [${response.statusCode}] => PATH: ${response.requestOptions.path}");
          handler.next(response); // İşleme devam et
        },
        onError: (error, handler) {
          // Hata durumunda
          logger.e("Error: ${error.message}");
          if (error.response != null) {
            logger.w(
                "Error Response: [${error.response?.statusCode}] => PATH: ${error.requestOptions.path}");
          }
          handler.next(error); // İşleme devam et
        },
      ),
    );

  // Error handling için yardımcı metot
  static void handleError(
    DioException error,
  ) {
    if (error.response == null) {
      return ToastService.error(
        message: "Sunucuya bağlanırken bir hata oluştu.",
      );
    }

    if (error.response!.statusCode == 401) {
      if (Get.currentRoute == "/login") return;
      Get.offAllNamed("/login");
      return;
    }

    final message = error.response!.data['message'];
    final errors = error.response!.data['errors'];

    final errorList = errors != null
        ? errors.values.toList().join("\n")
        : "Lütfen tekrar deneyin.";

    ToastService.error(title: message, message: errorList);
  }

  // API istekleri için fetcher metodu
  static Function(String endpoint) fetcher = (String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      handleError(e);
      return null;
    }
  };

  static getFile(String file) {
    return "$apiUrl/files/$file";
  }
}
