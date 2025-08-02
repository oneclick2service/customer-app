import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/service_provider_model.dart';

class ProviderCard extends StatelessWidget {
  final ServiceProvider provider;
  final VoidCallback? onTap;

  const ProviderCard({Key? key, required this.provider, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with profile and basic info
                Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: provider.profileImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                provider.profileImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.person,
                                    color: AppConstants.primaryColor,
                                    size: 30,
                                  );
                                },
                              ),
                            )
                          : Icon(
                              Icons.person,
                              color: AppConstants.primaryColor,
                              size: 30,
                            ),
                    ),
                    const SizedBox(width: 12),

                    // Provider Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  provider.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (provider.isVerified)
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
                                    '✓ Verified',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Rating and Reviews
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${provider.rating} (${provider.totalReviews} reviews)',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          // Experience and Specializations
                          const SizedBox(height: 4),
                          Text(
                            '${provider.experience} years exp • ${provider.specializations.join(", ")}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Details Row
                Row(
                  children: [
                    // Distance
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.location_on,
                        label: 'Distance',
                        value: '${provider.distance} km',
                        color: Colors.blue,
                      ),
                    ),

                    // ETA
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.access_time,
                        label: 'ETA',
                        value: '${provider.estimatedArrival} min',
                        color: Colors.orange,
                      ),
                    ),

                    // Price
                    Expanded(
                      child: _buildDetailItem(
                        icon: Icons.currency_rupee,
                        label: 'Rate',
                        value: '₹${provider.hourlyRate}/hr',
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Trust Score and Availability
                Row(
                  children: [
                    // Trust Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getTrustScoreColor(
                          provider.trustScore,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Trust Score: ${provider.trustScore}%',
                        style: TextStyle(
                          color: _getTrustScoreColor(provider.trustScore),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Availability Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: provider.isAvailable
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        provider.isAvailable ? 'Available' : 'Busy',
                        style: TextStyle(
                          color: provider.isAvailable
                              ? Colors.green
                              : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Languages
                if (provider.languages.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: provider.languages.map((language) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          language,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }

  Color _getTrustScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.orange;
    if (score >= 70) return Colors.yellow[700]!;
    return Colors.red;
  }
}
