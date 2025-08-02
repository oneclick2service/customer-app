import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../models/booking_model.dart';

class CorporateBillingScreen extends StatefulWidget {
  final BookingModel booking;
  final double amount;

  const CorporateBillingScreen({
    Key? key,
    required this.booking,
    required this.amount,
  }) : super(key: key);

  @override
  State<CorporateBillingScreen> createState() => _CorporateBillingScreenState();
}

class _CorporateBillingScreenState extends State<CorporateBillingScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _billingAddressController =
      TextEditingController();
  final TextEditingController _contactPersonController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _poNumberController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  String _billingType = 'invoice';
  String _paymentTerms = 'net30';
  bool _isLoading = false;
  bool _isInvoiceGenerated = false;
  String? _invoiceNumber;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _companyNameController.dispose();
    _gstNumberController.dispose();
    _billingAddressController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _poNumberController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  void _generateInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate invoice generation
    await Future.delayed(const Duration(seconds: 2));

    // Generate invoice number
    final invoiceNumber =
        'INV${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    setState(() {
      _invoiceNumber = invoiceNumber;
      _isInvoiceGenerated = true;
      _isLoading = false;
    });

    _showInvoiceGeneratedDialog();
  }

  void _showInvoiceGeneratedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.receipt, color: Colors.green),
            SizedBox(width: 8),
            Text('Invoice Generated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invoice Number: $_invoiceNumber'),
            const SizedBox(height: 8),
            Text('Company: ${_companyNameController.text}'),
            const SizedBox(height: 8),
            Text('Amount: ₹${widget.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Payment Terms: ${_getPaymentTermsText()}'),
            const SizedBox(height: 8),
            const Text('Invoice has been generated and sent to your email.'),
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

  String _getPaymentTermsText() {
    switch (_paymentTerms) {
      case 'net15':
        return 'Net 15 days';
      case 'net30':
        return 'Net 30 days';
      case 'net45':
        return 'Net 45 days';
      case 'net60':
        return 'Net 60 days';
      default:
        return 'Net 30 days';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corporate Billing'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Details Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Service Details',
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

              // Company Information
              const Text(
                'Company Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Company Name
              CustomTextField(
                controller: _companyNameController,
                hintText: 'Company Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Company name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // GST Number
              CustomTextField(
                controller: _gstNumberController,
                hintText: 'GST Number',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'GST number is required';
                  }
                  if (value.length != 15) {
                    return 'GST number must be 15 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Billing Address
              CustomTextField(
                controller: _billingAddressController,
                hintText: 'Billing Address',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Billing address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact Person
              CustomTextField(
                controller: _contactPersonController,
                hintText: 'Contact Person Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Contact person name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email and Phone Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _emailController,
                      hintText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _phoneController,
                      hintText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Department and PO Number Row
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _departmentController,
                      hintText: 'Department',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _poNumberController,
                      hintText: 'PO Number (Optional)',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Billing Options
              const Text(
                'Billing Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Billing Type
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Billing Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RadioListTile<String>(
                        title: const Text('Invoice'),
                        subtitle: const Text('Standard invoice for payment'),
                        value: 'invoice',
                        groupValue: _billingType,
                        onChanged: (value) {
                          setState(() {
                            _billingType = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Proforma Invoice'),
                        subtitle: const Text('For advance payment'),
                        value: 'proforma',
                        groupValue: _billingType,
                        onChanged: (value) {
                          setState(() {
                            _billingType = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Payment Terms
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Payment Terms',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _paymentTerms,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select Payment Terms',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'net15',
                            child: Text('Net 15 days'),
                          ),
                          DropdownMenuItem(
                            value: 'net30',
                            child: Text('Net 30 days'),
                          ),
                          DropdownMenuItem(
                            value: 'net45',
                            child: Text('Net 45 days'),
                          ),
                          DropdownMenuItem(
                            value: 'net60',
                            child: Text('Net 60 days'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _paymentTerms = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Corporate Benefits
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.business, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Corporate Benefits',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• Bulk booking discounts\n'
                        '• Dedicated account manager\n'
                        '• Priority customer support\n'
                        '• Monthly consolidated billing\n'
                        '• Tax invoice with GST details\n'
                        '• Expense tracking and reporting',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Generate Invoice Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  onPressed: _isLoading || _isInvoiceGenerated
                      ? null
                      : _generateInvoice,
                  text: _isLoading
                      ? 'Generating Invoice...'
                      : _isInvoiceGenerated
                      ? 'Invoice Generated'
                      : 'Generate Invoice',
                ),
              ),

              if (_isInvoiceGenerated) ...[
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
                              'Invoice Generated Successfully',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Invoice Number: $_invoiceNumber'),
                        const SizedBox(height: 8),
                        const Text(
                          'Invoice has been sent to your email address.',
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Additional Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Important Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• All invoices include GST details\n'
                        '• Payment terms are strictly enforced\n'
                        '• Late payment charges may apply\n'
                        '• For bulk bookings, contact sales team\n'
                        '• Corporate accounts get priority support',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
