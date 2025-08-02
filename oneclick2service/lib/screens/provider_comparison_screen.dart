import 'package:flutter/material.dart';
import '../models/service_provider_model.dart';
import '../widgets/verification_badge_widget.dart';
import '../widgets/star_rating_widget.dart';
import '../widgets/custom_button.dart';

class ProviderComparisonScreen extends StatefulWidget {
  final List<ServiceProviderModel> providers;

  const ProviderComparisonScreen({Key? key, required this.providers})
    : super(key: key);

  @override
  State<ProviderComparisonScreen> createState() =>
      _ProviderComparisonScreenState();
}

class _ProviderComparisonScreenState extends State<ProviderComparisonScreen> {
  String _sortBy = 'rating';
  bool _showVerifiedOnly = false;
  bool _showPremiumOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Comparison'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', true, () => _clearFilters()),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Verified Only',
                          _showVerifiedOnly,
                          () => _toggleVerifiedOnly(),
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          'Premium Only',
                          _showPremiumOnly,
                          () => _togglePremiumOnly(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Sort options
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('Sort by: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                    DropdownMenuItem(
                      value: 'experience',
                      child: Text('Experience'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('Completed Services'),
                    ),
                    DropdownMenuItem(
                      value: 'response',
                      child: Text('Response Time'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Comparison table
          Expanded(child: _buildComparisonTable()),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue.shade600,
    );
  }

  Widget _buildComparisonTable() {
    final filteredProviders = _getFilteredProviders();
    final sortedProviders = _getSortedProviders(filteredProviders);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header row
          _buildHeaderRow(),
          const SizedBox(height: 16),
          // Provider rows
          ...sortedProviders.map((provider) => _buildProviderRow(provider)),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: const Text(
              'Provider',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: const Text(
              'Rating',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: const Text(
              'Verified',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: const Text(
              'Experience',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: const Text(
              'Services',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderRow(ServiceProviderModel provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: provider.profileImage != null
                          ? NetworkImage(provider.profileImage!)
                          : null,
                      child: provider.profileImage == null
                          ? Text(
                              provider.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            provider.serviceCategories.isNotEmpty
                                ? provider.serviceCategories.first
                                : 'Service Provider',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                VerificationBadgeWidget(
                  level: _getVerificationLevel(provider),
                  badgeText: _getVerificationText(provider),
                  showDetails: false,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                children: [
                  StarRatingWidget(
                    initialRating: provider.rating,
                    size: 12,
                    readOnly: true,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Icon(
                provider.isVerified ? Icons.verified : Icons.pending,
                color: provider.isVerified ? Colors.green : Colors.orange,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                provider.experience ?? 'N/A',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${provider.completedBookings}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<ServiceProviderModel> _getFilteredProviders() {
    List<ServiceProviderModel> filtered = widget.providers;

    if (_showVerifiedOnly) {
      filtered = filtered.where((provider) => provider.isVerified).toList();
    }

    if (_showPremiumOnly) {
      filtered = filtered
          .where(
            (provider) =>
                provider.rating >= 4.5 && provider.completedBookings >= 50,
          )
          .toList();
    }

    return filtered;
  }

  List<ServiceProviderModel> _getSortedProviders(
    List<ServiceProviderModel> providers,
  ) {
    switch (_sortBy) {
      case 'rating':
        providers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience':
        providers.sort((a, b) {
          final aExp = a.experience ?? '';
          final bExp = b.experience ?? '';
          return bExp.compareTo(aExp);
        });
        break;
      case 'completed':
        providers.sort(
          (a, b) => b.completedBookings.compareTo(a.completedBookings),
        );
        break;
      case 'response':
        // Mock response time sorting
        providers.sort((a, b) => a.totalBookings.compareTo(b.totalBookings));
        break;
    }
    return providers;
  }

  VerificationLevel _getVerificationLevel(ServiceProviderModel provider) {
    if (provider.rating >= 4.8 && provider.completedBookings >= 100) {
      return VerificationLevel.expert;
    } else if (provider.rating >= 4.5 && provider.completedBookings >= 50) {
      return VerificationLevel.premium;
    } else if (provider.isBackgroundChecked) {
      return VerificationLevel.verified;
    } else {
      return VerificationLevel.basic;
    }
  }

  String _getVerificationText(ServiceProviderModel provider) {
    switch (_getVerificationLevel(provider)) {
      case VerificationLevel.basic:
        return 'Basic';
      case VerificationLevel.verified:
        return 'Verified';
      case VerificationLevel.premium:
        return 'Premium';
      case VerificationLevel.expert:
        return 'Expert';
    }
  }

  void _clearFilters() {
    setState(() {
      _showVerifiedOnly = false;
      _showPremiumOnly = false;
    });
  }

  void _toggleVerifiedOnly() {
    setState(() {
      _showVerifiedOnly = !_showVerifiedOnly;
      if (_showVerifiedOnly) {
        _showPremiumOnly = false;
      }
    });
  }

  void _togglePremiumOnly() {
    setState(() {
      _showPremiumOnly = !_showPremiumOnly;
      if (_showPremiumOnly) {
        _showVerifiedOnly = false;
      }
    });
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show verified providers only'),
              value: _showVerifiedOnly,
              onChanged: (value) {
                setState(() {
                  _showVerifiedOnly = value ?? false;
                });
                Navigator.pop(context);
              },
            ),
            CheckboxListTile(
              title: const Text('Show premium providers only'),
              value: _showPremiumOnly,
              onChanged: (value) {
                setState(() {
                  _showPremiumOnly = value ?? false;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
