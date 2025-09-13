import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:odoosaleapp/models/version/VersionCheckRequestModel.dart';
import 'package:odoosaleapp/models/version/VersionCheckResponseModel.dart';

class VersionService {
  static const String _baseUrl = 'https://apicontrol.nametech.be/api/Version/Check';
  
  Future<VersionCheckResponseModel?> checkVersion({
    required String appKey,
    required String osSystem,
    required int version,
  }) async {
    try {
      final request = VersionCheckRequestModel(
        appKey: appKey,
        osSystem: osSystem,
        version: version,
      );

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return VersionCheckResponseModel.fromJson(jsonData);
      } else {
        print('❌ Version check API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Version check error: $e');
      return null;
    }
  }

  // Platform detection
  String getOsSystem() {
    if (Platform.isAndroid) {
      return 'ANDROID';
    } else if (Platform.isIOS) {
      return 'IOS';
    } else {
      return 'UNKNOWN';
    }
  }

  // App version (pubspec.yaml'dan dinamik olarak al)
  Future<int> getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return int.parse(packageInfo.version.replaceAll('.', ''));
    } catch (e) {
      print('❌ Version alınamadı, default değer kullanılıyor: $e');
      return 1; // Fallback değer
    }
  }

  // App key (package name)
  Future<String> getAppKey() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.packageName;
    } catch (e) {
      print('❌ Package name alınamadı, default değer kullanılıyor: $e');
      return 'com.nametech.odoo.lezza'; // Fallback değer
    }
  }
}
