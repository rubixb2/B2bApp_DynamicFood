class CategoryResponseModel {
  final int id;
  final String name;
  final String imageUrl;
  final String image;

  CategoryResponseModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.image,
  });

  factory CategoryResponseModel.fromJson(Map<String, dynamic> json) {
    return CategoryResponseModel(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      image: json['image'] ?? '',
    );
  }
}