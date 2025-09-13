class PickupModel {
  final int id;
  final String? name;
  final String? address;

  PickupModel({
    required this.id,
    this.name,
    required this.address

  });

  factory PickupModel.fromJson(Map<String, dynamic> json) {
    return PickupModel(
      id: json['id'],
      name: json['name'] ?? json['address'] ?? "",
      address: json['address'] ?? "",

    );
  }
}
