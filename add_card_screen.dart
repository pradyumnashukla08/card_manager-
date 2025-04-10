import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/card_service.dart';
import '../models/card_model.dart';

class AddCardScreen extends StatefulWidget {
  final CardModel? card;

  const AddCardScreen({Key? key, this.card}) : super(key: key);

  @override
  _AddCardScreenState createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _limitController = TextEditingController();

  String _selectedCategory = 'Credit Card';
  String _selectedDueDate = '1';
  bool _isSaving = false;
  bool _isEditing = false;
  String? _originalEncryptedNumber;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _isEditing = true;
      _nameController.text = widget.card!.cardName;
      _expiryController.text = widget.card!.expiryDate;
      _selectedCategory = widget.card!.category;
      _selectedDueDate = widget.card!.billingDueDate.toString();
      _limitController.text = widget.card!.cardLimit.toString();
      _originalEncryptedNumber = widget.card!.encryptedCardNumber;
      _numberController.text = _originalEncryptedNumber!;
    }
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length > 16) value = value.substring(0, 16);
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(value[i]);
    }
    return buffer.toString();
  }

  String _formatExpiryDate(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length > 4) value = value.substring(0, 4);
    return value.length > 2 ? '${value.substring(0, 2)}/${value.substring(2)}' : value;
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final cardService = Provider.of<CardService>(context, listen: false);
      final encryptedCardNumber = _numberController.text.replaceAll(' ', '');

      final newCard = CardModel(
        id: _isEditing ? widget.card!.id : '',
        cardName: _nameController.text.trim(),
        encryptedCardNumber: encryptedCardNumber,
        expiryDate: _expiryController.text.trim(),
        category: _selectedCategory,
        billingDueDate: int.tryParse(_selectedDueDate) ?? 1,
        cardLimit: double.tryParse(_limitController.text.trim()) ?? 0,
        createdAt: widget.card?.createdAt ?? DateTime.now(),
      );

      _isEditing
          ? await cardService.updateCard(newCard)
          : await cardService.addCard(newCard);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint("🔥 Error saving card: $e");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Card' : 'Add Card')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Cardholder Name',
                validator: (val) => val!.isEmpty ? 'Enter the cardholder name' : null,
              ),
              _buildFormattedField(
                controller: _numberController,
                label: 'Card Number',
                enabled: !_isEditing,
                formatter: _formatCardNumber,
                validator: (val) {
                  final clean = val!.replaceAll(' ', '');
                  if (_isEditing && clean == _originalEncryptedNumber) return null;
                  return clean.length == 16 ? null : 'Must be 16 digits';
                },
              ),
              _buildFormattedField(
                controller: _expiryController,
                label: 'Expiry Date (MM/YY)',
                formatter: _formatExpiryDate,
                validator: (val) {
                  if (val == null || val.length != 5) return 'Enter MM/YY';
                  final month = int.tryParse(val.substring(0, 2));
                  return (month != null && month >= 1 && month <= 12)
                      ? null
                      : 'Enter valid month';
                },
              ),
              _buildTextField(
                controller: _limitController,
                label: 'Card Limit',
                keyboardType: TextInputType.number,
              ),
              _buildDropdown(
                value: _selectedCategory,
                label: 'Category',
                items: ['Credit Card', 'Debit Card', 'ID Card'],
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              _buildDropdown(
                value: _selectedDueDate,
                label: 'Billing Due Date',
                items: List.generate(31, (i) => '${i + 1}'),
                onChanged: (val) => setState(() => _selectedDueDate = val!),
              ),
              const SizedBox(height: 24),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _saveCard,
                child: Text(_isEditing ? 'Update Card' : 'Save Card'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(labelText: label),
        validator: validator,
        enabled: enabled,
      ),
    );
  }

  Widget _buildFormattedField({
    required TextEditingController controller,
    required String label,
    required String Function(String) formatter,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        enabled: enabled,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(19),
          TextInputFormatter.withFunction((oldValue, newValue) {
            final formatted = formatter(newValue.text);
            return TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }),
        ],
        decoration: InputDecoration(labelText: label),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
