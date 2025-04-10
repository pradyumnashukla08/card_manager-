import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/card_model.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../services/notification_service.dart';

class CardService extends ChangeNotifier {
  final SupabaseClient supabase = Supabase.instance.client;
  List<CardModel> _cards = [];
  bool isLoading = false;

  List<CardModel> get cards {
    debugPrint("📌 Current Cards List: $_cards");
    return _cards;
  }

  /// 🔐 AES Encryption Key (Must be exactly 32 bytes for AES-256)
  final String _encryptionKey = '0123456789abcdef0123456789abcdef';

  /// 🔐 Encrypt card number before storing
  String encryptCardNumber(String cardNumber) {
    try {
      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc));

      final encrypted = encrypter.encrypt(cardNumber, iv: iv);
      return base64.encode(iv.bytes + encrypted.bytes);
    } catch (e) {
      debugPrint('❌ Encryption Error: $e');
      return '';
    }
  }

  /// 🔓 Decrypt stored card number
  String decryptCardNumber(String encryptedData) {
    try {
      final key = encrypt.Key.fromUtf8(_encryptionKey);
      final data = base64.decode(encryptedData);
      final iv = encrypt.IV(Uint8List.fromList(data.sublist(0, 16)));
      final encryptedText = encrypt.Encrypted(
          Uint8List.fromList(data.sublist(16)));

      final encrypter = encrypt.Encrypter(
          encrypt.AES(key, mode: encrypt.AESMode.cbc));
      return encrypter.decrypt(encryptedText, iv: iv);
    } catch (e) {
      debugPrint('❌ Decryption Error: $e');
      return '**** **** **** ****';
    }
  }

  /// 📌 Fetch Cards from Supabase
  Future<void> fetchCards() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await supabase.from('cards').select();
      debugPrint("✅ Supabase Raw Response: $response");

      if (response is List) {
        _cards = response.map((json) {
          final card = CardModel.fromJson(json);
          return card.copyWith(
            encryptedCardNumber: decryptCardNumber(card.encryptedCardNumber),
          );
        }).toList();
      } else {
        _cards = [];
      }

      // Schedule reminders for all cards
      for (var card in _cards) {
        _scheduleReminders(card);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Fetch Cards Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// 🛎️ Schedule reminders for billing due dates
  void _scheduleReminders(CardModel card) {
    if (card.billingDueDate == null || card.billingDueDate == 0) {
      debugPrint("⚠️ No due date for card: ${card.cardName}");
      return;
    }

    try {
      DateTime dueDate = DateTime.parse(card.billingDueDate as String);

      // One day before
      DateTime oneDayBefore = dueDate.subtract(const Duration(days: 1));
      if (oneDayBefore.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          card.id.hashCode,
          "Upcoming Payment",
          "Your ${card.cardName} payment is due tomorrow!",
          oneDayBefore,
        );
      }

      // On the due date
      if (dueDate.isAfter(DateTime.now())) {
        NotificationService().scheduleNotification(
          card.id.hashCode + 1,
          "Payment Due Today!",
          "Your ${card.cardName} payment is due today. Don't forget to pay!",
          dueDate,
        );
      }
    } catch (e) {
      debugPrint("❌ Reminder Scheduling Error: $e");
    }
  }

  /// ➕ Add a new card to Supabase
  Future<void> addCard(CardModel card) async {
    try {
      String encryptedCardNumber = encryptCardNumber(card.encryptedCardNumber);

      if (encryptedCardNumber.isEmpty) {
        throw Exception("Encryption failed");
      }

      String newId = const Uuid().v4();
      final newCard = card.copyWith(
          id: newId, encryptedCardNumber: encryptedCardNumber);

      await supabase.from('cards').insert(newCard.toJson());

      debugPrint("✅ Card Added Successfully: ${newCard.toJson()}");

      await fetchCards();
    } catch (e) {
      debugPrint('❌ Add Card Error: $e');
    }
  }

  /// ✏️ Update an existing card
  Future<void> updateCard(CardModel card) async {
    try {
      String encryptedCardNumber = encryptCardNumber(card.encryptedCardNumber);

      if (encryptedCardNumber.isEmpty) {
        throw Exception("Encryption failed");
      }

      final response = await supabase.from('cards').update({
        'card_name': card.cardName,
        'encrypted_card_number': encryptedCardNumber,
        'expiry_date': card.expiryDate,
        'category': card.category,
        'billing_due_date': card.billingDueDate,
        'card_limit': card.cardLimit,
      }).match({'id': card.id}).select();

      debugPrint("🔄 Update Response: $response");

      if (response == null || response.isEmpty) {
        debugPrint("❌ Update failed. No record updated.");
      } else {
        debugPrint("✅ Card Updated Successfully!");
        await fetchCards(); // Refresh the card list after update
      }
    } catch (e) {
      debugPrint('❌ Update Card Error: $e');
    }
  }


  Future<void> deleteCard(String id) async {
    try {
      debugPrint("🗑️ Deleting card with ID: $id");

      final response = await supabase
          .from('cards')
          .delete()
          .eq('id', id)
          .select();

      debugPrint("🗑️ Delete Response: $response");

      if (response == null || response.isEmpty) {
        debugPrint("❌ Delete failed. No record deleted.");
      } else {
        debugPrint("✅ Card Deleted Successfully!");
        await fetchCards(); // Refresh the card list after deletion
      }
    } catch (e) {
      debugPrint('❌ Delete Card Error: $e');
    }
  }
}
