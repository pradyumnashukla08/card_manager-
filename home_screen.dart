import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'add_card_screen.dart';
import '../models/card_model.dart';  // Import the model

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<CardModel> cardBox;  // Box to store cards

  @override
  void initState() {
    super.initState();
    cardBox = Hive.box<CardModel>('cards'); // Open Hive box
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Column(
        children: [
          Expanded(
            child: cardBox.isEmpty
                ? const Center(child: Text("No Cards Added Yet"))
                : ListView.builder(
              itemCount: cardBox.length,
              itemBuilder: (context, index) {
                final card = cardBox.getAt(index);
                return Card(
                  child: ListTile(
                    title: Text(card!.name),
                    subtitle: Text("Card Type: ${card.type}"),
                    trailing: Text("**** **** **** ${card.number.substring(12)}"),
                  ),
                );
              },
            ),
          ),
          // Add Card Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCardScreen()),
                );
                setState(() {}); // Refresh screen after adding card
              },
              child: const Text("Add Card"),
            ),
          ),
        ],
      ),
    );
  }
}
