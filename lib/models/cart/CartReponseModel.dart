import 'CartProductModel.dart';

class CartResponseModel {
  final int id;
  final String customerId;
  final int merchantId;
  final int userId;
  final DateTime date;
  final bool status;
  final int customersWinnedProductId;
  final double? deliveryFee;
  final double? paidAmount;
  final double takeawayDiscountAmount;
  final String? discountCode;
  final double discountAmount;
  final String? discountDescription;
  final int paymentStatus;
  final String? warningDescription;
  final int tempBranchId;
  final int giftType;
  final int repeatedCartId;
  final int baseBranchId;
  final int pointOperationId;
  final int totalUsedPoint;
  final DateTime? updateDate;
  final String? orders;
  final bool deleted;
  final int orderId;
  final String? odooStatus;
  final bool orderStatus;
  final String? orderCompletePdfUrl;
  final bool invoiceStatus;
  final String? invoicePdfUrl;
  final bool active;
  final int invoiceId;
  final double cashAmount;
  final double cardAmount;
  final int paymentType;
  final double customerCashAmount;
  final double customerCashChange;
  final String? sequenceNo;
  final String? posPaymentText;
  final String? customerName;
  final double cartTotalPaid;
  final double cartPaid;
  final bool routed;
  final List<CartProductModel> cartProducts;

  CartResponseModel({
    required this.id,
    required this.customerId,
    required this.merchantId,
    required this.userId,
    required this.date,
    required this.status,
    required this.customersWinnedProductId,
    this.deliveryFee,
    this.paidAmount,
    required this.takeawayDiscountAmount,
    this.discountCode,
    required this.discountAmount,
    this.discountDescription,
    required this.paymentStatus,
    this.warningDescription,
    required this.tempBranchId,
    required this.giftType,
    required this.repeatedCartId,
    required this.baseBranchId,
    required this.pointOperationId,
    required this.totalUsedPoint,
    this.updateDate,
    this.orders,
    required this.deleted,
    required this.orderId,
    this.odooStatus,
    required this.orderStatus,
    this.orderCompletePdfUrl,
    required this.invoiceStatus,
    this.invoicePdfUrl,
    required this.active,
    required this.invoiceId,
    required this.cashAmount,
    required this.cardAmount,
    required this.paymentType,
    required this.customerCashAmount,
    required this.customerCashChange,
    this.sequenceNo,
    this.posPaymentText,
    this.customerName,
    required this.cartTotalPaid,
    required this.cartPaid,
    required this.routed,
    required this.cartProducts,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) {
    return CartResponseModel(
      id: json['ID'],
      customerId: json['CUSTOMER_ID'],
      merchantId: json['MERCHANT_ID'],
      userId: json['USER_ID'],
      date: DateTime.parse(json['DATE']),
      status: json['STATUS'],
      customersWinnedProductId: json['CUSTOMERS_WINNED_PRODUCT_ID'],
      deliveryFee: json['DELIVERY_FEE'],
      paidAmount: json['PAID_AMOUNT'],
      takeawayDiscountAmount: json['TAKEAWAY_DISCOUNT_AMOUNT'],
      discountCode: json['DISCOUNT_CODE'],
      discountAmount: json['DISCOUNT_AMOUNT'],
      discountDescription: json['DISCOUNT_DESCRIPTION'],
      paymentStatus: json['PAYMENT_STATUS'],
      warningDescription: json['WARNING_DESCRIPTION'],
      tempBranchId: json['TEMP_BRANCH_ID'],
      giftType: json['GIFT_TYPE'],
      repeatedCartId: json['REPEATED_CART_ID'],
      baseBranchId: json['BASE_BRANCH_ID'],
      pointOperationId: json['POINT_OPERATION_ID'],
      totalUsedPoint: json['TOTAL_USED_POINT'],
      updateDate: json['UPDATE_DATE'] != null
          ? DateTime.parse(json['UPDATE_DATE'])
          : null,
      orders: json['ORDERS'],
      deleted: json['DELETED'],
      orderId: json['ORDER_ID'],
      odooStatus: json['ODOO_STATUS'],
      orderStatus: json['ORDER_STATUS'],
      orderCompletePdfUrl: json['ORDER_COMPLETE_PDF_URL'],
      invoiceStatus: json['INVOICE_STATUS'],
      invoicePdfUrl: json['INVOICE_PDF_URL'],
      active: json['ACTIVE'],
      invoiceId: json['INVOICE_ID'],
      cashAmount: json['CASH_AMOUNT'],
      cardAmount: json['CARD_AMOUNT'],
      paymentType: json['PAYMENT_TYPE'],
      customerCashAmount: json['CUSTOMER_CASH_AMOUNT'],
      customerCashChange: json['CUSTOMER_CASH_CHANGE'],
      sequenceNo: json['SEQUENCE_NO'],
      posPaymentText: json['POS_PAYMENT_TEXT'],
      customerName: json['CUSTOMER_NAME'],
      cartTotalPaid: json['CART_TOTAL_PAID'],
      cartPaid: json['CART_PAID'],
      routed: json['ROUTED'],
      cartProducts: (json['CART_PRODUCTS'] as List<dynamic>)
          .map((item) => CartProductModel.fromJson(item))
          .toList(),
    );
  }
}
