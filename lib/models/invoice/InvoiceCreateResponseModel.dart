

class InvoiceCreateResponseModel {
  int control;
  String message;
  InvoiceData data;

  InvoiceCreateResponseModel({
    required this.control,
    required this.message,
    required this.data,
  });

  factory InvoiceCreateResponseModel.fromJson(Map<String, dynamic> json) {
    return InvoiceCreateResponseModel(
      control: json['Control'] ?? 0,
      message: json['Message'] ?? '',
      data: InvoiceData.fromJson(json['Data'] ?? {}),
    );
  }
}

class InvoiceData {
  int invoiceId;
  String pdfUrl;
  bool routed;

  InvoiceData({
    required this.invoiceId,
    required this.pdfUrl,
    required this.routed,
  });

  factory InvoiceData.fromJson(Map<String, dynamic> json) {
    return InvoiceData(
      invoiceId: json['invoiceId'] ?? 0,
      pdfUrl: json['pdfUrl'] ?? '',
      routed: json['routed'] ?? false,
    );
  }
}
