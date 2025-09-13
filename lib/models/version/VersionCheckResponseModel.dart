class VersionCheckResponseModel {
  final String version;
  final int control;
  final int statusCode;
  final String message;
  final dynamic extraData;
  final VersionData? data;
  final List<dynamic> params;

  VersionCheckResponseModel({
    required this.version,
    required this.control,
    required this.statusCode,
    required this.message,
    this.extraData,
    this.data,
    required this.params,
  });

  factory VersionCheckResponseModel.fromJson(Map<String, dynamic> json) {
    return VersionCheckResponseModel(
      version: json['Version'] ?? '',
      control: json['Control'] ?? 0,
      statusCode: json['StatusCode'] ?? 0,
      message: json['Message'] ?? '',
      extraData: json['ExtraData'],
      data: json['Data'] != null ? VersionData.fromJson(json['Data']) : null,
      params: json['Params'] ?? [],
    );
  }
}

class VersionData {
  final String osSystem;
  final String? crmApi;
  final String? menuApi;
  final String? geoApi;
  final String? paymentApi;
  final String? surveyApi;
  final double version;
  final bool forceVersion;
  final String? description;
  final int merchantId;
  final bool guestLogin;

  VersionData({
    required this.osSystem,
    this.crmApi,
    this.menuApi,
    this.geoApi,
    this.paymentApi,
    this.surveyApi,
    required this.version,
    required this.forceVersion,
    this.description,
    required this.merchantId,
    required this.guestLogin,
  });

  factory VersionData.fromJson(Map<String, dynamic> json) {
    return VersionData(
      osSystem: json['OsSystem'] ?? '',
      crmApi: json['CrmApi'],
      menuApi: json['MenuApi'],
      geoApi: json['GeoApi'],
      paymentApi: json['PaymentApi'],
      surveyApi: json['SurveyApi'],
      version: (json['Version'] ?? 0.0).toDouble(),
      forceVersion: json['ForceVersion'] ?? false,
      description: json['Description'],
      merchantId: json['MerchantId'] ?? 0,
      guestLogin: json['GuestLogin'] ?? false,
    );
  }
}
