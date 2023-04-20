import 'package:dio/dio.dart';

final dio = Dio();

/// Checks if the backend is running on http://127.0.0.1:8080/
Future<bool> checkBackend() async {
  try {
    Response response = await dio.get("http://127.0.0.1:8080");
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  } catch (e) {
    return false;
  }
}

Future<Map<String, dynamic>> svdBackEnd(Map<String, dynamic> data) async {
  Response response = await dio.post("http://127.0.0.1:8080/svd", data: data);
  Map<String, dynamic> respData = response.data;
  return respData;
}
