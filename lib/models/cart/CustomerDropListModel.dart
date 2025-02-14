class CustomerDropListModel {
  final int id;
  final int priceListId;
  final String name;
  final double credit;
  final String? contactAddress;
  final String? phone;
  final String? vat;
  final int xFrequency;
  final String? partnerLatitude;
  final String? partnerLongitude;
  final String? xPartnerCode;

  CustomerDropListModel({
    required this.id,
    required this.priceListId,
    required this.name,
    required this.credit,
    required this.contactAddress,
    required this.phone,
    required this.vat,
    required this.xFrequency,
    required this.partnerLatitude,
    required this.partnerLongitude,
    required this.xPartnerCode,
  });

  factory CustomerDropListModel.fromJson(Map<String, dynamic> json) {
    return CustomerDropListModel(
      id: json['id'],
      priceListId: json['price_list_id'],
      name: json['name'],
      credit: json['credit'],
      contactAddress: json['contact_address'],
      phone: json['phone'],
      vat: json['vat'],
      xFrequency: json['x_frequency'],
      partnerLatitude: json['partner_latitude'],
      partnerLongitude: json['partner_longitude'],
      xPartnerCode: json['x_partner_code'],
    );
  }
}
