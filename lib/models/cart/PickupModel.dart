class PickupModel {
  final int id;
  final String? address;

  PickupModel({
    required this.id,
    required this.address

  });

  factory PickupModel.fromJson(Map<String, dynamic> json) {
    return PickupModel(
      id: json['id'],
      address: json['address'] ?? "",

    );
  }
}
