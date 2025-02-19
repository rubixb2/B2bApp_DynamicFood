class AddOrderResponseModel {
  int id;
  String name;
  String xQuotation;
  String state;
  String dateOrder;
  double amountUntaxed;
  double amountTax;
  double amountTotal;
  int cartId;
  int partnerId;
  String partnerName;
  String invoiceStatus;
  bool orderCompleteStatus;
  bool invoiceCreateStatus;
  String orderPdfUrl;
  String invoicePdfUrl;
  double discountPercentage;
  double discountAmount;

  AddOrderResponseModel({
    required this.id,
    required this.name,
    required this.xQuotation,
    required this.state,
    required this.dateOrder,
    required this.amountUntaxed,
    required this.amountTax,
    required this.amountTotal,
    required this.cartId,
    required this.partnerId,
    required this.partnerName,
    required this.invoiceStatus,
    required this.orderCompleteStatus,
    required this.invoiceCreateStatus,
    required this.orderPdfUrl,
    required this.invoicePdfUrl,
    required this.discountPercentage,
    required this.discountAmount,
  });

  // fromJson metodu
  factory AddOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return AddOrderResponseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      xQuotation: json['x_quotation'] ?? '',
      state: json['state'] ?? '',
      dateOrder: json['date_order'] ?? '',
      amountUntaxed: (json['amount_untaxed'] ?? 0).toDouble(),
      amountTax: (json['amount_tax'] ?? 0).toDouble(),
      amountTotal: (json['amount_total'] ?? 0).toDouble(),
      cartId: json['cart_id'] ?? 0,
      partnerId: json['partner_id'] ?? 0,
      partnerName: json['partner_name'] ?? '',
      invoiceStatus: json['invoice_status'] ?? '',
      orderCompleteStatus: json['order_complete_status'] ?? false,
      invoiceCreateStatus: json['invoice_create_status'] ?? false,
      orderPdfUrl: json['order_pdf_url'] ?? '',
      invoicePdfUrl: json['invoice_pdf_url'] ?? '',
      discountPercentage: (json['discount_percentage'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
    );
  }

  // toJson metodu
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'x_quotation': xQuotation,
      'state': state,
      'date_order': dateOrder,
      'amount_untaxed': amountUntaxed,
      'amount_tax': amountTax,
      'amount_total': amountTotal,
      'cart_id': cartId,
      'partner_id': partnerId,
      'partner_name': partnerName,
      'invoice_status': invoiceStatus,
      'order_complete_status': orderCompleteStatus,
      'invoice_create_status': invoiceCreateStatus,
      'order_pdf_url': orderPdfUrl,
      'invoice_pdf_url': invoicePdfUrl,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
    };
  }
}
