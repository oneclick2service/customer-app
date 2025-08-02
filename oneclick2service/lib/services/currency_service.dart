import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CurrencyService {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  // Supported currencies
  static const Map<String, CurrencyInfo> _supportedCurrencies = {
    'INR': CurrencyInfo(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      decimalPlaces: 2,
      isDefault: true,
    ),
    'USD': CurrencyInfo(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      decimalPlaces: 2,
      isDefault: false,
    ),
    'EUR': CurrencyInfo(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      decimalPlaces: 2,
      isDefault: false,
    ),
    'GBP': CurrencyInfo(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      decimalPlaces: 2,
      isDefault: false,
    ),
    'AED': CurrencyInfo(
      code: 'AED',
      name: 'UAE Dirham',
      symbol: 'د.إ',
      decimalPlaces: 2,
      isDefault: false,
    ),
    'SGD': CurrencyInfo(
      code: 'SGD',
      name: 'Singapore Dollar',
      symbol: 'S\$',
      decimalPlaces: 2,
      isDefault: false,
    ),
  };

  // Exchange rates (mock data - replace with real API)
  static const Map<String, double> _exchangeRates = {
    'USD': 0.012, // 1 INR = 0.012 USD
    'EUR': 0.011, // 1 INR = 0.011 EUR
    'GBP': 0.0095, // 1 INR = 0.0095 GBP
    'AED': 0.044, // 1 INR = 0.044 AED
    'SGD': 0.016, // 1 INR = 0.016 SGD
  };

  String _currentCurrency = 'INR';
  Map<String, double> _cachedRates = {};
  DateTime? _lastRateUpdate;

  // Initialize currency service
  Future<void> initialize() async {
    await _loadUserCurrencyPreference();
    await _updateExchangeRates();
    debugPrint('Currency service initialized with currency: $_currentCurrency');
  }

  // Get supported currencies
  List<CurrencyInfo> getSupportedCurrencies() {
    return _supportedCurrencies.values.toList();
  }

  // Get current currency
  String getCurrentCurrency() {
    return _currentCurrency;
  }

  // Set current currency
  Future<void> setCurrentCurrency(String currencyCode) async {
    if (!_supportedCurrencies.containsKey(currencyCode)) {
      throw Exception('Unsupported currency: $currencyCode');
    }

    _currentCurrency = currencyCode;
    await _saveUserCurrencyPreference();
    debugPrint('Currency changed to: $_currentCurrency');
  }

  // Get currency info
  CurrencyInfo? getCurrencyInfo(String currencyCode) {
    return _supportedCurrencies[currencyCode];
  }

  // Format amount in current currency
  String formatAmount(double amount, {String? currencyCode}) {
    final currency = currencyCode ?? _currentCurrency;
    final info = _supportedCurrencies[currency];

    if (info == null) {
      return amount.toStringAsFixed(2);
    }

    return '${info.symbol}${amount.toStringAsFixed(info.decimalPlaces)}';
  }

  // Convert amount between currencies
  double convertAmount(double amount, String fromCurrency, String toCurrency) {
    if (fromCurrency == toCurrency) {
      return amount;
    }

    // Convert to base currency (INR) first
    double inBaseCurrency = amount;
    if (fromCurrency != 'INR') {
      final fromRate = _getExchangeRate(fromCurrency);
      inBaseCurrency = amount / fromRate;
    }

    // Convert from base currency to target currency
    if (toCurrency != 'INR') {
      final toRate = _getExchangeRate(toCurrency);
      return inBaseCurrency * toRate;
    }

    return inBaseCurrency;
  }

  // Convert amount to current currency
  double convertToCurrentCurrency(double amount, String fromCurrency) {
    return convertAmount(amount, fromCurrency, _currentCurrency);
  }

  // Get exchange rate
  double _getExchangeRate(String currencyCode) {
    if (currencyCode == 'INR') return 1.0;

    final rate = _exchangeRates[currencyCode];
    if (rate == null) {
      debugPrint('Exchange rate not found for: $currencyCode');
      return 1.0; // Fallback to 1:1
    }

    return rate;
  }

  // Update exchange rates from API
  Future<void> _updateExchangeRates() async {
    try {
      // TODO: Replace with real exchange rate API
      // For now, use mock data
      _cachedRates = Map.from(_exchangeRates);
      _lastRateUpdate = DateTime.now();

      debugPrint('Exchange rates updated');
    } catch (e) {
      debugPrint('Failed to update exchange rates: $e');
      // Use cached rates if available
      if (_cachedRates.isEmpty) {
        _cachedRates = Map.from(_exchangeRates);
      }
    }
  }

  // Load user currency preference
  Future<void> _loadUserCurrencyPreference() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('user_preferences')
          .select('currency')
          .eq('user_id', user.id)
          .single();

      if (response != null && response['currency'] != null) {
        final currency = response['currency'] as String;
        if (_supportedCurrencies.containsKey(currency)) {
          _currentCurrency = currency;
        }
      }
    } catch (e) {
      debugPrint('Failed to load currency preference: $e');
    }
  }

  // Save user currency preference
  Future<void> _saveUserCurrencyPreference() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      await _supabase.from('user_preferences').upsert({
        'user_id': user.id,
        'currency': _currentCurrency,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Failed to save currency preference: $e');
    }
  }

  // Get currency symbol
  String getCurrencySymbol(String currencyCode) {
    final info = _supportedCurrencies[currencyCode];
    return info?.symbol ?? currencyCode;
  }

  // Check if currency is supported
  bool isCurrencySupported(String currencyCode) {
    return _supportedCurrencies.containsKey(currencyCode);
  }

  // Get default currency
  String getDefaultCurrency() {
    return _supportedCurrencies.entries
        .firstWhere((entry) => entry.value.isDefault)
        .key;
  }

  // Format price range
  String formatPriceRange(
    double minPrice,
    double maxPrice, {
    String? currencyCode,
  }) {
    final currency = currencyCode ?? _currentCurrency;
    final minFormatted = formatAmount(minPrice, currencyCode: currency);
    final maxFormatted = formatAmount(maxPrice, currencyCode: currency);

    if (minPrice == maxPrice) {
      return minFormatted;
    }

    return '$minFormatted - $maxFormatted';
  }

  // Parse amount from string
  double? parseAmount(String amountString, {String? currencyCode}) {
    try {
      final currency = currencyCode ?? _currentCurrency;
      final info = _supportedCurrencies[currency];

      if (info == null) return null;

      // Remove currency symbol and other non-numeric characters
      final cleanString = amountString
          .replaceAll(RegExp(r'[^\d.,]'), '')
          .replaceAll(',', '');

      return double.parse(cleanString);
    } catch (e) {
      debugPrint('Failed to parse amount: $e');
      return null;
    }
  }

  // Get currency display name
  String getCurrencyDisplayName(String currencyCode) {
    final info = _supportedCurrencies[currencyCode];
    return info?.name ?? currencyCode;
  }

  // Check if exchange rates are stale
  bool areExchangeRatesStale() {
    if (_lastRateUpdate == null) return true;

    final now = DateTime.now();
    final difference = now.difference(_lastRateUpdate!);

    // Consider rates stale after 1 hour
    return difference.inHours >= 1;
  }

  // Force refresh exchange rates
  Future<void> refreshExchangeRates() async {
    await _updateExchangeRates();
  }

  // Get all exchange rates
  Map<String, double> getAllExchangeRates() {
    final rates = <String, double>{'INR': 1.0};
    rates.addAll(_cachedRates);
    return rates;
  }

  // Validate currency code
  bool isValidCurrencyCode(String currencyCode) {
    return _supportedCurrencies.containsKey(currencyCode);
  }

  // Get currency info for current currency
  CurrencyInfo? getCurrentCurrencyInfo() {
    return _supportedCurrencies[_currentCurrency];
  }

  // Format amount with currency code
  String formatAmountWithCode(double amount, {String? currencyCode}) {
    final currency = currencyCode ?? _currentCurrency;
    final formatted = formatAmount(amount, currencyCode: currency);
    return '$formatted $currency';
  }

  // Get currency list for dropdown
  List<Map<String, String>> getCurrencyListForDropdown() {
    return _supportedCurrencies.entries.map((entry) {
      return {
        'code': entry.key,
        'name': '${entry.value.name} (${entry.value.symbol})',
      };
    }).toList();
  }
}

// Currency information model
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final int decimalPlaces;
  final bool isDefault;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.decimalPlaces,
    required this.isDefault,
  });

  @override
  String toString() {
    return 'CurrencyInfo(code: $code, name: $name, symbol: $symbol)';
  }
}
