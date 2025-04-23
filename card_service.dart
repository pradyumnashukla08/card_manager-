import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/card_model.dart';
import '../config/supabase_config.dart';
import '../utils/encryption_helper.dart';

class CardService {
  final _client = SupabaseConfig.client;

  // 🔐 Save a new card (encrypted)
  Future<void> saveCard(CardModel card) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    try {
      final encryptedCardNumber = await EncryptionHelper.encrypt(card.cardNumber);
      final encryptedCardHolder = await EncryptionHelper.encrypt(card.cardHolder);

      final response = await _client.from('credit_cards').insert({
        'user_id': userId,
        'card_number': encryptedCardNumber,
        'card_holder': encryptedCardHolder,
        'expiry_date': card.expiryDate,
        'due_date': card.dueDate.toIso8601String(),
        'card_limit': card.cardLimit,
      }).select();

      print("✅ Card saved successfully: $response");
    } catch (e) {
      print("❌ Error saving card: $e");
      rethrow;
    }
  }

  // 🔄 Update existing card by ID
  Future<void> updateCard(int cardId, CardModel updatedCard) async {
    try {
      final encryptedCardNumber = await EncryptionHelper.encrypt(updatedCard.cardNumber);
      final encryptedCardHolder = await EncryptionHelper.encrypt(updatedCard.cardHolder);

      final response = await _client.from('credit_cards').update({
        'card_number': encryptedCardNumber,
        'card_holder': encryptedCardHolder,
        'expiry_date': updatedCard.expiryDate,
        'due_date': updatedCard.dueDate.toIso8601String(),
        'card_limit': updatedCard.cardLimit,
      }).eq('id', cardId);

      print("✅ Card updated successfully: $response");
    } catch (e) {
      print("❌ Error updating card: $e");
      rethrow;
    }
  }

  // 🔓 Fetch all cards and decrypt safely
  Future<List<CardModel>> getCards() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception("User not logged in");

    try {
      final response = await _client
          .from('credit_cards')
          .select()
          .eq('user_id', userId);

      final data = response as List;

      // Try decryption, skip entries that fail
      final cards = await Future.wait(data.map((card) async {
        try {
          return await CardModel.fromEncryptedMap(card);
        } catch (e) {
          print("⚠️ Skipping corrupted card ID: ${card['id']}, error: $e");
          return null;
        }
      }));

      return cards.whereType<CardModel>().toList(); // Remove nulls
    } catch (e) {
      print("❌ Error fetching cards: $e");
      rethrow;
    }
  }

  // ❌ Delete card by ID
  Future<void> deleteCard(int cardId) async {
    try {
      final response = await _client
          .from('credit_cards')
          .delete()
          .eq('id', cardId);

      print("🗑️ Card deleted successfully: $response");
    } catch (e) {
      print("❌ Error deleting card: $e");
      rethrow;
    }
  }
}
