import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardholderNameController =
      TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _upiIdController = TextEditingController();

  bool _isLoading = false;
  bool _isAddingCard = false;
  String _selectedPaymentType = 'card';
  String _defaultPaymentMethod = '';

  final List<Map<String, dynamic>> _savedPaymentMethods = [
    {
      'id': 'card_1',
      'type': 'card',
      'name': 'HDFC Credit Card',
      'number': '**** **** **** 1234',
      'expiry': '12/25',
      'isDefault': true,
      'icon': Icons.credit_card,
      'color': Colors.blue,
    },
    {
      'id': 'upi_1',
      'type': 'upi',
      'name': 'Paytm UPI',
      'number': 'user@paytm',
      'expiry': '',
      'isDefault': false,
      'icon': Icons.account_balance_wallet,
      'color': Colors.blue,
    },
    {
      'id': 'card_2',
      'type': 'card',
      'name': 'SBI Debit Card',
      'number': '**** **** **** 5678',
      'expiry': '08/26',
      'isDefault': false,
      'icon': Icons.credit_card,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _defaultPaymentMethod = _savedPaymentMethods.firstWhere(
      (method) => method['isDefault'],
    )['id'];
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardholderNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _addPaymentMethod() {
    setState(() {
      _isAddingCard = true;
    });
  }

  void _savePaymentMethod() async {
    if (_selectedPaymentType == 'card') {
      if (_cardNumberController.text.isEmpty ||
          _cardholderNameController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        _showSnackBar('Please fill all card details');
        return;
      }
    } else {
      if (_upiIdController.text.isEmpty) {
        _showSnackBar('Please enter UPI ID');
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate saving payment method
    await Future.delayed(const Duration(seconds: 2));

    final newMethod = {
      'id': 'method_${DateTime.now().millisecondsSinceEpoch}',
      'type': _selectedPaymentType,
      'name': _selectedPaymentType == 'card'
          ? '${_cardholderNameController.text}\'s Card'
          : 'UPI ID',
      'number': _selectedPaymentType == 'card'
          ? '**** **** **** ${_cardNumberController.text.substring(_cardNumberController.text.length - 4)}'
          : _upiIdController.text,
      'expiry': _selectedPaymentType == 'card' ? _expiryController.text : '',
      'isDefault': _savedPaymentMethods.isEmpty,
      'icon': _selectedPaymentType == 'card'
          ? Icons.credit_card
          : Icons.account_balance_wallet,
      'color': _selectedPaymentType == 'card' ? Colors.blue : Colors.green,
    };

    setState(() {
      _savedPaymentMethods.add(newMethod);
      _isLoading = false;
      _isAddingCard = false;
      _clearForm();
    });

    _showSnackBar('Payment method added successfully');
  }

  void _clearForm() {
    _cardNumberController.clear();
    _cardholderNameController.clear();
    _expiryController.clear();
    _cvvController.clear();
    _upiIdController.clear();
    _selectedPaymentType = 'card';
  }

  void _setDefaultPaymentMethod(String methodId) {
    setState(() {
      for (var method in _savedPaymentMethods) {
        method['isDefault'] = method['id'] == methodId;
      }
      _defaultPaymentMethod = methodId;
    });
    _showSnackBar('Default payment method updated');
  }

  void _deletePaymentMethod(String methodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text(
          'Are you sure you want to delete this payment method?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _savedPaymentMethods.removeWhere(
                  (method) => method['id'] == methodId,
                );
                if (_defaultPaymentMethod == methodId &&
                    _savedPaymentMethods.isNotEmpty) {
                  _savedPaymentMethods.first['isDefault'] = true;
                  _defaultPaymentMethod = _savedPaymentMethods.first['id'];
                }
              });
              _showSnackBar('Payment method deleted');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _addPaymentMethod,
            icon: const Icon(Icons.add),
            tooltip: 'Add Payment Method',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Default Payment Method
            if (_savedPaymentMethods.isNotEmpty) ...[
              const Text(
                'Default Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        _savedPaymentMethods.firstWhere(
                          (method) => method['isDefault'],
                        )['icon'],
                        color: _savedPaymentMethods.firstWhere(
                          (method) => method['isDefault'],
                        )['color'],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _savedPaymentMethods.firstWhere(
                                (method) => method['isDefault'],
                              )['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _savedPaymentMethods.firstWhere(
                                (method) => method['isDefault'],
                              )['number'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Saved Payment Methods
            const Text(
              'Saved Payment Methods',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Payment Methods List
            ..._savedPaymentMethods
                .map(
                  (method) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            method['icon'],
                            color: method['color'],
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  method['number'],
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (method['expiry'].isNotEmpty)
                                  Text(
                                    'Expires: ${method['expiry']}',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'default') {
                                _setDefaultPaymentMethod(method['id']);
                              } else if (value == 'delete') {
                                _deletePaymentMethod(method['id']);
                              }
                            },
                            itemBuilder: (context) => [
                              if (!method['isDefault'])
                                const PopupMenuItem(
                                  value: 'default',
                                  child: Row(
                                    children: [
                                      Icon(Icons.star),
                                      SizedBox(width: 8),
                                      Text('Set as Default'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            child: const Icon(Icons.more_vert),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),

            // Add Payment Method Form
            if (_isAddingCard) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _isAddingCard = false;
                                _clearForm();
                              });
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Payment Type Selection
                      const Text(
                        'Payment Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Card'),
                              value: 'card',
                              groupValue: _selectedPaymentType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentType = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('UPI'),
                              value: 'upi',
                              groupValue: _selectedPaymentType,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentType = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card Details
                      if (_selectedPaymentType == 'card') ...[
                        CustomTextField(
                          controller: _cardNumberController,
                          hintText: 'Card Number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(16),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _cardholderNameController,
                          hintText: 'Cardholder Name',
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: _expiryController,
                                hintText: 'MM/YY',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: CustomTextField(
                                controller: _cvvController,
                                hintText: 'CVV',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],

                      // UPI Details
                      if (_selectedPaymentType == 'upi') ...[
                        CustomTextField(
                          controller: _upiIdController,
                          hintText: 'UPI ID (e.g., name@bank)',
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          onPressed: _isLoading ? null : _savePaymentMethod,
                          text: _isLoading
                              ? 'Saving...'
                              : 'Save Payment Method',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Security Information
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Security & Privacy',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• All payment methods are encrypted\n'
                      '• Card details are securely stored\n'
                      '• PCI DSS compliant\n'
                      '• No sensitive data stored locally',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
