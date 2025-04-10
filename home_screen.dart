import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/card_service.dart';
import '../models/card_model.dart';
import 'add_card_screen.dart';
import 'card_detail_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); // ✅ Added 'key' parameter

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardService = Provider.of<CardService>(context, listen: false);
      cardService.fetchCards();
    });
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cards"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _goToProfileScreen,
          ),
          IconButton(
            icon: const Icon(Icons.credit_card),
            onPressed: () => _showSavedCards(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
      ),
      body: Consumer<CardService>(
        builder: (context, cardService, child) {
          return RefreshIndicator(
            onRefresh: () async => cardService.fetchCards(),
            child: cardService.isLoading
                ? const Center(child: CircularProgressIndicator())
                : cardService.cards.isEmpty
                ? const Center(
              child: Text(
                "No cards available. Add a card!",
                style: TextStyle(fontSize: 18),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: cardService.cards.length,
              itemBuilder: (context, index) {
                final card = cardService.cards[index];
                String lastFourDigits = card.encryptedCardNumber.length >= 4
                    ? card.encryptedCardNumber.substring(card.encryptedCardNumber.length - 4)
                    : "****";

                return GestureDetector(
                  onTap: () => _viewCardDetails(card),
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(card.cardName,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Card Ending: $lastFourDigits"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editCard(card),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDelete(cardService, card.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("Add Card"),
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCardScreen()),
          );

          if (result == true && mounted) {
            Provider.of<CardService>(context, listen: false).fetchCards();
          }
        },
      ),
    );
  }

  void _viewCardDetails(CardModel card) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CardDetailScreen(card: card)),
    );
  }

  void _editCard(CardModel card) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddCardScreen(card: card)),
    ).then((result) {
      if (result == true) {
        // Refresh UI after editing
        Provider.of<CardService>(context, listen: false).fetchCards();
      }
    });
  }

  void _confirmDelete(CardService cardService, String cardId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Card"),
        content: const Text("Are you sure you want to delete this card?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await cardService.deleteCard(cardId);

              if (!mounted) return;

              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }


  void _showSavedCards(BuildContext context) {
    final cardService = Provider.of<CardService>(context, listen: false);

    if (cardService.cards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No saved cards found!")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 400,
          child: ListView.builder(
            itemCount: cardService.cards.length,
            itemBuilder: (context, index) {
              final card = cardService.cards[index];
              String lastFourDigits = card.encryptedCardNumber.length >= 4
                  ? card.encryptedCardNumber.substring(card.encryptedCardNumber.length - 4)
                  : "****";

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(card.cardName),
                  subtitle: Text("**** **** **** $lastFourDigits"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(cardService, card.id),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _goToProfileScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }
}
