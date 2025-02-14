import 'package:odoosaleapp/models/invoice/BillsResponseModel.dart';

class InvoiceApiResponseModel {
  final int totalCount;
  final List<InvoiceResponseModel> bills;

  InvoiceApiResponseModel({
    required this.totalCount,
    required this.bills,

  });

  factory InvoiceApiResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceApiResponseModel(
        totalCount: json['TotalCount'],
        bills: (json['BillList'] as List<dynamic>)
          .map((item) => InvoiceResponseModel.fromJson(item))
          .toList(),
    );
  }
}