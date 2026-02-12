class DefectItem {
  final String issue;
  final int price;
  final int quantity;

  DefectItem({
    required this.issue,
    required this.price,
    this.quantity = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'issue': issue,
      'price': price,
      'quantity': quantity,
    };
  }

  factory DefectItem.fromMap(Map<String, dynamic> map) {
    return DefectItem(
      issue: map['issue'] ?? '',
      price: map['price'] ?? 0,
      quantity: map['quantity'] ?? 1,
    );
  }
}
