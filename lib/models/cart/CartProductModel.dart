class CartProductModel {
  final int id;
  final int cartId;
  final int plu;
  final int quantity;
  final double price;
  final int unitMultiplierId;
  final int productType;
  final String? currencySymbol;
  final int productId;
  final String? discountCode;
  final double discountAmount;
  final String? discountDescription;
  final int parentId;
  final String? description;
  final int type;
  final String? productName;
  final int unit;
  final DateTime? createDate;
  final int vat;
  final double vatAmount;
  final String? vatDefault;
  final int addFrom;
  final double vatPrice;
  final String? productPriceInfo;
  final int dependentId;
  final double boxQuantity;
  final double pieceQuantity;
  final double lastQuantity;
  final double stockCount;
  final int boxUnitCount;
  final String? imageUrl;
  final double taxPercentage;
  final double unitPrice;
  final double productTotalPrice;
  final double taxedTotalPrice;
  final double taxAmount;
  final double unitTaxedPrice;
  final double ticketPrice;
  final double discountValue;
  final String? palletName;
  final double palletValue;
  final int palletCount;


  set pieceQuantity(double value) {
    if (value >= 0) { // Negatif olmasını önlemek için kontrol.
      pieceQuantity = value;
    }
  }
  set boxQuantity(double value) {
    if (value >= 0) { // Negatif olmasını önlemek için kontrol.
      boxQuantity = value;
    }
  }

  CartProductModel({
    required this.id,
    required this.cartId,
    required this.plu,
    required this.quantity,
    required this.price,
    required this.unitMultiplierId,
    required this.productType,
    required this.currencySymbol,
    required this.productId,
    required this.discountCode,
    required this.discountAmount,
    required this.discountDescription,
    required this.parentId,
    required this.description,
    required this.type,
    required this.productName,
    required this.unit,
    this.createDate,
    required this.vat,
    required this.vatAmount,
    required this.vatDefault,
    required this.addFrom,
    required this.vatPrice,
    required this.productPriceInfo,
    required this.dependentId,
    required this.boxQuantity,
    required this.pieceQuantity,
    required this.lastQuantity,
    required this.stockCount,
    required this.boxUnitCount,
    required this.imageUrl,
    required this.taxPercentage,
    required this.unitPrice,
    required this.productTotalPrice,
    required this.taxedTotalPrice,
    required this.taxAmount,
    required this.unitTaxedPrice,
    required this.ticketPrice,
    required this.discountValue,
    this.palletName,
    required this.palletValue,
    required this.palletCount,
  });

  factory CartProductModel.fromJson(Map<String, dynamic> json) {
    return CartProductModel(
      id: json['ID'],
      cartId: json['CART_ID'],
      plu: json['PLU'],
      quantity: json['QUANTITY'],
      price: json['PRICE'],
      unitMultiplierId: json['UNIT_MULTIPLIER_ID'],
      productType: json['PRODUCT_TYPE'],
      currencySymbol: json['CURRENCY_SYMBOL'],
      productId: json['PRODUCT_ID'],
      discountCode: json['DISCOUNT_CODE'],
      discountAmount: json['DISCOUNT_AMOUNT'],
      discountDescription: json['DISCOUNT_DESCRIPTION'],
      parentId: json['PARENT_ID'],
      description: json['DESCRIPTION'],
      type: json['TYPE'],
      productName: json['PRODUCT_NAME'],
      unit: json['UNIT'],
      createDate: json['CREATE_DATE'] != null
          ? DateTime.parse(json['CREATE_DATE'])
          : null,
      vat: json['VAT'],
      vatAmount: json['VAT_AMOUNT'],
      vatDefault: json['VAT_DEFAULT'],
      addFrom: json['ADD_FROM'],
      vatPrice: json['VAT_PRICE'],
      productPriceInfo: json['PRODUCT_PRICE_INFO'],
      dependentId: json['DEPENDENT_ID'],
      boxQuantity: json['BOX_QUANTITY'],
      pieceQuantity: json['PIECE_QUANTITY'],
      lastQuantity: json['LAST_QUANTITY'],
      stockCount: json['STOCK_COUNT'],
      boxUnitCount: json['BOX_UNIT_COUNT'],
      imageUrl: json['IMAGE_URL'],
      taxPercentage: json['TAX_PERCENTAGE'],
      unitPrice: json['UNIT_PRICE'],
      productTotalPrice: json['PRODUCT_TOTAL_PRICE'],
      taxedTotalPrice: json['TAXED_TOTAL_PRICE'],
      taxAmount: json['TAX_AMOUNT'],
      unitTaxedPrice: json['UNIT_TAXED_PRICE'],
      ticketPrice: json['TICKET_PRICE'],
      discountValue: json['DISCOUNT_VALUE'],
      palletName: json['PALLET_NAME'],
      palletValue: json['PALLET_VALUE'],
      palletCount: json['PALLET_COUNT'],
    );
  }
}
