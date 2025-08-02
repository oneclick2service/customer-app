import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../models/booking_model.dart';

class DigitalWalletScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const DigitalWalletScreen({
    Key? key,
    required this.booking,
    required this.amount,
  }) : super(key: key);

  @override
  State<DigitalWalletScreen> createState() => _DigitalWalletScreenState();
}

class _DigitalWalletScreenState extends State<DigitalWalletScreen> {
  String _selectedWallet = '';
  bool _isLoading = false;
  bool _isPaymentCompleted = false;
  String? _transactionId;
  final TextEditingController _amountController = TextEditingController();

  final List<Map<String, dynamic>> _wallets = [
    {
      'id': 'paytm',
      'name': 'Paytm',
      'icon': Icons.account_balance_wallet,
      'color': Colors.blue,
      'balance': 2500.0,
    },
    {
      'id': 'phonepe',
      'name': 'PhonePe',
      'icon': Icons.account_balance_wallet,
      'color': Colors.purple,
      'balance': 1800.0,
    },
    {
      'id': 'googlepay',
      'name': 'Google Pay',
      'icon': Icons.account_balance_wallet,
      'color': Colors.green,
      'balance': 3200.0,
    },
    {
      'id': 'amazonpay',
      'name': 'Amazon Pay',
      'icon': Icons.account_balance_wallet,
      'color': Colors.orange,
      'balance': 1500.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.amount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double _getWalletBalance(String walletId) {
    final wallet = _wallets.firstWhere((w) => w['id'] == walletId);
    return wallet['balance'];
  }

  bool _hasSufficientBalance(String walletId) {
    return _getWalletBalance(walletId) >= widget.amount;
  }

  void _selectWallet(String walletId) {
    setState(() {
      _selectedWallet = walletId;
    });
  }

  void _processPayment() async {
    if (_selectedWallet.isEmpty) {
      _showSnackBar('Please select a wallet');
      return;
    }

    if (!_hasSufficientBalance(_selectedWallet)) {
      _showInsufficientBalanceDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Generate transaction ID
    final transactionId = 'WALLET${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _transactionId = transactionId;
      _isPaymentCompleted = true;
      _isLoading = false;
    });

    _showPaymentSuccessDialog();
  }

  void _showInsufficientBalanceDialog() {
    final wallet = _wallets.firstWhere((w) => w['id'] == _selectedWallet);
    final balance = wallet['balance'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Balance'),
        content: Text(
          'Your ${wallet['name']} wallet has insufficient balance.\n\n'
          'Required: ₹${widget.amount.toStringAsFixed(2)}\n'
          'Available: ₹${balance.toStringAsFixed(2)}\n\n'
          'Please add money to your wallet or choose another payment method.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog() {
    final wallet = _wallets.firstWhere((w) => w['id'] == _selectedWallet);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: $_transactionId'),
            const SizedBox(height: 8),
            Text('Amount: ₹${_amountController.text}'),
            const SizedBox(height: 8),
            Text('Wallet: ${wallet['name']}'),
            const SizedBox(height: 8),
            Text(
              'Remaining Balance: ₹${(_getWalletBalance(_selectedWallet) - widget.amount).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            const Text('Your payment has been processed successfully.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('OK'),
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
        title: const Text('Digital Wallet'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Payment Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Service:'),
                        Text(widget.booking.serviceType),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Provider:'),
                        Text(
                          widget.booking.serviceProviderId ?? 'Not Assigned',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '₹${widget.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Select Wallet
            const Text(
              'Select Digital Wallet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Wallet Options
            ..._wallets
                .map(
                  (wallet) => Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: () => _selectWallet(wallet['id']),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _selectedWallet == wallet['id']
                                ? wallet['color']
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: wallet['color'].withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                wallet['icon'],
                                color: wallet['color'],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    wallet['name'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Balance: ₹${wallet['balance'].toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedWallet == wallet['id'])
                              Icon(
                                Icons.check_circle,
                                color: wallet['color'],
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),

            const SizedBox(height: 24),

            // Selected Wallet Details
            if (_selectedWallet.isNotEmpty) ...[
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Amount to Pay:'),
                          Text(
                            '₹${widget.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_wallets.firstWhere((w) => w['id'] == _selectedWallet)['name']} Balance:',
                          ),
                          Text(
                            '₹${_getWalletBalance(_selectedWallet).toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Remaining Balance:'),
                          Text(
                            '₹${(_getWalletBalance(_selectedWallet) - widget.amount).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _hasSufficientBalance(_selectedWallet)
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (!_hasSufficientBalance(_selectedWallet)) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning,
                                color: Colors.red.shade700,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Insufficient balance. Please add money to your wallet.',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Pay Button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _isLoading || _isPaymentCompleted
                    ? null
                    : _processPayment,
                text: _isLoading
                    ? 'Processing Payment...'
                    : _isPaymentCompleted
                    ? 'Payment Completed'
                    : 'Pay ₹${_amountController.text}',
              ),
            ),

            if (_isPaymentCompleted) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Successful',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Transaction ID: $_transactionId'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About Digital Wallets',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Fast and secure payments\n'
                      '• No need to enter card details\n'
                      '• Instant transaction confirmation\n'
                      '• Available 24/7',
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
