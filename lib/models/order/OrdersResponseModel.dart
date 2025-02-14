class OrdersResponseModel {
  final int id;
  final int cartId;
  final int partnerid;
  final String name;
  final String dateOrder;
  final String partnerName;
  final double amountTotal;
  final bool orderCompleteStatus;
  final String orderPdfUrl;
  final String invoicePdfUrl;

  OrdersResponseModel({
    required this.id,
    required this.cartId,
    required this.partnerid,
    required this.name,
    required this.dateOrder,
    required this.partnerName,
    required this.amountTotal,
    required this.orderCompleteStatus,
    required this.orderPdfUrl,
    required this.invoicePdfUrl,
  });

  factory OrdersResponseModel.fromJson(Map<String, dynamic> json) {
    return OrdersResponseModel(
      id: json['id'],
      cartId: json['cart_id'],
      partnerid: json.containsKey('partnerid') ? json['partnerid'] : 0,
      name: json['name'],
      dateOrder: json['date_order'],
      partnerName: json['partner_name'],
     // amountTotal: DateTime.parse(json['DATE']),
      amountTotal: json['amount_total'],
      orderCompleteStatus: json['order_complete_status'],
      orderPdfUrl: json['order_pdf_url'],
      invoicePdfUrl: json['invoice_pdf_url']
    );
  }
}