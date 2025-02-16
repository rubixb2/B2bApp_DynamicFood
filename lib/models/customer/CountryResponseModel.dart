class CountryResponseModel {
  final int id;
  final String countryName;

  CountryResponseModel({required this.id, required this.countryName});

  factory CountryResponseModel.fromJson(Map<String, dynamic> json) {
    return CountryResponseModel(
      id: json['Id'],
      countryName: json['CountryName'],
    );
  }
}
