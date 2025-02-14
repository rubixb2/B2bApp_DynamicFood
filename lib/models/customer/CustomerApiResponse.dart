import 'dart:convert';

/*class CustomerResponse {
  final int control;
  final CustomerData data;

  CustomerResponse({required this.control, required this.data});

  factory CustomerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerResponse(
      control: json['Control'] ?? 0,
      data: CustomerData.fromJson(json['Data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Control': control,
      'Data': data.toJson(),
    };
  }
}*/

class CustomerApiResponse {
  final List<Customer> customerList;
  final int totalCount;

  CustomerApiResponse({required this.customerList, required this.totalCount});

  factory CustomerApiResponse.fromJson(Map<String, dynamic> json) {
    return CustomerApiResponse(
      customerList: (json['CustomerList'] as List)
          .map((item) => Customer.fromJson(item))
          .toList(),
      totalCount: json['TotalCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CustomerList': customerList.map((customer) => customer.toJson()).toList(),
      'TotalCount': totalCount,
    };
  }
}
class Customer {
  final int id;
  final String name;
  final String? vat;
  final String? displayName;
  final String? companyType;
  final bool? active;
  final bool? isCompany;
  final List<int>? saleOrderIds;
  final int? saleOrderCount;
  final List<dynamic>? propertyAccountReceivableId;
  final List<dynamic>? propertyPaymentTermId;
  final List<dynamic>? propertyAccountPositionId;
  final String? lang;
  final String? contactAddress;
  final double? totalInvoiced;
  final String? street;
  final dynamic phone;
  final dynamic email;
  final String? zip;
  final String? city;

  Customer({
    required this.id,
    required this.name,
    this.vat,
    this.displayName,
    this.companyType,
    this.active,
    this.isCompany,
    this.saleOrderIds,
    this.saleOrderCount,
    this.propertyAccountReceivableId,
    this.propertyPaymentTermId,
    this.propertyAccountPositionId,
    this.lang,
    this.contactAddress,
    this.totalInvoiced,
    this.street,
    this.phone,
    this.email,
    this.zip,
    this.city,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      vat: json['vat'],
      displayName: json['display_name'],
      companyType: json['company_type'],
      active: json['active'],
      isCompany: json['is_company'],
      saleOrderIds: json['sale_order_ids'] != null
          ? List<int>.from(json['sale_order_ids'])
          : null,
      saleOrderCount: json['sale_order_count'],
      propertyAccountReceivableId: json['property_account_receivable_id'],
      propertyPaymentTermId: json['property_payment_term_id'],
      propertyAccountPositionId: json['property_account_position_id'],
      lang: json['lang'],
      contactAddress: json['contact_address'],
      totalInvoiced: (json['total_invoiced'] != null)
          ? double.tryParse(json['total_invoiced'].toString())
          : null,
      street: json['street'],
      phone: json['phone'],
      email: json['email'],
      zip: json['zip'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vat': vat,
      'display_name': displayName,
      'company_type': companyType,
      'active': active,
      'is_company': isCompany,
      'sale_order_ids': saleOrderIds,
      'sale_order_count': saleOrderCount,
      'property_account_receivable_id': propertyAccountReceivableId,
      'property_payment_term_id': propertyPaymentTermId,
      'property_account_position_id': propertyAccountPositionId,
      'lang': lang,
      'contact_address': contactAddress,
      'total_invoiced': totalInvoiced,
      'street': street,
      'phone': phone,
      'email': email,
      'zip': zip,
      'city': city,
    };
  }
}
