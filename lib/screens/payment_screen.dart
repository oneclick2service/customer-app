import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/booking_model.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const PaymentScreen({Key? key, required this.booking, required this.amount})
    : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();

  // Payment method selection
  String _selectedPaymentMethod = PaymentService.PAYMENT_METHOD_UPI;

  // UPI fields
  final TextEditingController _upiIdController = TextEditingController();
  String? _selectedUpiApp;

  // Card fields
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardholderController = TextEditingController();

  // Wallet fields
  String? _selectedWallet;
  final TextEditingController _walletIdController = TextEditingController();

  // Payment processing
  bool _isProcessing = false;
  String? _error;

  // Pricing breakdown
  late final Map<String, double> _pricingBreakdown;

  @override
  void initState() {
    super.initState();
    _calculatePricingBreakdown();
  }

  @override
  void dispose() {
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardholderController.dispose();
    _walletIdController.dispose();
    super.dispose();
  }

  void _calculatePricingBreakdown() {
    final baseAmount = widget.amount;
    final serviceCharge = baseAmount * 0.05; // 5% service charge
    final gst = (baseAmount + serviceCharge) * 0.18; // 18% GST
    final total = baseAmount + serviceCharge + gst;

    _pricingBreakdown = {
      'Base Amount': baseAmount,
      'Service Charge': serviceCharge,
      'GST (18%)': gst,
      'Total': total,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPricingBreakdown(),
            const SizedBox(height: 24),
            _buildPaymentMethodSelection(),
            const SizedBox(height: 24),
            _buildPaymentForm(),
            const SizedBox(height: 24),
            _buildPaymentButton(),
            if (_error != null) ...[
              const SizedBox(height: 16),
              _buildErrorWidget(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.receipt, color: AppConstants.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                'Pricing Breakdown',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._pricingBreakdown.entries.map((entry) {
            final isTotal = entry.key == 'Total';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                      color: isTotal
                          ? AppConstants.primaryColor
                          : Colors.grey[700],
                    ),
                  ),
                  Text(
                    '₹${entry.value.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                      color: isTotal
                          ? AppConstants.primaryColor
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No hidden fees • Transparent pricing',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Method',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildPaymentMethodCard(
              'UPI',
              Icons.account_balance_wallet,
              PaymentService.PAYMENT_METHOD_UPI,
              'Fast & Secure',
            ),
            _buildPaymentMethodCard(
              'Card',
              Icons.credit_card,
              PaymentService.PAYMENT_METHOD_CARD,
              'Credit/Debit',
            ),
            _buildPaymentMethodCard(
              'Wallet',
              Icons.account_balance,
              PaymentService.PAYMENT_METHOD_WALLET,
              'Digital Wallet',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    IconData icon,
    String method,
    String subtitle,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = method;
          _error = null;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white70 : Colors.grey[500],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    switch (_selectedPaymentMethod) {
      case PaymentService.PAYMENT_METHOD_UPI:
        return _buildUPIForm();
      case PaymentService.PAYMENT_METHOD_CARD:
        return _buildCardForm();
      case PaymentService.PAYMENT_METHOD_WALLET:
        return _buildWalletForm();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUPIForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UPI Payment',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _upiIdController,
          labelText: 'UPI ID',
          hintText: 'example@upi',
          prefixIcon: Icon(Icons.account_balance_wallet),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter UPI ID';
            }
            if (!_paymentService.isValidUPI(value)) {
              return 'Please enter a valid UPI ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Select UPI App (Optional)',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _paymentService.getAvailableUPIApps().map((app) {
            final isSelected = _selectedUpiApp == app;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedUpiApp = isSelected ? null : app;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryColor
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  app,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCardForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Card Payment',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _cardNumberController,
          labelText: 'Card Number',
          hintText: '1234 5678 9012 3456',
          prefixIcon: Icon(Icons.credit_card),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter card number';
            }
            if (value.length < 13) {
              return 'Please enter a valid card number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _expiryController,
                labelText: 'Expiry Date',
                hintText: 'MM/YY',
                prefixIcon: Icon(Icons.calendar_today),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter expiry date';
                  }
                  if (value.length != 4) {
                    return 'Please enter MM/YY format';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _cvvController,
                labelText: 'CVV',
                hintText: '123',
                prefixIcon: Icon(Icons.security),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter CVV';
                  }
                  if (value.length < 3) {
                    return 'Please enter valid CVV';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _cardholderController,
          labelText: 'Cardholder Name',
          hintText: 'John Doe',
          prefixIcon: Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter cardholder name';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildWalletForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Digital Wallet',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          'Select Wallet',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _paymentService.getAvailableWallets().map((wallet) {
            final isSelected = _selectedWallet == wallet;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedWallet = isSelected ? null : wallet;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppConstants.primaryColor
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppConstants.primaryColor
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  wallet,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedWallet != null) ...[
          const SizedBox(height: 16),
          CustomTextField(
            controller: _walletIdController,
            labelText: 'Wallet ID/Phone Number',
            hintText: 'Enter your wallet ID or phone number',
            prefixIcon: Icon(Icons.account_balance_wallet),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter wallet ID';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      child: CustomButton(
        text: _isProcessing
            ? 'Processing...'
            : 'Pay ₹${_pricingBreakdown['Total']!.toStringAsFixed(2)}',
        onPressed: _isProcessing ? null : _processPayment,
        backgroundColor: AppConstants.primaryColor,
        textColor: Colors.white,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_error!, style: TextStyle(color: Colors.red[700])),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    // Validate form based on payment method
    if (!_validateForm()) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      PaymentResult result;

      switch (_selectedPaymentMethod) {
        case PaymentService.PAYMENT_METHOD_UPI:
          result = await _paymentService.processUPIPayment(
            booking: widget.booking,
            amount: _pricingBreakdown['Total']!,
            upiId: _upiIdController.text.trim(),
          );
          break;

        case PaymentService.PAYMENT_METHOD_CARD:
          result = await _paymentService.processCardPayment(
            booking: widget.booking,
            amount: _pricingBreakdown['Total']!,
            cardNumber: _cardNumberController.text.trim(),
            expiryDate: _formatExpiryDate(_expiryController.text.trim()),
            cvv: _cvvController.text.trim(),
            cardholderName: _cardholderController.text.trim(),
          );
          break;

        case PaymentService.PAYMENT_METHOD_WALLET:
          result = await _paymentService.processWalletPayment(
            booking: widget.booking,
            amount: _pricingBreakdown['Total']!,
            walletType: _selectedWallet!,
          );
          break;

        default:
          throw Exception('Invalid payment method');
      }

      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        setState(() {
          _error = result.errorMessage ?? 'Payment failed';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Payment failed: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  bool _validateForm() {
    switch (_selectedPaymentMethod) {
      case PaymentService.PAYMENT_METHOD_UPI:
        if (_upiIdController.text.trim().isEmpty) {
          setState(() {
            _error = 'Please enter UPI ID';
          });
          return false;
        }
        if (!_paymentService.isValidUPI(_upiIdController.text.trim())) {
          setState(() {
            _error = 'Please enter a valid UPI ID';
          });
          return false;
        }
        break;

      case PaymentService.PAYMENT_METHOD_CARD:
        if (_cardNumberController.text.trim().isEmpty) {
          setState(() {
            _error = 'Please enter card number';
          });
          return false;
        }
        if (_expiryController.text.trim().isEmpty) {
          setState(() {
            _error = 'Please enter expiry date';
          });
          return false;
        }
        if (_cvvController.text.trim().isEmpty) {
          setState(() {
            _error = 'Please enter CVV';
          });
          return false;
        }
        if (_cardholderController.text.trim().isEmpty) {
          setState(() {
            _error = 'Please enter cardholder name';
          });
          return false;
        }
        break;

      case PaymentService.PAYMENT_METHOD_WALLET:
        if (_selectedWallet == null) {
          setState(() {
            _error = 'Please select a wallet';
          });
          return false;
        }
        if (_walletIdController.text.trim().isEmpty) {
          setState(() {
            _error = 'Please enter wallet ID';
          });
          return false;
        }
        break;
    }

    return true;
  }

  String _formatExpiryDate(String input) {
    if (input.length == 4) {
      return '${input.substring(0, 2)}/${input.substring(2)}';
    }
    return input;
  }
}
