import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardDetailScreen extends StatelessWidget {
  final CardModel card;

  const CardDetailScreen({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String lastFourDigits = card.encryptedCardNumber.length >= 4
        ? card.encryptedCardNumber.substring(card.encryptedCardNumber.length - 4)
        : "****";

    return Scaffold(
      appBar: AppBar(title: const Text("Card Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Card Name: ${card.cardName}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text("Card Number: **** **** **** $lastFourDigits",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("Expiry Date: ${card.expiryDate}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("Billing Due Date: ${card.billingDueDate}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("Category: ${card.category}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 10),
                Text("Card Limit: \$${card.cardLimit.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, color: Colors.green)),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Go Back"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
