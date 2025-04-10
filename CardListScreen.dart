import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/card_service.dart';
import 'add_card_screen.dart'; // Ensure you have this file

class CardListScreen extends StatefulWidget {
  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CardService>(context, listen: false).fetchCards(); // ✅ Fetch cards on screen load
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardService = Provider.of<CardService>(context);
    final cards = cardService.cards;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cards')),
      body: cards.isEmpty
          ? const Center(child: Text("No cards added yet!"))
          : ListView.builder(
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return ListTile(
            title: Text(card.cardName),
            subtitle: Text('**** **** **** ${card.encryptedCardNumber.substring(card.encryptedCardNumber.length - 4)}'),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await cardService.deleteCard(card.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Card deleted successfully!')),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
