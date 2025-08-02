import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import '../utils/responsive_utils.dart';
import 'account_type_selection_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResendLoading = false;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendTimer();
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(widget.phoneNumber, otp);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Save session and navigate to account type selection
        await authProvider.saveSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountTypeSelectionScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Invalid OTP'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResendLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.sendOtp(widget.phoneNumber);

    if (mounted) {
      setState(() {
        _isResendLoading = false;
        _resendCountdown = 30;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        _startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Failed to send OTP'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = ResponsiveUtils.isSmallScreen(context);
    final isVerySmallScreen = ResponsiveUtils.isVerySmallScreen(context);
    final adaptivePadding = ResponsiveUtils.getAdaptivePadding(context);
    final adaptiveSpacing = ResponsiveUtils.getAdaptiveSpacing(context);
    final adaptiveIconSize = ResponsiveUtils.getAdaptiveIconSize(context);
    final adaptiveTitleSize = ResponsiveUtils.getAdaptiveTitleSize(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: ResponsiveUtils.scrollableContent(
            context: context,
            child: Column(
              children: [
                SizedBox(height: adaptiveSpacing),

                // Header
                Container(
                  padding: EdgeInsets.all(adaptivePadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    boxShadow: AppConstants.elevatedShadow,
                  ),
                  child: Column(
                    children: [
                      // Phone Icon
                      Container(
                        width: adaptiveIconSize,
                        height: adaptiveIconSize,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusLarge,
                          ),
                        ),
                        child: Icon(
                          Icons.phone_android,
                          size: adaptiveIconSize * 0.5,
                          color: AppConstants.primaryColor,
                        ),
                      ),

                      SizedBox(height: adaptiveSpacing),

                      // Title
                      Text(
                        'Verify Your Number',
                        style: AppConstants.headingStyle.copyWith(
                          fontSize: adaptiveTitleSize,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppConstants.marginMedium),

                      // Description
                      Text(
                        'We\'ve sent a 6-digit code to',
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.textSecondaryColor,
                          fontSize: ResponsiveUtils.getAdaptiveBodySize(
                            context,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.marginSmall),

                      Text(
                        widget.phoneNumber,
                        style: AppConstants.subheadingStyle.copyWith(
                          color: AppConstants.primaryColor,
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: adaptiveSpacing),

                // OTP Input
                Container(
                  padding: EdgeInsets.all(adaptivePadding),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    boxShadow: AppConstants.elevatedShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Enter OTP',
                        style: AppConstants.subheadingStyle.copyWith(
                          fontSize: isSmallScreen ? 16 : 18,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: AppConstants.marginMedium),

                      // OTP Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: isVerySmallScreen ? 40 : 50,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusMedium,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadiusMedium,
                                  ),
                                  borderSide: const BorderSide(
                                    color: AppConstants.primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) => _onOtpChanged(value, index),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: adaptiveSpacing),

                      // Verify Button
                      CustomButton(
                        text: 'Verify OTP',
                        onPressed: _isLoading ? null : _verifyOtp,
                        isLoading: _isLoading,
                      ),

                      SizedBox(height: AppConstants.marginMedium),

                      // Resend OTP
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Didn\'t receive the code? ',
                            style: AppConstants.captionStyle.copyWith(
                              fontSize: ResponsiveUtils.getAdaptiveCaptionSize(
                                context,
                              ),
                            ),
                          ),
                          if (_resendCountdown > 0)
                            Text(
                              'Resend in $_resendCountdown seconds',
                              style: AppConstants.captionStyle.copyWith(
                                color: AppConstants.primaryColor,
                                fontSize:
                                    ResponsiveUtils.getAdaptiveCaptionSize(
                                      context,
                                    ),
                              ),
                            )
                          else
                            TextButton(
                              onPressed: _isResendLoading ? null : _resendOtp,
                              child: _isResendLoading
                                  ? const SizedBox(
                                      height: 16,
                                      width: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Resend OTP',
                                      style: AppConstants.captionStyle.copyWith(
                                        color: AppConstants.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize:
                                            ResponsiveUtils.getAdaptiveCaptionSize(
                                              context,
                                            ),
                                      ),
                                    ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: adaptiveSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
