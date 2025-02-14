import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CustomersDetailResponseModel {
  final int id;
  final String vat;
  final String lang;
  final String name;
  final String phone;
  final String zip;
  final String city;
  final String displayName;
  final String contactAddress;
  final double credit;
  final double overdueDept;
  final int invoiceLimit;
  final List<CustomerOrderSaleResponseModel> orderSaleList;
  final List<CustomerOrderInvoiceResponseModel> orderInvoiceList;

  CustomersDetailResponseModel({
    required this.id,
    required this.vat,
    required this.lang,
    required this.name,
    required this.phone,
    required this.zip,
    required this.city,
    required this.displayName,
    required this.contactAddress,
    required this.credit,
    required this.overdueDept,
    required this.invoiceLimit,
    required this.orderSaleList,
    required this.orderInvoiceList,
  });

  factory CustomersDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomersDetailResponseModel(
      id: json['id'],
      vat: json['vat'],
      lang: json['lang'],
      name: json['name'],
      phone: json['phone'],
      zip: json['zip'],
      city: json['city'],
      displayName: json['display_name'],
      contactAddress: json['contact_address'],
      credit: json['credit'].toDouble(),
      overdueDept: json['overdueDept'].toDouble(),
      invoiceLimit: json['invoice_limit'],
      orderSaleList: (json['order_sale_list'] as List)
          .map((i) => CustomerOrderSaleResponseModel.fromJson(i))
          .toList(),
      orderInvoiceList: (json['order_invoice_list'] as List)
          .map((i) => CustomerOrderInvoiceResponseModel.fromJson(i))
          .toList(),
    );
  }
}

class CustomerOrderSaleResponseModel {
  final int id;
  final String name;
  final String createDate;
  final String invoiceStatus;
  final String invoiceNo;
  final double amountTotal;
  final String pdfUrl;

  CustomerOrderSaleResponseModel({
    required this.id,
    required this.name,
    required this.createDate,
    required this.invoiceStatus,
    required this.invoiceNo,
    required this.amountTotal,
    required this.pdfUrl,
  });

  factory CustomerOrderSaleResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderSaleResponseModel(
      id: json['id'],
      name: json['name'],
      createDate: json['create_date'],
      invoiceStatus: json['invoice_status'],
      invoiceNo: json['invoice_no'],
      amountTotal: json['amount_total'].toDouble(),
      pdfUrl: json['pdf_url'] ?? '',
    );
  }
}

class CustomerOrderInvoiceResponseModel {
  final int id;
  final String name;
  final String? invoiceDate;
  final String? invoiceDateDue;
  final int overdueDayInt;
  final String? invoiceOrigin;
  final double amountTotalSigned;
  final String? paymentState;
  final String? overdueDay;
  final String? pdfUrl;
  final int sort;

  CustomerOrderInvoiceResponseModel({
    required this.id,
    required this.name,
    required this.invoiceDate,
    required this.invoiceDateDue,
    required this.overdueDayInt,
    required this.invoiceOrigin,
    required this.amountTotalSigned,
    required this.paymentState,
    required this.overdueDay,
    required this.pdfUrl,
    required this.sort,
  });

  factory CustomerOrderInvoiceResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerOrderInvoiceResponseModel(
      id: json['id'],
      name: json['name'],
      invoiceDate: json['invoice_date'],
      invoiceDateDue: json['invoice_date_due'],
      overdueDayInt: json['overdue_day_int'],
      invoiceOrigin: json['invoice_origin'],
      amountTotalSigned: json['amount_total_signed'].toDouble(),
      paymentState: json['payment_state'],
      overdueDay: json['overdue_day'],
      pdfUrl: json['pdf_url'] ?? '',
      sort: json['sort'],
    );
  }
}
