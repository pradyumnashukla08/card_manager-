import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/card_service.dart';
import '../models/card_model.dart';
import '../config/supabase_config.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _cardLimitController = TextEditingController();

  String get _formattedCardNumber {
    String digits = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    return digits.replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ").trim();
  }

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _dueDateController.dispose();
    _cardLimitController.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (_formKey.currentState!.validate()) {
      try {
        final userId = SupabaseConfig.client.auth.currentUser?.id;
        if (userId == null) throw Exception('User not logged in');

        final card = CardModel(
          id: 0, // Supabase auto-generates ID
          userId: userId,
          cardHolder: _cardHolderController.text,
          cardNumber: _formattedCardNumber,
          expiryDate: _expiryDateController.text,
          // Convert the due date to a valid DateTime object (current month and year + DD)
          dueDate: DateTime(
            DateTime.now().year,
            DateTime.now().month,
            int.parse(_dueDateController.text), // Use the entered day (DD)
          ),
          cardLimit: double.parse(_cardLimitController.text),
        );

        await CardService().saveCard(card);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Card saved successfully!')));
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Card")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Card Preview
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formattedCardNumber.isEmpty ? 'XXXX XXXX XXXX XXXX' : _formattedCardNumber,
                        style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
                      ),
                      const Spacer(),
                      Text(
                        _cardHolderController.text.isEmpty
                            ? 'CARDHOLDER NAME'
                            : _cardHolderController.text.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        _expiryDateController.text.isEmpty ? 'MM/YY' : _expiryDateController.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _cardHolderController,
                decoration: const InputDecoration(labelText: "Cardholder Name"),
                onChanged: (_) => setState(() {}),
                validator: (value) => value!.isEmpty ? 'Enter cardholder name' : null,
              ),

              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(labelText: "Card Number"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                ],
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter card number';
                  final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                  if (digitsOnly.length != 16) return 'Card number must be 16 digits';
                  return null;
                },
              ),

              TextFormField(
                controller: _expiryDateController,
                decoration: const InputDecoration(labelText: "Expiry Date (MM/YY)"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'\d|/')),
                  LengthLimitingTextInputFormatter(5),
                ],
                onChanged: (value) {
                  if (value.length == 2 && !value.contains('/')) {
                    _expiryDateController.text = '$value/';
                    _expiryDateController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _expiryDateController.text.length));
                  }
                  setState(() {});
                },
                validator: (value) {
                  if (value == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                    return 'Enter valid expiry (MM/YY)';
                  }
                  return null;
                },
              ),

              TextFormField(
                controller: _dueDateController,
                decoration: const InputDecoration(labelText: "Due Day (DD)"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2), // Limit to 2 digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter due day';
                  final day = int.tryParse(value);
                  if (day == null || day < 1 || day > 31) return 'Invalid day (01-31)';
                  return null;
                },
              ),


              TextFormField(
                controller: _cardLimitController,
                decoration: const InputDecoration(labelText: "Card Limit (e.g. 50000.00)"),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter card limit';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Enter valid limit';
                  return null;
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveCard, child: const Text("Save Card")),
            ],
          ),
        ),
      ),
    );
  }
}
