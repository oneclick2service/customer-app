import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('One Click'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.primaryColor,
              Color(0xFF1976D2),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              children: [
                // Welcome Section
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Welcome to One Click!',
                        style: AppConstants.headingStyle.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Your service marketplace for Vijayawada',
                        style: AppConstants.bodyStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingXLarge),
                
                // Service Categories
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppConstants.paddingMedium,
                      mainAxisSpacing: AppConstants.paddingMedium,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: AppConstants.serviceCategories.length,
                    itemBuilder: (context, index) {
                      final category = AppConstants.serviceCategories[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          boxShadow: AppConstants.cardShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: category['color'].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                              ),
                              child: Center(
                                child: Text(
                                  category['icon'],
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppConstants.paddingMedium),
                            Text(
                              category['name'],
                              style: AppConstants.subheadingStyle.copyWith(
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppConstants.paddingSmall),
                            Text(
                              category['description'],
                              style: AppConstants.captionStyle.copyWith(
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 