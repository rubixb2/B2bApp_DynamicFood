class VersionCheckRequestModel {
  final String appKey;
  final String osSystem;
  final int version;

  VersionCheckRequestModel({
    required this.appKey,
    required this.osSystem,
    required this.version,
  });

  Map<String, dynamic> toJson() {
    return {
      'AppKey': appKey,
      'OsSystem': osSystem,
      'Version': version,
    };
  }
}
