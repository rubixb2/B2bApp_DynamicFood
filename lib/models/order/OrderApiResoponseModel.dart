import 'package:odoosaleapp/models/order/OrdersResponseModel.dart';

class OrderApiResponseModel {
  final int totalCount;
  final List<OrdersResponseModel> orders;

  OrderApiResponseModel({
    required this.totalCount,
    required this.orders,

  });

  factory OrderApiResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderApiResponseModel(
        totalCount: json['TotalCount'],
        orders: (json['OrdersList'] as List<dynamic>)
          .map((item) => OrdersResponseModel.fromJson(item))
          .toList(),
    );
  }
}