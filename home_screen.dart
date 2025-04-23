import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_card_screen.dart';
import '../services/card_service.dart';
import '../models/card_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CardModel>> _cardsFuture;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    _cardsFuture = CardService().getCards(); // Already handles decryption
  }

  void _refreshCards() {
    setState(() {
      _loadCards();
    });
  }

  String _getMaskedCardNumber(String cardNumber) {
    try {
      return "**** **** **** ${cardNumber.substring(cardNumber.length - 4)}";
    } catch (e) {
      return "Invalid Card Number";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Credit Cards"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          )
        ],
      ),
      body: FutureBuilder<List<CardModel>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error loading cards:\n${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No cards found"));
          }

          final cards = snapshot.data!;
          return ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];

              return Card(
                elevation: 4,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    _getMaskedCardNumber(card.cardNumber),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Holder: ${card.cardHolder}"),
                      Text("Expiry: ${card.expiryDate}"),
                      Text("Due Date: ${card.dueDate.day}/${card.dueDate.month}/${card.dueDate.year}"),
                      Text("Limit: ₹${card.cardLimit.toStringAsFixed(2)}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCardPage()),
          );
          _refreshCards(); // Refresh after adding a new card
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
