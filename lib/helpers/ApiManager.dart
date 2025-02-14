import 'dart:convert';
import 'package:http/http.dart' as http;

// GlobalResponseModel sınıfı
class GlobalResponseModel {
  String? version;
  int? control;
  int? statusCode;
  String? message;
  int? messageType;
  dynamic data;
  String? extraData;
  dynamic extraDataObj;
  List<String>? params;

  GlobalResponseModel({
    this.version,
    this.control,
    this.statusCode,
    this.message,
    this.messageType,
    this.data,
    this.extraData,
    this.extraDataObj,
    this.params,
  });

  // JSON'dan nesneye dönüşüm
  factory GlobalResponseModel.fromJson(Map<String, dynamic> json) {
    return GlobalResponseModel(
      version: json['Version'],
      control: json['Control'],
      statusCode: json['StatusCode'],
      message: json['Message'],
      messageType: json['MessageType'],
      data: json['Data'],
      extraData: json['ExtraData'],
      extraDataObj: json['ExtraDataObj'],
      params: List<String>.from(json['Params'] ?? []),
    );
  }
}

// API Yönetim Sınıfı
class ApiManager {
  final String baseUrl;

  ApiManager(this.baseUrl);

  Future<GlobalResponseModel> postRequest({
    required String endpoint,
    required Map<String, dynamic> body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return GlobalResponseModel.fromJson(jsonResponse);
      } else {
        // Hata durumunda
        return GlobalResponseModel(
          statusCode: response.statusCode,
          message: 'Error: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      // İstek sırasında bir hata oluştuğunda
      return GlobalResponseModel(
        statusCode: 500,
        message: 'Exception: $e',
      );
    }
  }
}
