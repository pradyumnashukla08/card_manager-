import 'package:flutter/material.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCardType;
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();

  final List<String> _cardTypes = ["Credit Card", "Debit Card", "Prepaid Card"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Card")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Card Name
                TextFormField(
                  controller: _cardNameController,
                  decoration: const InputDecoration(labelText: "Card Name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a card name";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Card Type Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCardType,
                  items: _cardTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type));
                  }).toList(),
                  decoration: const InputDecoration(labelText: "Card Type"),
                  onChanged: (value) {
                    setState(() {
                      _selectedCardType = value;
                    });
                  },
                  validator: (value) => value == null ? "Please select a card type" : null,
                ),
                const SizedBox(height: 10),

                // 16-digit Card Number
                TextFormField(
                  controller: _cardNumberController,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: const InputDecoration(labelText: "Card Number"),
                  validator: (value) {
                    if (value == null || value.length != 16) {
                      return "Card number must be 16 digits";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Due Date (Day)
                TextFormField(
                  controller: _dueDateController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Due Date (DD)"),
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null || int.parse(value) < 1 || int.parse(value) > 31) {
                      return "Enter a valid day (1-31)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Expiry Date (MM/YYYY)
                TextFormField(
                  controller: _expiryDateController,
                  decoration: const InputDecoration(labelText: "Expiry Date (MM/YYYY)"),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      _expiryDateController.text = "${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}";
                    }
                  },
                  validator: (value) {
                    if (value == null || !RegExp(r'^(0[1-9]|1[0-2])\/\d{4}$').hasMatch(value)) {
                      return "Enter a valid expiry date (MM/YYYY)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Card Limit
                TextFormField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Limit"),
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return "Enter a valid limit";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Submit Button
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Card Added Successfully!")),
                      );
                    }
                  },
                  child: const Text("Add Card"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
