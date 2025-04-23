import 'package:flutter/material.dart';
import '../models/card_model.dart';

class EditCardScreen extends StatefulWidget {
  final CardModel card; // Add card parameter

  const EditCardScreen({Key? key, required this.card}) : super(key: key);

  @override
  _EditCardScreenState createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late TextEditingController cardNumberController;
  late TextEditingController cardHolderController;

  @override
  void initState() {
    super.initState();
    cardNumberController = TextEditingController(text: widget.card.cardNumber);
    cardHolderController = TextEditingController(text: widget.card.cardHolder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: cardNumberController,
              decoration: const InputDecoration(labelText: 'Card Number'),
            ),
            TextField(
              controller: cardHolderController,
              decoration: const InputDecoration(labelText: 'Card Holder'),
            ),
            ElevatedButton(
              onPressed: () {
                // Perform save/edit action here
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}

