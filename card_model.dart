class CardModel {
  final String id;
  final String cardName;
  final String encryptedCardNumber;
  final String expiryDate;
  final String category;
  final int billingDueDate;
  final double cardLimit;
  final DateTime? createdAt;

  CardModel({
    required this.id,
    required this.cardName,
    required this.encryptedCardNumber,
    required this.expiryDate,
    required this.category,
    required this.billingDueDate,
    required this.cardLimit,
    this.createdAt,
  });

  /// ✅ **Add `copyWith` Method**
  CardModel copyWith({
    String? id,
    String? cardName,
    String? encryptedCardNumber,
    String? expiryDate,
    String? category,
    int? billingDueDate,
    double? cardLimit,
    DateTime? createdAt,
  }) {
    return CardModel(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      encryptedCardNumber: encryptedCardNumber ?? this.encryptedCardNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      category: category ?? this.category,
      billingDueDate: billingDueDate ?? this.billingDueDate,
      cardLimit: cardLimit ?? this.cardLimit,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'card_name': cardName,
      'encrypted_card_number': encryptedCardNumber,
      'expiry_date': expiryDate,
      'category': category,
      'billing_due_date': billingDueDate,
      'card_limit': cardLimit,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] ?? '',
      cardName: json['card_name'] ?? '',
      encryptedCardNumber: json['encrypted_card_number'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
      category: json['category'] ?? '',
      billingDueDate: (json['billing_due_date'] as int?) ?? 1,
      cardLimit: (json['card_limit'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
