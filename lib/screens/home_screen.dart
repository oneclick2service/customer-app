import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isVerySmallScreen = ResponsiveUtils.isVerySmallScreen(context);
    final adaptivePadding = ResponsiveUtils.getAdaptivePadding(context);
    final adaptiveSpacing = ResponsiveUtils.getAdaptiveSpacing(context);
    final adaptiveTitleSize = ResponsiveUtils.getAdaptiveTitleSize(context);

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
            colors: [AppConstants.primaryColor, Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: ResponsiveUtils.scrollableContent(
            context: context,
            child: Column(
              children: [
                SizedBox(height: adaptiveSpacing),

                // Welcome Section
                Container(
                  padding: EdgeInsets.all(adaptivePadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
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
                          fontSize: adaptiveTitleSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppConstants.paddingMedium),
                      Text(
                        'Your service marketplace for Vijayawada',
                        style: AppConstants.bodyStyle.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: ResponsiveUtils.getAdaptiveBodySize(
                            context,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: adaptiveSpacing),

                // Service Categories
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isVerySmallScreen ? 1 : 2,
                    crossAxisSpacing: AppConstants.paddingMedium,
                    mainAxisSpacing: AppConstants.paddingMedium,
                    childAspectRatio: isVerySmallScreen ? 2.5 : 1.2,
                  ),
                  itemCount: AppConstants.serviceCategories.length,
                  itemBuilder: (context, index) {
                    final category = AppConstants.serviceCategories[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusMedium,
                        ),
                        boxShadow: AppConstants.cardShadow,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: isVerySmallScreen ? 40 : 50,
                            height: isVerySmallScreen ? 40 : 50,
                            decoration: BoxDecoration(
                              color: category['color'].withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadiusSmall,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                category['icon'],
                                style: TextStyle(
                                  fontSize: isVerySmallScreen ? 20 : 24,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppConstants.paddingMedium),
                          Text(
                            category['name'],
                            style: AppConstants.subheadingStyle.copyWith(
                              fontSize: isVerySmallScreen ? 12 : 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: AppConstants.paddingSmall),
                          Text(
                            category['description'],
                            style: AppConstants.captionStyle.copyWith(
                              fontSize: ResponsiveUtils.getAdaptiveCaptionSize(
                                context,
                              ),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: isVerySmallScreen ? 1 : 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                ),

                SizedBox(height: adaptiveSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
