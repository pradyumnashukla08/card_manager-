import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';
import 'edit_card_screen.dart';

class ViewCardsScreen extends StatefulWidget {
  const ViewCardsScreen({super.key});

  @override
  State<ViewCardsScreen> createState() => _ViewCardsScreenState();
}

class _ViewCardsScreenState extends State<ViewCardsScreen> {
  late Future<List<CardModel>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    _cardsFuture = CardService().getCards();
  }

  void _deleteCard(int cardId) async {
    await CardService().deleteCard(cardId);
    setState(() => _loadCards());
  }

  void _editCard(CardModel card) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditCardScreen(card: card)),
    );
    setState(() => _loadCards());
  }

  Widget _buildCard(CardModel card) {
    final formattedDueDate = DateFormat('dd/MM/yyyy').format(card.dueDate);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade500, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            card.cardHolder,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            card.cardNumber,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Expiry: ${card.expiryDate}",
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                "Limit: ₹${card.cardLimit.toStringAsFixed(2)}",
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            "Due: $formattedDueDate",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _editCard(card),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () => _deleteCard(card.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cards")),
      body: FutureBuilder<List<CardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading cards:\n${snapshot.error}",
                  textAlign: TextAlign.center),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No cards found."));
          }

          final cards = snapshot.data!;
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) => _buildCard(cards[index]),
          );
        },
      ),
    );
  }
}
