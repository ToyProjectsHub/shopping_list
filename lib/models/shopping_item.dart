class ShoppingItem {
  final String id;
  String name;
  bool isCompleted;
  int? quantity;
  double? price;
  String? volume;
  String? link;

  ShoppingItem({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.quantity,
    this.price,
    this.volume,
    this.link,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isCompleted': isCompleted,
      'quantity': quantity,
      'price': price,
      'volume': volume,
      'link': link,
    };
  }

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    return ShoppingItem(
      id: json['id'] as String,
      name: json['name'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      quantity: json['quantity'] as int?,
      price: json['price'] as double?,
      volume: json['volume'] as String?,
      link: json['link'] as String?,
    );
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isCompleted,
    int? quantity,
    double? price,
    String? volume,
    String? link,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isCompleted: isCompleted ?? this.isCompleted,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      volume: volume ?? this.volume,
      link: link ?? this.link,
    );
  }
}
