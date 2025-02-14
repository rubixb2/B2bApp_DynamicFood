class PaymentLineTypeResponseModel {
  final List<PaymentMethod> PaymentTypeList;

  PaymentLineTypeResponseModel({required this.PaymentTypeList});

  factory PaymentLineTypeResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentLineTypeResponseModel(
      PaymentTypeList: (json['PaymentTypeList'] as List)
          .map((item) => PaymentMethod.fromJson(item))
          .toList(),
    );
  }
}

class PaymentMethod {
  final int id;
  final String name;

  PaymentMethod({required this.id, required this.name});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['key'],
      name: json['value'],
    );
  }
}