class InvoiceResponseModel {
  final int id;
  final String name;
  final double amountTax;
  final double amountTotal;
  final String partnerId;
  final String partnerName;
  final String invoiceDate;
  final String invoiceDateDue;
  final String overdueDay;
  final String typeName;
  final String accessUrl;
  final String invoiceOrigin;
  final double amountResidualSigned;
  final String paymentReference;
  final String amountResidualSignedText;
  final String paymentState;

  InvoiceResponseModel({
    required this.id,
    required this.name,
    required this.amountTax,
    required this.amountTotal,
    required this.partnerId,
    required this.partnerName,
    required this.invoiceDate,
    required this.invoiceDateDue,
    required this.overdueDay,
    required this.typeName,
    required this.accessUrl,
    required this.invoiceOrigin,
    required this.amountResidualSigned,
    required this.paymentReference,
    required this.amountResidualSignedText,
    required this.paymentState,
  });

  // JSON'dan Nesneye Dönüştürme
  factory InvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceResponseModel(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      amountTax: (json["amount_tax"] ?? 0).toDouble(),
      amountTotal: (json["amount_total"] ?? 0).toDouble(),
      partnerId: json["partner_id"] ?? "",
      partnerName: json["partner_name"] ?? "",
      invoiceDate: json["invoice_date"] ?? "",
      invoiceDateDue: json["invoice_date_due"] ?? "",
      overdueDay: json["overdue_day"] ?? "",
      typeName: json["type_name"] ?? "",
      accessUrl: json["access_url"] ?? "",
      invoiceOrigin: json["invoice_origin"] ?? "",
      amountResidualSigned: (json["amount_residual_signed"] ?? 0).toDouble(),
      paymentReference: json["payment_reference"] ?? "",
      amountResidualSignedText: json["amount_residual_signed_text"] ?? "",
      paymentState: json["payment_state"] ?? "",
    );
  }

  // Nesneyi JSON'a Dönüştürme
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "amount_tax": amountTax,
      "amount_total": amountTotal,
      "partner_id": partnerId,
      "partner_name": partnerName,
      "invoice_date": invoiceDate,
      "invoice_date_due": invoiceDateDue,
      "overdue_day": overdueDay,
      "type_name": typeName,
      "access_url": accessUrl,
      "invoice_origin": invoiceOrigin,
      "amount_residual_signed": amountResidualSigned,
      "payment_reference": paymentReference,
      "amount_residual_signed_text": amountResidualSignedText,
      "payment_state": paymentState,
    };
  }
}
