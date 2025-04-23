import '../utils/encryption_helper.dart';

class CardModel {
  final int id;
  final String userId;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final DateTime dueDate;
  final double cardLimit;

  CardModel({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolder,
    required this.expiryDate,
    required this.dueDate,
    required this.cardLimit,
  });

  /// ✅ When data is already decrypted (normal usage)
  factory CardModel.fromMap(Map<String, dynamic> map) {
    return CardModel(
      id: map['id'] as int,
      userId: map['user_id'] as String,
      cardNumber: map['card_number'] as String,
      cardHolder: map['card_holder'] as String,
      expiryDate: map['expiry_date'] as String,
      dueDate: DateTime.parse(map['due_date']),
      cardLimit: (map['card_limit'] as num).toDouble(),
    );
  }

  /// 🔒 Used for encrypted data fetched from Supabase
  static Future<CardModel> fromEncryptedMap(Map<String, dynamic> map) async {
    try {
      final decryptedCardNumber = await EncryptionHelper.decrypt(map['card_number']);
      final decryptedCardHolder = await EncryptionHelper.decrypt(map['card_holder']);

      return CardModel(
        id: map['id'] as int,
        userId: map['user_id'] as String,
        cardNumber: decryptedCardNumber,
        cardHolder: decryptedCardHolder,
        expiryDate: map['expiry_date'] as String,
        dueDate: DateTime.parse(map['due_date']),
        cardLimit: (map['card_limit'] as num).toDouble(),
      );
    } catch (e) {
      print("⚠️ Failed to decrypt card data (ID: ${map['id']}): $e");

      // Optional: You can choose to either
      // 1. Skip this entry (return null and filter later)
      // 2. Return partially filled card (not recommended for sensitive data)
      // Here we throw to signal the failure for filtering outside
      throw Exception("Decryption failed for card ID: ${map['id']}");
    }
  }

  /// 🔒 Encrypt data before saving
  Future<Map<String, dynamic>> toEncryptedMap() async {
    final encryptedCardNumber = await EncryptionHelper.encrypt(cardNumber);
    final encryptedCardHolder = await EncryptionHelper.encrypt(cardHolder);

    return {
      'id': id,
      'user_id': userId,
      'card_number': encryptedCardNumber,
      'card_holder': encryptedCardHolder,
      'expiry_date': expiryDate,
      'due_date': dueDate.toIso8601String(),
      'card_limit': cardLimit,
    };
  }
}
