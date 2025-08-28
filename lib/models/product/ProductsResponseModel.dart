class ProductsResponseModel {
  final int id;
  final String name;
  final String imageUrl;
  final String barcode;
  final String bigImageUrl;
  final int categId;
  final double stockCount;
  final double listPrice;
  final double unitPrice;
  final String listPriceText;
  final String unitPriceText;
  final double vatPrice;
  final String vatPriceText;
  final double taxedPrice;
  final String taxedPriceText;
  final String description;
  final int palletCount;

  ProductsResponseModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.barcode,
    required this.bigImageUrl,
    required this.categId,
    required this.stockCount,
    required this.listPrice,
    required this.unitPrice,
    required this.listPriceText,
    required this.unitPriceText,
    required this.vatPrice,
    required this.vatPriceText,
    required this.taxedPrice,
    required this.taxedPriceText,
    required this.palletCount,
    required this.description,
  });

  factory ProductsResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductsResponseModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      barcode: json['barcode'],
      bigImageUrl: json['big_image_url'],
      categId: json['categ_id'],
      stockCount: json['stock_count'],
      listPrice: json['list_price'],
      unitPrice: json['unit_price'],
      listPriceText: json['list_price_text'],
      unitPriceText: json['unit_price_text'],
      vatPrice: json['vat_price'],
      vatPriceText: json['vat_price_text'],
      taxedPrice: json['taxed_price'],
      taxedPriceText: json['taxed_price_text'],
      palletCount: json['pallet_count'],
      description: json['description'],
    );
  }
}
